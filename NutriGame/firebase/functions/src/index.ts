/**
 * NutriGame Cloud Functions
 *
 * Functions for:
 * - Scheduled notifications (meal reminders, streak warnings)
 * - Weekly ranking reset
 * - User statistics updates
 * - Push notification delivery
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============================================
// TYPES
// ============================================

interface User {
  name: string;
  email: string;
  fcmToken?: string;
  timezone: string;
  notificationsEnabled: boolean;
  squadCode?: string;
  currentStreak: number;
  totalXP: number;
  level: number;
  lastCompletedDate?: admin.firestore.Timestamp;
}

interface NotificationPayload {
  title: string;
  body: string;
  data?: { [key: string]: string };
}

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Send push notification to a user
 */
async function sendPushNotification(
  fcmToken: string,
  payload: NotificationPayload
): Promise<boolean> {
  try {
    await messaging.send({
      token: fcmToken,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data: payload.data,
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });
    return true;
  } catch (error) {
    console.error("Error sending notification:", error);
    return false;
  }
}

/**
 * Get current hour in user's timezone
 */
function getCurrentHourInTimezone(timezone: string): number {
  try {
    const now = new Date();
    const options: Intl.DateTimeFormatOptions = {
      hour: "numeric",
      hour12: false,
      timeZone: timezone,
    };
    const hourStr = new Intl.DateTimeFormat("en-US", options).format(now);
    return parseInt(hourStr, 10);
  } catch {
    // Default to UTC if timezone is invalid
    return new Date().getUTCHours();
  }
}

/**
 * Get today's date string in user's timezone
 */
function getTodayDateString(timezone: string): string {
  try {
    const now = new Date();
    const options: Intl.DateTimeFormatOptions = {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      timeZone: timezone,
    };
    const parts = new Intl.DateTimeFormat("en-CA", options).formatToParts(now);
    const year = parts.find((p) => p.type === "year")?.value;
    const month = parts.find((p) => p.type === "month")?.value;
    const day = parts.find((p) => p.type === "day")?.value;
    return `${year}-${month}-${day}`;
  } catch {
    return new Date().toISOString().split("T")[0];
  }
}

/**
 * Get week ID (YYYY-WW format)
 */
function getWeekId(date: Date = new Date()): string {
  const year = date.getUTCFullYear();
  const startOfYear = new Date(Date.UTC(year, 0, 1));
  const days = Math.floor(
    (date.getTime() - startOfYear.getTime()) / (24 * 60 * 60 * 1000)
  );
  const weekNumber = Math.ceil((days + startOfYear.getUTCDay() + 1) / 7);
  return `${year}-${weekNumber.toString().padStart(2, "0")}`;
}

/**
 * Get missions completed today by user
 */
async function getTodayMissions(
  userId: string,
  date: string
): Promise<string[]> {
  const snapshot = await db
    .collection("missions")
    .where("userId", "==", userId)
    .where("date", "==", date)
    .get();

  return snapshot.docs.map((doc) => doc.data().type as string);
}

// ============================================
// SCHEDULED FUNCTIONS
// ============================================

/**
 * Morning notification - Breakfast reminder (09:00 local time)
 * Runs every hour, checks user timezone
 */
