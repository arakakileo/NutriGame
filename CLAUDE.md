# CLAUDE.md - NutriGame (AppNutricionista)

## Visão Geral

App iOS nativo de **gamificação nutricional** para engajar pacientes de nutricionistas no cumprimento de suas dietas através de mecânicas de jogos (XP, Níveis, Streaks) e competição social (Squads/Rankings).

**Nome do App**: NutriGame
**Versão**: MVP 1.0
**Plataforma**: iOS Nativo (iPhone only)
**Backend**: Firebase
**Idioma**: Português (Brasil)
**Dark Mode**: Suportado

---

## Tech Stack

### Mobile (Front-end)
- **Linguagem**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Arquitetura**: MVVM
- **Minimum iOS**: 17.0
- **Device**: iPhone only (não iPad)

### Backend / Infraestrutura (Firebase)
- **Authentication**: Sign in with Apple, Google, Email/Senha
- **Firestore**: Banco de dados NoSQL
- **Storage**: Armazenamento de fotos de refeições
- **Analytics**: Firebase Analytics
- **Cloud Messaging**: Push notifications
- **Cloud Functions**: Agendamento de notificações

---

## Comandos de Desenvolvimento

```bash
cd AppNutricionista/NutriGame

# Abrir projeto no Xcode
open NutriGame.xcodeproj

# Instalar dependências (SPM via terminal)
xcodebuild -resolvePackageDependencies

# Build para simulador
xcodebuild -scheme NutriGame -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Rodar testes
xcodebuild test -scheme NutriGame -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

---

## Estrutura do Projeto

```
NutriGame/
├── App/
│   ├── NutriGameApp.swift              # Entry point
│   └── AppDelegate.swift               # Firebase config
├── Core/
│   ├── Authentication/
│   │   ├── AuthService.swift
│   │   ├── AuthViewModel.swift
│   │   └── Views/
│   │       ├── LoginView.swift
│   │       ├── SignUpView.swift
│   │       └── SocialLoginButtons.swift
│   ├── Navigation/
│   │   ├── AppRouter.swift
│   │   ├── MainTabView.swift
│   │   └── NavigationState.swift
│   └── Extensions/
│       ├── Color+Extensions.swift
│       ├── Date+Extensions.swift
│       ├── View+Extensions.swift
│       └── String+Extensions.swift
├── Features/
│   ├── Onboarding/
│   │   ├── Views/
│   │   │   ├── OnboardingView.swift
│   │   │   ├── OnboardingPageView.swift
│   │   │   └── SquadCodeInputView.swift
│   │   └── ViewModels/
│   │       └── OnboardingViewModel.swift
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── XPHeaderView.swift
│   │   │   ├── StreakBadgeView.swift
│   │   │   └── LevelProgressView.swift
│   │   ├── ViewModels/
│   │   │   └── HomeViewModel.swift
│   │   └── Components/
│   │       ├── StatsCard.swift
│   │       └── DailyProgressRing.swift
│   ├── Missions/
│   │   ├── Views/
│   │   │   ├── MissionsListView.swift
│   │   │   ├── MissionCardView.swift
│   │   │   ├── CameraView.swift
│   │   │   ├── PhotoConfirmationView.swift
│   │   │   └── HydrationCounterView.swift
│   │   ├── ViewModels/
│   │   │   ├── MissionsViewModel.swift
│   │   │   └── CameraViewModel.swift
│   │   └── Components/
│   │       ├── MissionCheckButton.swift
│   │       ├── XPGainAnimation.swift
│   │       └── ConfettiView.swift
│   ├── Ranking/
│   │   ├── Views/
│   │   │   ├── RankingView.swift
│   │   │   ├── RankingRowView.swift
│   │   │   └── RankingHeaderView.swift
│   │   ├── ViewModels/
│   │   │   └── RankingViewModel.swift
│   │   └── Components/
│   │       ├── PositionBadge.swift
│   │       └── TodayMissionsIndicator.swift
│   ├── Profile/
│   │   ├── Views/
│   │   │   ├── ProfileView.swift
│   │   │   ├── EditProfileView.swift
│   │   │   ├── PhotoGalleryView.swift
│   │   │   └── SettingsView.swift
│   │   ├── ViewModels/
│   │   │   ├── ProfileViewModel.swift
│   │   │   └── GalleryViewModel.swift
│   │   └── Components/
│   │       ├── ProfileHeader.swift
│   │       ├── StatsGrid.swift
│   │       └── PhotoGridItem.swift
│   └── Squad/
│       ├── Views/
│       │   ├── CreateSquadView.swift
│       │   ├── SquadDetailsView.swift
│       │   └── LeaveSquadConfirmation.swift
│       └── ViewModels/
│           └── SquadViewModel.swift
├── Models/
│   ├── User.swift
│   ├── Squad.swift
│   ├── Mission.swift
│   ├── MissionType.swift
│   ├── WeeklyRanking.swift
│   └── PremiumFeature.swift
├── Services/
│   ├── Firebase/
│   │   ├── FirebaseService.swift
│   │   ├── AuthService.swift
│   │   ├── UserService.swift
│   │   ├── MissionService.swift
│   │   ├── SquadService.swift
│   │   ├── RankingService.swift
│   │   └── StorageService.swift
│   ├── Notifications/
│   │   ├── NotificationService.swift
│   │   └── NotificationScheduler.swift
│   └── Camera/
│       ├── CameraService.swift
│       └── ImageCompressor.swift
├── Design/
│   ├── Theme/
│   │   ├── AppTheme.swift
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── Spacing.swift
│   └── Components/
│       ├── Buttons/
│       │   ├── PrimaryButton.swift
│       │   ├── SecondaryButton.swift
│       │   └── IconButton.swift
│       ├── Cards/
│       │   └── BaseCard.swift
│       ├── Inputs/
│       │   ├── CustomTextField.swift
│       │   └── CodeInputField.swift
│       ├── Feedback/
│       │   ├── LoadingView.swift
│       │   ├── ErrorView.swift
│       │   ├── EmptyStateView.swift
│       │   └── ToastView.swift
│       └── Animations/
│           ├── ShimmerEffect.swift
│           ├── PulseAnimation.swift
│           └── ConfettiEffect.swift
├── Resources/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   └── Images/
│   ├── Localizable.strings          # PT-BR
│   └── GoogleService-Info.plist     # (não commitar)
└── Utils/
    ├── Constants.swift
    ├── Validators.swift
    ├── DateFormatter+Utils.swift
    └── HapticManager.swift
