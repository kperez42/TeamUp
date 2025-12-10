//
//  PersonalizedOnboardingManager.swift
//  TeamUp
//
//  Manages personalized onboarding paths based on gamer goals and preferences
//  Adapts the onboarding experience to match user gaming intentions
//

import Foundation
import SwiftUI

/// Manages personalized onboarding experiences based on gamer goals
@MainActor
class PersonalizedOnboardingManager: ObservableObject {

    static let shared = PersonalizedOnboardingManager()

    @Published var selectedGoal: GamerGoal?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum GamerGoal: String, Codable, CaseIterable {
        case findRankedTeammates = "find_ranked_teammates"
        case casualCoOp = "casual_coop"
        case competitiveTeam = "competitive_team"
        case boardGameGroup = "board_game_group"
        case dndGroup = "dnd_group"
        case streamingPartner = "streaming_partner"
        case esportsTeam = "esports_team"
        case gamingCommunity = "gaming_community"

        var displayName: String {
            switch self {
            case .findRankedTeammates: return "Find Ranked Teammates"
            case .casualCoOp: return "Casual Co-op Partners"
            case .competitiveTeam: return "Join Competitive Team"
            case .boardGameGroup: return "Board Game Group"
            case .dndGroup: return "D&D / Tabletop Group"
            case .streamingPartner: return "Streaming Partners"
            case .esportsTeam: return "Esports Team"
            case .gamingCommunity: return "Join Gaming Community"
            }
        }

        var icon: String {
            switch self {
            case .findRankedTeammates: return "trophy.fill"
            case .casualCoOp: return "gamecontroller.fill"
            case .competitiveTeam: return "person.3.fill"
            case .boardGameGroup: return "dice.fill"
            case .dndGroup: return "sparkles"
            case .streamingPartner: return "video.fill"
            case .esportsTeam: return "star.fill"
            case .gamingCommunity: return "bubble.left.and.bubble.right.fill"
            }
        }

        var description: String {
            switch self {
            case .findRankedTeammates:
                return "Climb the ranks with reliable teammates"
            case .casualCoOp:
                return "Chill gaming sessions, no pressure"
            case .competitiveTeam:
                return "Join or form a serious competitive squad"
            case .boardGameGroup:
                return "Find players for board games and card games"
            case .dndGroup:
                return "Find a party for tabletop RPG adventures"
            case .streamingPartner:
                return "Find collaborators for streaming content"
            case .esportsTeam:
                return "Join a professional esports organization"
            case .gamingCommunity:
                return "Connect with gamers who share your interests"
            }
        }

        var color: Color {
            switch self {
            case .findRankedTeammates: return .orange
            case .casualCoOp: return .green
            case .competitiveTeam: return .red
            case .boardGameGroup: return .purple
            case .dndGroup: return .indigo
            case .streamingPartner: return .pink
            case .esportsTeam: return .yellow
            case .gamingCommunity: return .cyan
            }
        }
    }

    // Legacy type alias for compatibility
    typealias DatingGoal = GamerGoal

