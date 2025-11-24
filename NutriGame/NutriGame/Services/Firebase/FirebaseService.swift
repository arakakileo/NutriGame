//
//  FirebaseService.swift
//  NutriGame
//
//  Created by NutriGame Team
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class FirebaseService {
    static let shared = FirebaseService()

    let db: Firestore
    let storage: Storage

    private init() {
        db = Firestore.firestore()
        storage = Storage.storage()

        // Configurar settings do Firestore
        let settings = db.settings
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }

    // MARK: - Collection References
    var usersCollection: CollectionReference {
        db.collection(Constants.FirestoreCollection.users)
    }

    var squadsCollection: CollectionReference {
        db.collection(Constants.FirestoreCollection.squads)
    }

    var missionsCollection: CollectionReference {
        db.collection(Constants.FirestoreCollection.missions)
    }

    var weeklyRankingsCollection: CollectionReference {
        db.collection(Constants.FirestoreCollection.weeklyRankings)
    }

    var premiumPlansCollection: CollectionReference {
        db.collection(Constants.FirestoreCollection.premiumPlans)
    }

    // MARK: - Storage References
    func avatarRef(userId: String) -> StorageReference {
        storage.reference()
            .child(Constants.StoragePath.avatars)
            .child("\(userId).jpg")
    }

    func missionPhotoRef(missionId: String) -> StorageReference {
        storage.reference()
            .child(Constants.StoragePath.missionPhotos)
            .child("\(missionId).jpg")
    }
}

// MARK: - Firestore Helpers
extension FirebaseService {
    func document<T: Decodable>(
        _ reference: DocumentReference,
        as type: T.Type
    ) async throws -> T {
        let snapshot = try await reference.getDocument()
        return try snapshot.data(as: type)
    }

    func documents<T: Decodable>(
        _ query: Query,
        as type: T.Type
    ) async throws -> [T] {
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: type) }
    }

    func setDocument<T: Encodable>(
        _ data: T,
        at reference: DocumentReference
    ) async throws {
        try reference.setData(from: data)
    }

    func updateDocument(
        _ data: [String: Any],
        at reference: DocumentReference
    ) async throws {
        try await reference.updateData(data)
    }

    func deleteDocument(_ reference: DocumentReference) async throws {
        try await reference.delete()
    }
}

// MARK: - Storage Helpers
extension FirebaseService {
    func uploadImage(
        _ imageData: Data,
        to reference: StorageReference
    ) async throws -> URL {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await reference.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await reference.downloadURL()
        return downloadURL
    }

    func deleteImage(at reference: StorageReference) async throws {
        try await reference.delete()
    }
}