```

---

## Modelo de Dados (Firestore)

### Collections

```javascript
// users/{userId}
{
  name: string,
  email: string,
  avatarUrl: string | null,
  squadCode: string | null,
  level: number,                    // default: 1
  totalXP: number,                  // default: 0
  currentStreak: number,            // default: 0
  longestStreak: number,            // default: 0
  lastCompletedDate: timestamp | null,
  createdAt: timestamp,
  isNutritionist: boolean,          // default: false
  fcmToken: string | null,          // push notifications
  timezone: string,                 // ex: "America/Sao_Paulo"
  notificationsEnabled: boolean,    // default: true

  // Preparado para monetização futura
  isPremium: boolean,               // default: false
  premiumUntil: timestamp | null,
  premiumFeatures: string[]         // features desbloqueadas
}

// squads/{squadCode}
{
  name: string,
  ownerUserId: string,
  code: string,                     // 6 chars, uppercase alfanumérico
  memberCount: number,
  maxMembers: number,               // default: 100
  createdAt: timestamp,

  // Preparado para monetização futura
  isPremium: boolean,               // default: false
  premiumFeatures: string[]
}

// missions/{missionId}
{
  odaj5erId: string,
  squadCode: string,
  type: "breakfast" | "lunch" | "dinner" | "snack" | "workout" | "hydration",
  photoUrl: string | null,
  waterCount: number | null,        // 0-5, apenas para hydration
  xpEarned: number,
  completedAt: timestamp,
  date: string                      // "YYYY-MM-DD"
}

// weeklyRankings/{squadCode}_{weekId}
{
  squadCode: string,
  weekStart: timestamp,
  weekEnd: timestamp,

  // subcollection: users/{userId}
  users: {
    name: string,
    avatarUrl: string | null,
    weeklyXP: number,
    todayMissions: string[],        // tipos completados hoje
    lastUpdated: timestamp
  }
}

// premiumPlans/{planId} - Para monetização futura
{
  name: string,
  price: number,
  currency: "BRL",
  duration: "monthly" | "yearly",
  features: string[],
  isActive: boolean
}
```

---

## Sistema de Pontuação (XP)

| Ação | XP |
|------|-----|
| Missão com foto (refeição/treino) | 50 XP |
| Copo de água (cada, max 5) | 10 XP |
| Daily Bonus (6/6 missões) | +100 XP |
| **Máximo diário** | **400 XP** |

### Fórmula de Níveis

```swift
// XP necessário para atingir o nível N
func xpRequiredForLevel(_ level: Int) -> Int {
    return level * 500  // Lvl 2 = 500, Lvl 3 = 1000, etc.
}