export const sendBreakfastReminder = functions.pubsub
  .schedule("0 * * * *") // Every hour
  .onRun(async () => {
    const usersSnapshot = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const notifications: Promise<boolean>[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as User;
      if (!user.fcmToken || !user.timezone) continue;

      const currentHour = getCurrentHourInTimezone(user.timezone);
      if (currentHour !== 9) continue; // Only at 9 AM local time

      const todayMissions = await getTodayMissions(
        doc.id,
        getTodayDateString(user.timezone)
      );

      if (!todayMissions.includes("breakfast")) {
        notifications.push(
          sendPushNotification(user.fcmToken, {
            title: "Bom dia! ☀️",
            body: "Registre seu café da manhã e ganhe 50 XP!",
            data: { type: "mission_reminder", missionType: "breakfast" },
          })
        );
      }
    }

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} breakfast reminders`);
  });

/**
 * Lunch notification (13:00 local time)
 */
export const sendLunchReminder = functions.pubsub
  .schedule("0 * * * *")
  .onRun(async () => {
    const usersSnapshot = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const notifications: Promise<boolean>[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as User;
      if (!user.fcmToken || !user.timezone) continue;

      const currentHour = getCurrentHourInTimezone(user.timezone);
      if (currentHour !== 13) continue;

      const todayMissions = await getTodayMissions(
        doc.id,
        getTodayDateString(user.timezone)
      );

      if (!todayMissions.includes("lunch")) {
        notifications.push(
          sendPushNotification(user.fcmToken, {
            title: "Hora do almoço! 🍽️",
            body: "Não esqueça de registrar seu almoço!",
            data: { type: "mission_reminder", missionType: "lunch" },
          })
        );
      }
    }

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} lunch reminders`);
  });

/**
 * Dinner notification (19:00 local time)
 */
export const sendDinnerReminder = functions.pubsub
  .schedule("0 * * * *")
  .onRun(async () => {
    const usersSnapshot = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const notifications: Promise<boolean>[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as User;
      if (!user.fcmToken || !user.timezone) continue;

      const currentHour = getCurrentHourInTimezone(user.timezone);
      if (currentHour !== 19) continue;

      const todayMissions = await getTodayMissions(
        doc.id,
        getTodayDateString(user.timezone)
      );

      if (!todayMissions.includes("dinner")) {
        notifications.push(
          sendPushNotification(user.fcmToken, {
            title: "Hora do jantar! 🌙",
            body: "Complete sua missão de jantar!",
            data: { type: "mission_reminder", missionType: "dinner" },
          })
        );
      }
    }

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} dinner reminders`);
  });

/**
 * Daily summary notification (21:00 local time)
 */
export const sendDailySummary = functions.pubsub
  .schedule("0 * * * *")
  .onRun(async () => {
    const usersSnapshot = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    const notifications: Promise<boolean>[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as User;
      if (!user.fcmToken || !user.timezone) continue;

      const currentHour = getCurrentHourInTimezone(user.timezone);
      if (currentHour !== 21) continue;

      const todayMissions = await getTodayMissions(
        doc.id,
        getTodayDateString(user.timezone)
      );

      const completedCount = todayMissions.length;
      const remainingCount = 6 - completedCount;

      if (remainingCount > 0) {
        const bonusMessage =
          remainingCount <= 2
            ? " Você está perto do bônus de 100 XP!"
            : "";

        notifications.push(
          sendPushNotification(user.fcmToken, {
            title: "Resumo do dia 📊",
            body: `Você completou ${completedCount}/6 missões. Faltam ${remainingCount}!${bonusMessage}`,
            data: { type: "daily_summary" },
          })
        );
      }
    }

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} daily summaries`);
  });

/**
 * Streak warning notification (21:30 local time)
 */
export const sendStreakWarning = functions.pubsub
  .schedule("30 * * * *")
  .onRun(async () => {
    const usersSnapshot = await db
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .where("currentStreak", ">=", 3)
      .get();

    const notifications: Promise<boolean>[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data() as User;
      if (!user.fcmToken || !user.timezone) continue;

      const currentHour = getCurrentHourInTimezone(user.timezone);
      if (currentHour !== 21) continue; // 21:30

      const todayMissions = await getTodayMissions(
        doc.id,
        getTodayDateString(user.timezone)
      );

      // If no missions completed today, streak is at risk
      if (todayMissions.length === 0) {
        notifications.push(
          sendPushNotification(user.fcmToken, {
            title: "Seu streak está em risco! 🔥",
            body: `Você tem ${user.currentStreak} dias de streak. Complete uma missão para não perder!`,
            data: { type: "streak_warning" },
          })
        );
      }
    }

    await Promise.all(notifications);
    console.log(`Sent ${notifications.length} streak warnings`);
  });