    struct OnboardingPath {
        let goal: DatingGoal
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case profileDepth = "profile_depth"
            case photoQuality = "photo_quality"
            case bioOptimization = "bio_optimization"
            case interestMatching = "interest_matching"
            case locationAccuracy = "location_accuracy"
            case verificationTrust = "verification_trust"
        }
    }

    struct OnboardingPathStep {
        let id: String
        let title: String
        let description: String
        let importance: StepImportance
        let tips: [String]

        enum StepImportance {
            case critical
            case recommended
            case optional
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedGoal()
    }

    // MARK: - Goal Selection

    func selectGoal(_ goal: GamerGoal) {
        selectedGoal = goal
        recommendedPath = generatePath(for: goal)
        saveGoal()

        // Track analytics
        AnalyticsManager.shared.logEvent(.onboardingStepCompleted, parameters: [
            "step": "goal_selection",
            "goal": goal.rawValue,
            "goal_name": goal.displayName
        ])

        Logger.shared.info("User selected onboarding goal: \(goal.displayName)", category: .onboarding)
    }

    // MARK: - Path Generation

    private func generatePath(for goal: GamerGoal) -> OnboardingPath {
        switch goal {
        case .findRankedTeammates:
            return createRankedTeammatesPath()
        case .casualCoOp:
            return createCasualCoOpPath()
        case .competitiveTeam:
            return createCompetitiveTeamPath()
        case .boardGameGroup:
            return createBoardGamePath()
        case .dndGroup:
            return createDnDPath()
        case .streamingPartner:
            return createStreamingPath()
        case .esportsTeam:
            return createEsportsPath()
        case .gamingCommunity:
            return createCommunityPath()
        }
    }

    private func createRankedTeammatesPath() -> OnboardingPath {
        OnboardingPath(
            goal: .findRankedTeammates,
            steps: [
                OnboardingPathStep(
                    id: "gaming_profile",
                    title: "Set Up Your Gamer Profile",
                    description: "Show your competitive side and skill level",
                    importance: .critical,
                    tips: [
                        "Add your main games and current ranks",
                        "Share your peak ranks and achievements",
                        "Be honest about your skill level for better connections"
                    ]
                ),
                OnboardingPathStep(
                    id: "schedule_setup",
                    title: "Set Your Gaming Schedule",
                    description: "Find teammates who play when you do",
                    importance: .critical,
                    tips: [
                        "Add your typical gaming hours",
                        "Specify timezone for accurate matching",
                        "Mark preferred days for ranked sessions"
                    ]
                ),
                OnboardingPathStep(
                    id: "comms_setup",
                    title: "Communication Preferences",
                    description: "Voice chat is key for ranked play",
                    importance: .recommended,
                    tips: [
                        "Link your Discord for easy team comms",
                        "Specify if you prefer callouts or quiet focus",
                        "Add language preferences"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .interestMatching, .verificationTrust],
            recommendedFeatures: ["Rank Verification", "LFG Posts", "Squad Finder"],
            tutorialPriority: ["profile_quality", "matching", "squad_builder", "messaging"]
        )
    }

    private func createCasualCoOpPath() -> OnboardingPath {
        OnboardingPath(
            goal: .casualCoOp,
            steps: [
                OnboardingPathStep(
                    id: "casual_profile",
                    title: "Create Your Gamer Profile",
                    description: "Share what games you enjoy and your vibe",
                    importance: .critical,
                    tips: [
                        "List your favorite games to play",
                        "Add a profile pic or gaming avatar",
                        "Write a chill bio about your gaming style"
                    ]
                ),
                OnboardingPathStep(
                    id: "games_setup",
                    title: "Add Your Games",
                    description: "Help us find players with shared games",
                    importance: .recommended,
                    tips: [
                        "Select games you're currently playing",
                        "Include games you'd like to try with friends",
                        "Mark co-op favorites"
                    ]
                )
            ],
            focusAreas: [.interestMatching, .locationAccuracy, .bioOptimization],
            recommendedFeatures: ["Quick Match", "Game Sessions", "Party Finder"],
            tutorialPriority: ["scrolling", "matching", "messaging", "profile_quality"]
        )
    }

    private func createCompetitiveTeamPath() -> OnboardingPath {
        OnboardingPath(
            goal: .competitiveTeam,
            steps: [
                OnboardingPathStep(
                    id: "competitive_profile",
                    title: "Build Your Competitive Profile",
                    description: "Showcase your skills and experience",
                    importance: .critical,
                    tips: [
                        "Add detailed stats and achievements",
                        "List tournament experience if any",
                        "Highlight your best roles/positions"
                    ]
                ),
                OnboardingPathStep(
                    id: "availability",
                    title: "Set Your Commitment Level",
                    description: "Teams need to know your availability",
                    importance: .critical,
                    tips: [
                        "Specify practice schedule availability",
                        "Be clear about tournament availability",
                        "Mention if you're looking to go pro"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .interestMatching],
            recommendedFeatures: ["Team Finder", "Scrims", "Tournament LFT"],
            tutorialPriority: ["profile_quality", "matching", "team_features", "messaging"]
        )
    }

    private func createBoardGamePath() -> OnboardingPath {
        OnboardingPath(
            goal: .boardGameGroup,
            steps: [
                OnboardingPathStep(
                    id: "board_game_profile",
                    title: "Create Your Board Gamer Profile",
                    description: "Share your tabletop preferences",
                    importance: .critical,
                    tips: [
                        "List your favorite board games",
                        "Mention game complexity preferences",
                        "Add your BoardGameGeek profile if you have one"
                    ]
                ),
                OnboardingPathStep(
                    id: "location_setup",
                    title: "Set Your Location",
                    description: "Find local gaming groups",
                    importance: .critical,
                    tips: [
                        "Add your city for local connections",
                        "Specify if you host game nights",
                        "Mention preferred venues (home, FLGS, cafes)"
                    ]
                )
            ],
            focusAreas: [.locationAccuracy, .interestMatching, .bioOptimization],
            recommendedFeatures: ["Local Groups", "Game Night Events", "Board Game Library"],
            tutorialPriority: ["scrolling", "matching", "events", "messaging"]
        )
    }

    private func createDnDPath() -> OnboardingPath {
        OnboardingPath(
            goal: .dndGroup,
            steps: [
                OnboardingPathStep(
                    id: "ttrpg_profile",
                    title: "Create Your Adventurer Profile",
                    description: "Share your tabletop RPG experience",
                    importance: .critical,
                    tips: [
                        "List systems you play (D&D, Pathfinder, etc.)",
                        "Mention if you DM/GM or play",
                        "Share your favorite character types"
                    ]
                ),
                OnboardingPathStep(
                    id: "campaign_prefs",
                    title: "Set Campaign Preferences",
                    description: "Find the right party for you",
                    importance: .recommended,
                    tips: [
                        "Specify online vs in-person preference",
                        "Add schedule availability for sessions",
                        "Mention roleplay vs combat preference"
                    ]
                )
            ],
            focusAreas: [.interestMatching, .bioOptimization, .locationAccuracy],
            recommendedFeatures: ["Party Finder", "Campaign Listings", "Character Showcase"],
            tutorialPriority: ["profile_quality", "matching", "messaging", "party_finder"]
        )
    }

    private func createStreamingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .streamingPartner,
            steps: [
                OnboardingPathStep(
                    id: "content_profile",
                    title: "Set Up Your Creator Profile",
                    description: "Showcase your content and style",
                    importance: .critical,
                    tips: [
                        "Link your Twitch/YouTube channels",
                        "Describe your content style",
                        "Share your streaming schedule"
                    ]
                ),
                OnboardingPathStep(
                    id: "collab_prefs",
                    title: "Collaboration Preferences",
                    description: "Find the right collab partners",
                    importance: .recommended,
                    tips: [
                        "Specify types of collabs you're interested in",
                        "Add your average viewer count",
                        "Mention games you stream most"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .interestMatching],
            recommendedFeatures: ["Creator Verification", "Collab Finder", "Content Calendar"],
            tutorialPriority: ["profile_quality", "matching", "creator_tools", "messaging"]
        )
    }

    private func createEsportsPath() -> OnboardingPath {
        OnboardingPath(
            goal: .esportsTeam,
            steps: [
                OnboardingPathStep(
                    id: "esports_profile",
                    title: "Build Your Pro Profile",
                    description: "Showcase your competitive achievements",
                    importance: .critical,
                    tips: [
                        "Add verified ranks and stats",
                        "List tournament placings and teams",
                        "Include VODs or highlight clips"
                    ]
                ),
                OnboardingPathStep(
                    id: "tryout_availability",
                    title: "Set Tryout Availability",
                    description: "Let teams know when you can trial",
                    importance: .critical,
                    tips: [
                        "Specify your region for ping considerations",
                        "Add full-time availability",
                        "Mention salary/contract preferences"
                    ]
                )
            ],
            focusAreas: [.profileDepth, .verificationTrust, .interestMatching],
            recommendedFeatures: ["LFT Board", "Team Listings", "Stat Verification"],
            tutorialPriority: ["profile_quality", "team_features", "matching", "messaging"]
        )
    }

    private func createCommunityPath() -> OnboardingPath {
        OnboardingPath(
            goal: .gamingCommunity,
            steps: [
                OnboardingPathStep(
                    id: "community_profile",
                    title: "Create Your Gamer Profile",
                    description: "Share your gaming interests and personality",
                    importance: .critical,
                    tips: [
                        "Add your favorite games and genres",
                        "Share your gaming story",
                        "Upload a profile pic or avatar"
                    ]
                ),
                OnboardingPathStep(
                    id: "explore_communities",
                    title: "Find Your Communities",
                    description: "Connect with like-minded gamers",
                    importance: .recommended,
                    tips: [
                        "Browse game-specific channels",
                        "Join communities that match your interests",
                        "Start conversations with fellow gamers"
                    ]
                )
            ],
            focusAreas: [.interestMatching, .bioOptimization, .locationAccuracy],
            recommendedFeatures: ["Game Channels", "Community Events", "Group Chats"],
            tutorialPriority: ["scrolling", "matching", "communities", "messaging"]
        )
    }

    // MARK: - Customizations

    func getCustomTips() -> [String] {
        guard let path = recommendedPath else { return [] }
        return path.steps.flatMap { $0.tips }
    }

    func shouldEmphasize(focusArea: OnboardingPath.FocusArea) -> Bool {
        guard let path = recommendedPath else { return false }
        return path.focusAreas.contains(focusArea)
    }

    func getPrioritizedTutorials() -> [String] {
        guard let path = recommendedPath else {
            return ["welcome", "scrolling", "matching", "messaging"]
        }
        return path.tutorialPriority
    }

    func getRecommendedFeatures() -> [String] {
        return recommendedPath?.recommendedFeatures ?? []
    }

    // MARK: - Persistence

    private func saveGoal() {
        if let goal = selectedGoal,
           let encoded = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedGoal() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let goal = try? JSONDecoder().decode(GamerGoal.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.GamerGoal) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's your gaming goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us find the perfect squad for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.GamerGoal.allCases, id: \.self) { goal in
                        GoalCard(goal: goal, isSelected: manager.selectedGoal == goal) {
                            withAnimation(.spring(response: 0.3)) {
                                manager.selectGoal(goal)
                                HapticManager.shared.selection()
                            }
                        }
                    }
                }
                .padding(24)
            }

            // Continue Button
            if manager.selectedGoal != nil {
                Button {
                    if let goal = manager.selectedGoal {
                        onGoalSelected(goal)
                    }
                    dismiss()
                } label: {
                    HStack {
                        Text("Let's Go!")
                            .fontWeight(.semibold)

                        Image(systemName: "gamecontroller.fill")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.green, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .transition(.opacity)
            }
        }
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.05), Color.cyan.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

struct GoalCard: View {
    let goal: PersonalizedOnboardingManager.GamerGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(goal.color.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: goal.icon)
                            .font(.title2)
                            .foregroundColor(goal.color)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(goal.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? goal.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? goal.color.opacity(0.2) : .clear, radius: 8, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingGoalSelectionView { goal in
        print("Selected goal: \(goal.displayName)")
    }
}