// XP total acumulado até o nível N
func totalXPForLevel(_ level: Int) -> Int {
    return (level * (level + 1) / 2) * 500
}
```

### Regras de Streak

| Regra | Definição |
|-------|-----------|
| **Mínimo para manter** | 1 missão qualquer no dia |
| **Timezone** | Local do dispositivo (`TimeZone.current`) |
| **Reset** | Meia-noite local sem nenhuma missão |
| **Streak freeze** | Não disponível no MVP |

### Reset do Ranking Semanal

| Regra | Definição |
|-------|-----------|
| **Quando** | Domingo 23:59 UTC |
| **Histórico** | Não mantido no MVP |
| **WeekId format** | `YYYY-WW` (ex: "2024-48") |

---

## Regras de Negócio

### Squads

| Regra | Definição |
|-------|-----------|
| **Código** | 6 caracteres alfanuméricos, uppercase |
| **Case sensitive** | Não (converter para uppercase) |
| **Limite membros** | 100 por squad |
| **Trocar de squad** | Permitido. XP total mantido, ranking zerado no novo squad |
| **Sair do squad** | Permitido com confirmação |
| **Deletar squad** | Apenas owner. Membros ficam sem squad |

### Fotos

| Regra | Definição |
|-------|-----------|
| **Compressão** | JPEG quality 0.7 |
| **Tamanho máximo** | 500KB após compressão |
| **Resolução** | Max 1080px no lado maior |
| **Deletar** | Não permitido no MVP |
| **Validação** | Honor system (sem IA) |

### Perfil

| Ação | Permitido |
|------|-----------|
| Editar nome | Sim |
| Editar foto | Sim |
| Sair do squad | Sim (com confirmação) |
| Deletar conta | Sim (obrigatório App Store) |

---

## Notificações Push

### Horários Padrão

| Horário | Mensagem |
|---------|----------|
| 09:00 | "Bom dia! Registre seu café da manhã" |
| 13:00 | "Hora do almoço! Não esqueça de registrar" |
| 19:00 | "Hora do jantar! Complete sua missão" |
| 21:00 | "Você completou X/6 missões. Faltam Y para o bônus!" |
| 21:30 (se streak > 3) | "Seu streak de X dias está em risco!" |

### Implementação

- **Firebase Cloud Messaging (FCM)** para delivery
- **Cloud Functions** para agendamento baseado em timezone do usuário
- Usuário pode desabilitar nas configurações

---

## Onboarding Flow

```
┌─────────────────────────────────────────────────────────┐
│  1. Splash Screen (2s)                                  │
│     └─→ Check auth state                                │
├─────────────────────────────────────────────────────────┤
│  2. Se não logado → Login Screen                        │
│     ├─ Sign in with Apple                               │
│     ├─ Sign in with Google                              │
│     └─ Email/Senha                                      │
├─────────────────────────────────────────────────────────┤
│  3. Se novo usuário → Onboarding Tutorial (3 telas)     │
│     ├─ "Complete missões diárias para ganhar XP"        │
│     ├─ "Suba no ranking do seu squad"                   │
│     └─ "Mantenha seu streak para bônus"                 │
├─────────────────────────────────────────────────────────┤
│  4. Squad Code Input                                    │
│     ├─ Campo para inserir código                        │
│     ├─ OU "Sou Nutricionista" → Criar Squad             │
│     └─ Validação: código inválido = erro amigável       │
├─────────────────────────────────────────────────────────┤
│  5. Home Dashboard                                      │
└─────────────────────────────────────────────────────────┘
```

---

## Design System

### Paleta de Cores

```swift
// Colors.swift - Suporte a Dark Mode
extension Color {
    // Background (adapta automaticamente)
    static let bgPrimary = Color(.systemBackground)
    static let bgSecondary = Color(.secondarySystemBackground)
    static let bgTertiary = Color(.tertiarySystemBackground)

    // Accent/Gamification (fixos)
    static let accentGreen = Color(hex: "#00E676")    // Verde Neon - XP, sucesso
    static let accentPurple = Color(hex: "#7C4DFF")   // Roxo Elétrico - Níveis
    static let accentOrange = Color(hex: "#FF6D00")   // Laranja Vivo - Streak/Fogo

    // Missões
    static let missionBreakfast = Color(hex: "#FFB74D")  // Laranja claro
    static let missionLunch = Color(hex: "#81C784")      // Verde
    static let missionDinner = Color(hex: "#7986CB")     // Azul/Roxo
    static let missionSnack = Color(hex: "#F06292")      // Rosa
    static let missionWorkout = Color(hex: "#4FC3F7")    // Azul claro
    static let missionWater = Color(hex: "#4DD0E1")      // Cyan

    // Status
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FFC107")
    static let error = Color(hex: "#F44336")

    // Text (adapta automaticamente)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
}
```

### Tipografia

```swift
// Typography.swift
extension Font {
    // Títulos
    static let titleLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let titleMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let titleSmall = Font.system(size: 22, weight: .semibold, design: .rounded)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // Números/XP (destaque)
    static let xpLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let xpMedium = Font.system(size: 24, weight: .bold, design: .rounded)
    static let xpSmall = Font.system(size: 18, weight: .semibold, design: .rounded)