/**
 * Weekly ranking reset (Sunday 23:59 UTC)
 */
export const resetWeeklyRanking = functions.pubsub
  .schedule("59 23 * * 0") // Sunday 23:59 UTC
  .timeZone("UTC")
  .onRun(async () => {
    const squadsSnapshot = await db.collection("squads").get();

    for (const squadDoc of squadsSnapshot.docs) {
      const squadCode = squadDoc.id;
      const currentWeekId = getWeekId();
      const rankingId = `${squadCode}_${currentWeekId}`;

      // Get current week's ranking
      const rankingRef = db.collection("weeklyRankings").doc(rankingId);
      const usersSnapshot = await rankingRef.collection("users").get();

      // Find winner
      let winner: { id: string; name: string; xp: number } | null = null;
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        if (!winner || userData.weeklyXP > winner.xp) {
          winner = {
            id: userDoc.id,
            name: userData.name,
            xp: userData.weeklyXP,
          };
        }
      }

      // Send winner notification
      if (winner) {
        const winnerRef = await db.collection("users").doc(winner.id).get();
        const winnerData = winnerRef.data() as User;
        if (winnerData?.fcmToken && winnerData?.notificationsEnabled) {
          await sendPushNotification(winnerData.fcmToken, {
            title: "Parabéns, Campeão! 🏆",
            body: `Você venceu o ranking semanal com ${winner.xp} XP!`,
            data: { type: "weekly_winner" },
          });
        }
      }

      // Create new week's ranking document
      const newWeekId = getWeekId(
        new Date(Date.now() + 24 * 60 * 60 * 1000)
      ); // Next week
      const newRankingId = `${squadCode}_${newWeekId}`;

      const now = new Date();
      const weekStart = new Date(now);
      weekStart.setUTCDate(now.getUTCDate() - now.getUTCDay() + 1); // Next Monday
      weekStart.setUTCHours(0, 0, 0, 0);

      const weekEnd = new Date(weekStart);
      weekEnd.setUTCDate(weekStart.getUTCDate() + 6);
      weekEnd.setUTCHours(23, 59, 59, 999);

      await db.collection("weeklyRankings").doc(newRankingId).set({
        squadCode,
        weekStart: admin.firestore.Timestamp.fromDate(weekStart),
        weekEnd: admin.firestore.Timestamp.fromDate(weekEnd),
      });
    }

    console.log(`Reset rankings for ${squadsSnapshot.size} squads`);
  });

// ============================================
// TRIGGER FUNCTIONS
// ============================================

/**
 * Update ranking when mission is completed
 */
export const onMissionCompleted = functions.firestore
  .document("missions/{missionId}")
  .onCreate(async (snap, context) => {
    const mission = snap.data();
    const userId = mission.userId;
    const squadCode = mission.squadCode;
    const xpEarned = mission.xpEarned;

    if (!squadCode) return;

    const weekId = getWeekId();
    const rankingId = `${squadCode}_${weekId}`;
    const userRankingRef = db
      .collection("weeklyRankings")
      .doc(rankingId)
      .collection("users")
      .doc(userId);

    // Get user data
    const userSnapshot = await db.collection("users").doc(userId).get();
    const userData = userSnapshot.data() as User;

    // Get today's missions for this user
    const todayMissions = await getTodayMissions(userId, mission.date);

    // Update ranking
    await userRankingRef.set(
      {
        name: userData.name,
        avatarUrl: userData.avatarUrl || null,
        weeklyXP: admin.firestore.FieldValue.increment(xpEarned),
        todayMissions,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Check for daily bonus (6/6 missions)
    if (todayMissions.length === 6) {
      const bonusXP = 100;

      // Update user total XP
      await db
        .collection("users")
        .doc(userId)
        .update({
          totalXP: admin.firestore.FieldValue.increment(bonusXP),
        });

      // Update ranking XP
      await userRankingRef.update({
        weeklyXP: admin.firestore.FieldValue.increment(bonusXP),
      });

      // Send notification
      if (userData.fcmToken && userData.notificationsEnabled) {
        await sendPushNotification(userData.fcmToken, {
          title: "Bônus diário! 🎉",
          body: "Você completou todas as missões e ganhou +100 XP de bônus!",
          data: { type: "daily_bonus", xp: "100" },
        });
      }
    }
  });

/**
 * Update user level when XP changes
 */
export const onUserXPChange = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data() as User;
    const after = change.after.data() as User;

    if (before.totalXP === after.totalXP) return;

    // Calculate new level
    const calculateLevel = (xp: number): number => {
      let level = 1;
      let xpNeeded = 500;
      let totalXPNeeded = 0;

      while (totalXPNeeded + xpNeeded <= xp) {
        totalXPNeeded += xpNeeded;
        level++;
        xpNeeded = level * 500;
      }

      return level;
    };

    const newLevel = calculateLevel(after.totalXP);

    if (newLevel > before.level) {
      // Level up!
      await change.after.ref.update({ level: newLevel });

      // Send notification
      if (after.fcmToken && after.notificationsEnabled) {
        await sendPushNotification(after.fcmToken, {
          title: "Level Up! ⬆️",
          body: `Parabéns! Você alcançou o nível ${newLevel}!`,
          data: { type: "level_up", level: newLevel.toString() },
        });
      }
    }
  });

/**
 * Update squad member count when user joins/leaves
 */
export const onUserSquadChange = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data() as User;
    const after = change.after.data() as User;

    if (before.squadCode === after.squadCode) return;

    // Left old squad
    if (before.squadCode) {
      const oldSquadRef = db.collection("squads").doc(before.squadCode);
      await oldSquadRef.update({
        memberCount: admin.firestore.FieldValue.increment(-1),
      });
    }

    // Joined new squad
    if (after.squadCode) {
      const newSquadRef = db.collection("squads").doc(after.squadCode);
      await newSquadRef.update({
        memberCount: admin.firestore.FieldValue.increment(1),
      });
    }
  });

/**
 * Clean up when user deletes account
 */
export const onUserDeleted = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    const userId = context.params.userId;
    const userData = snap.data() as User;

    // Remove from squad
    if (userData.squadCode) {
      const squadRef = db.collection("squads").doc(userData.squadCode);
      await squadRef.update({
        memberCount: admin.firestore.FieldValue.increment(-1),
      });
    }

    // Delete user's missions (optional - keeping for now as per MVP)
    // const missionsSnapshot = await db.collection('missions')
    //   .where('userId', '==', userId).get();
    // const batch = db.batch();
    // missionsSnapshot.docs.forEach(doc => batch.delete(doc.ref));
    // await batch.commit();

    // Delete user's ranking entries
    const rankingsSnapshot = await db.collectionGroup("users")
      .where(admin.firestore.FieldPath.documentId(), "==", userId)
      .get();

    const batch = db.batch();
    rankingsSnapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();

    console.log(`Cleaned up data for deleted user ${userId}`);
  });

// ============================================
// CALLABLE FUNCTIONS
// ============================================

/**
 * Send test notification (for development)
 */
export const sendTestNotification = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Must be authenticated"
      );
    }

    const userId = context.auth.uid;
    const userSnapshot = await db.collection("users").doc(userId).get();
    const userData = userSnapshot.data() as User;

    if (!userData?.fcmToken) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "No FCM token found"
      );
    }

    const success = await sendPushNotification(userData.fcmToken, {
      title: "Teste de notificação 🔔",
      body: "Se você está vendo isso, as notificações estão funcionando!",
      data: { type: "test" },
    });

    return { success };
  }
);