    // Labels
    static let caption = Font.system(size: 12, weight: .medium)
    static let overline = Font.system(size: 10, weight: .semibold).uppercaseSmallCaps()
}
```

### Spacing & Sizing

```swift
// Spacing.swift
enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 24
    static let full: CGFloat = 9999
}
```

### Animações

| Elemento | Tipo | Duração |
|----------|------|---------|
| XP gain | Scale + fade in | 0.3s |
| Level up | Confetti + pulse | 1.5s |
| Mission complete | Checkmark + haptic | 0.25s |
| Streak increment | Fire pulse | 0.5s |
| Progress bar | Spring animation | 0.4s |

---

## Regras de Segurança Firebase

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Função helper para verificar mesmo squad
    function isSameSquad(squadCode) {
      return request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.squadCode == squadCode;
    }

    // Usuários
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }

    // Squads
    match /squads/{squadCode} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.ownerUserId;
      allow delete: if request.auth.uid == resource.data.ownerUserId;
    }

    // Missões
    match /missions/{missionId} {
      allow read: if isSameSquad(resource.data.squadCode);
      allow create: if request.auth.uid == request.resource.data.userId;
      allow update: if request.auth.uid == resource.data.userId;
      allow delete: if false; // Não permitir delete no MVP
    }

    // Rankings semanais
    match /weeklyRankings/{rankingId} {
      allow read: if request.auth != null;

      match /users/{rankUserId} {
        allow read: if request.auth != null;
        allow write: if request.auth.uid == rankUserId;
      }
    }

    // Planos premium (futuro)
    match /premiumPlans/{planId} {
      allow read: if request.auth != null;
      allow write: if false; // Apenas admin via console
    }
  }
}
```

---

## Dependências (Swift Package Manager)

```swift
// Dependências principais
dependencies: [
    // Firebase
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    // Products: FirebaseAuth, FirebaseFirestore, FirebaseStorage, FirebaseAnalytics, FirebaseMessaging
]
```

---

## Arquivos Sensíveis (.gitignore)

```gitignore
# Firebase
GoogleService-Info.plist

# Xcode
*.xcuserstate
xcuserdata/
DerivedData/
*.xcworkspace/xcuserdata/

# Secrets
*.secret
.env
Secrets.swift

# OS
.DS_Store
Thumbs.db

# Build
build/
*.ipa
*.dSYM.zip
```

---

## Preparação para Monetização

### Features Premium Planejadas (Pós-MVP)

| Feature | Descrição | Usuário |
|---------|-----------|---------|
| Histórico completo | Rankings de semanas anteriores | Paciente |
| Estatísticas avançadas | Gráficos de evolução, tendências | Paciente |
| Squad ilimitado | Mais de 100 membros | Nutricionista |
| Múltiplos squads | Gerenciar vários grupos | Nutricionista |
| Missões customizadas | Criar próprias missões | Nutricionista |
| Export de dados | Relatórios em PDF | Nutricionista |
| Remoção de anúncios | Experiência sem ads | Ambos |

### Implementação Preparatória

1. **Campos no modelo** já incluem `isPremium`, `premiumFeatures`
2. **Feature flags** podem ser controladas via Firebase Remote Config
3. **Coleção `premiumPlans`** pronta para cadastro de planos
4. **Estrutura modular** permite adicionar features sem refatoração

---

## Out of Scope (MVP)

- Painel Web administrativo
- Chat/mensagens diretas
- Personalização de dieta
- Avatar 3D / loja de itens
- Integração Apple Health/Watch
- Modo offline
- Histórico de rankings anteriores
- Múltiplos squads por nutricionista

---

## Roadmap

### Fase 1 - MVP (Atual)
- [x] Definição de escopo
- [x] Documentação técnica
- [ ] Setup projeto Xcode
- [ ] Configurar Firebase
- [ ] Implementar autenticação
- [ ] Criar UI do Onboarding
- [ ] Implementar Home Dashboard
- [ ] Sistema de Missões + Câmera
- [ ] Ranking do Squad
- [ ] Perfil + Galeria
- [ ] Notificações Push
- [ ] Animações e polish
- [ ] Testes
- [ ] Submit App Store

### Fase 2 - Melhorias
- [ ] Modo offline com sync
- [ ] Integração Apple Health
- [ ] Estatísticas avançadas

### Fase 3 - Monetização
- [ ] Sistema de assinaturas
- [ ] Features premium
- [ ] Painel web para nutricionistas

---

## Considerações de Performance

| Área | Estratégia |
|------|------------|
| **Imagens** | Compressão JPEG 0.7, max 1080px, cache com URLCache |
| **Ranking** | Paginação de 50 usuários, lazy loading |
| **Firestore** | Índices compostos para queries de ranking |
| **Animações** | Usar `withAnimation` e evitar redraws desnecessários |
| **Memory** | Liberar imagens não visíveis na galeria |
