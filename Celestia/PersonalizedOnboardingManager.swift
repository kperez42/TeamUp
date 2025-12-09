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

    @Published var selectedGoal: GamerGoalType?
    @Published var recommendedPath: OnboardingPath?
    @Published var customizations: [String: Any] = [:]

    private let userDefaultsKey = "selected_onboarding_goal"

    // MARK: - Models

    enum GamerGoalType: String, Codable, CaseIterable {
        case rankedTeammates = "ranked_teammates"
        case casualGaming = "casual_gaming"
        case competitiveTeam = "competitive_team"
        case tabletopGroup = "tabletop_group"
        case streamingCollab = "streaming_collab"
        case gamingCommunity = "gaming_community"

        var displayName: String {
            switch self {
            case .rankedTeammates: return "Find Ranked Teammates"
            case .casualGaming: return "Casual Co-op Gaming"
            case .competitiveTeam: return "Build a Competitive Team"
            case .tabletopGroup: return "Tabletop / D&D Group"
            case .streamingCollab: return "Streaming & Content"
            case .gamingCommunity: return "Join Gaming Community"
            }
        }

        var icon: String {
            switch self {
            case .rankedTeammates: return "chart.bar.fill"
            case .casualGaming: return "gamecontroller"
            case .competitiveTeam: return "trophy.fill"
            case .tabletopGroup: return "dice"
            case .streamingCollab: return "video.fill"
            case .gamingCommunity: return "person.3.fill"
            }
        }

        var description: String {
            switch self {
            case .rankedTeammates:
                return "Climb the ranks with skilled teammates"
            case .casualGaming:
                return "Chill gaming sessions, no pressure"
            case .competitiveTeam:
                return "Form a team for tournaments & scrims"
            case .tabletopGroup:
                return "Find players for D&D, board games & more"
            case .streamingCollab:
                return "Create content with other gamers"
            case .gamingCommunity:
                return "Find your gaming family"
            }
        }

        var color: Color {
            switch self {
            case .rankedTeammates: return .orange
            case .casualGaming: return .green
            case .competitiveTeam: return .red
            case .tabletopGroup: return .indigo
            case .streamingCollab: return .cyan
            case .gamingCommunity: return .blue
            }
        }
    }

    struct OnboardingPath {
        let goal: GamerGoalType
        let steps: [OnboardingPathStep]
        let focusAreas: [FocusArea]
        let recommendedFeatures: [String]
        let tutorialPriority: [String] // Tutorial IDs in priority order

        enum FocusArea: String {
            case gameSelection = "game_selection"
            case platformSetup = "platform_setup"
            case skillShowcase = "skill_showcase"
            case scheduleSetup = "schedule_setup"
            case profileOptimization = "profile_optimization"
            case voiceChatSetup = "voice_chat_setup"
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

    func selectGoal(_ goal: GamerGoalType) {
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

    private func generatePath(for goal: GamerGoalType) -> OnboardingPath {
        switch goal {
        case .rankedTeammates:
            return createRankedTeammatesPath()
        case .casualGaming:
            return createCasualGamingPath()
        case .competitiveTeam:
            return createCompetitiveTeamPath()
        case .tabletopGroup:
            return createTabletopGroupPath()
        case .streamingCollab:
            return createStreamingCollabPath()
        case .gamingCommunity:
            return createGamingCommunityPath()
        }
    }

    private func createRankedTeammatesPath() -> OnboardingPath {
        OnboardingPath(
            goal: .rankedTeammates,
            steps: [
                OnboardingPathStep(
                    id: "games_and_ranks",
                    title: "Add Your Games & Ranks",
                    description: "Show your competitive stats and ranks",
                    importance: .critical,
                    tips: [
                        "Add your main competitive games",
                        "Include your current rank in each game",
                        "Link your gaming accounts for verification"
                    ]
                ),
                OnboardingPathStep(
                    id: "platform_setup",
                    title: "Set Up Your Platforms",
                    description: "Connect your gaming accounts",
                    importance: .critical,
                    tips: [
                        "Link Steam, PSN, Xbox, or other accounts",
                        "Add your Discord for voice comms",
                        "Verified accounts get more teammate requests"
                    ]
                ),
                OnboardingPathStep(
                    id: "schedule_availability",
                    title: "Set Your Gaming Schedule",
                    description: "Let teammates know when you're online",
                    importance: .recommended,
                    tips: [
                        "Set your typical gaming hours",
                        "Include your timezone",
                        "Better schedule matches = better teammates"
                    ]
                )
            ],
            focusAreas: [.gameSelection, .skillShowcase, .scheduleSetup, .voiceChatSetup],
            recommendedFeatures: ["Rank Verification", "Stats Sync", "Voice Chat"],
            tutorialPriority: ["games_setup", "matching", "messaging", "squad_features"]
        )
    }

    private func createCasualGamingPath() -> OnboardingPath {
        OnboardingPath(
            goal: .casualGaming,
            steps: [
                OnboardingPathStep(
                    id: "favorite_games",
                    title: "Add Your Favorite Games",
                    description: "What do you love to play?",
                    importance: .critical,
                    tips: [
                        "Add games you enjoy playing",
                        "Include different genres you like",
                        "More games = more potential teammates"
                    ]
                ),
                OnboardingPathStep(
                    id: "play_style",
                    title: "Share Your Play Style",
                    description: "Help us find compatible gamers",
                    importance: .recommended,
                    tips: [
                        "Are you competitive or chill?",
                        "Do you prefer voice chat or text?",
                        "What times do you usually play?"
                    ]
                )
            ],
            focusAreas: [.gameSelection, .profileOptimization, .scheduleSetup],
            recommendedFeatures: ["Quick Match", "LFG Posts", "Game Channels"],
            tutorialPriority: ["discovery", "matching", "messaging", "profile"]
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
                        "Add your competitive game history",
                        "Include tournament experience if any",
                        "Show your best ranks and achievements"
                    ]
                ),
                OnboardingPathStep(
                    id: "verify_skills",
                    title: "Verify Your Gaming Accounts",
                    description: "Prove your skills with linked accounts",
                    importance: .critical,
                    tips: [
                        "Verified accounts attract serious teammates",
                        "Link your main gaming platform",
                        "Stats sync shows your true skill level"
                    ]
                ),
                OnboardingPathStep(
                    id: "team_preferences",
                    title: "Set Team Preferences",
                    description: "What kind of team are you looking for?",
                    importance: .recommended,
                    tips: [
                        "Specify your role preferences",
                        "Set your practice schedule availability",
                        "Mention your tournament goals"
                    ]
                )
            ],
            focusAreas: [.skillShowcase, .platformSetup, .scheduleSetup, .voiceChatSetup],
            recommendedFeatures: ["Team Builder", "Scrim Finder", "Tournament Hub"],
            tutorialPriority: ["competitive_features", "team_matching", "messaging", "scrims"]
        )
    }

    private func createTabletopGroupPath() -> OnboardingPath {
        OnboardingPath(
            goal: .tabletopGroup,
            steps: [
                OnboardingPathStep(
                    id: "tabletop_games",
                    title: "Add Your Tabletop Games",
                    description: "D&D, board games, card games & more",
                    importance: .critical,
                    tips: [
                        "List your favorite tabletop games",
                        "Mention if you're a GM/DM",
                        "Include experience level for each game"
                    ]
                ),
                OnboardingPathStep(
                    id: "play_format",
                    title: "Set Your Preferences",
                    description: "In-person, online, or both?",
                    importance: .critical,
                    tips: [
                        "Choose online (Roll20, VTT) or local",
                        "Set your location for in-person games",
                        "Add your typical session availability"
                    ]
                ),
                OnboardingPathStep(
                    id: "player_style",
                    title: "Describe Your Play Style",
                    description: "Roleplay heavy, combat focused, or balanced?",
                    importance: .recommended,
                    tips: [
                        "Share your preferred campaign style",
                        "Mention favorite characters/classes",
                        "Be clear about session expectations"
                    ]
                )
            ],
            focusAreas: [.gameSelection, .scheduleSetup, .profileOptimization],
            recommendedFeatures: ["Campaign Finder", "Group Builder", "Session Scheduler"],
            tutorialPriority: ["tabletop_features", "group_matching", "messaging", "scheduling"]
        )
    }

    private func createStreamingCollabPath() -> OnboardingPath {
        OnboardingPath(
            goal: .streamingCollab,
            steps: [
                OnboardingPathStep(
                    id: "content_profile",
                    title: "Set Up Your Creator Profile",
                    description: "Showcase your content and channels",
                    importance: .critical,
                    tips: [
                        "Link your Twitch, YouTube, TikTok",
                        "Share your content style and niche",
                        "Add your viewer/subscriber counts"
                    ]
                ),
                OnboardingPathStep(
                    id: "collab_preferences",
                    title: "Set Collaboration Preferences",
                    description: "What kind of collabs are you looking for?",
                    importance: .critical,
                    tips: [
                        "Specify collab types (co-streams, videos)",
                        "Share your content schedule",
                        "Mention your audience demographics"
                    ]
                ),
                OnboardingPathStep(
                    id: "games_content",
                    title: "Add Your Content Games",
                    description: "What games do you create content for?",
                    importance: .recommended,
                    tips: [
                        "List games you stream/record",
                        "Mention game genres you cover",
                        "Share content goals"
                    ]
                )
            ],
            focusAreas: [.platformSetup, .profileOptimization, .scheduleSetup],
            recommendedFeatures: ["Creator Matching", "Collab Scheduler", "Content Hub"],
            tutorialPriority: ["creator_features", "collab_matching", "messaging", "scheduling"]
        )
    }

    private func createGamingCommunityPath() -> OnboardingPath {
        OnboardingPath(
            goal: .gamingCommunity,
            steps: [
                OnboardingPathStep(
                    id: "gamer_profile",
                    title: "Create Your Gamer Profile",
                    description: "Show who you are as a gamer",
                    importance: .critical,
                    tips: [
                        "Add your favorite games",
                        "Share your gaming history",
                        "Be authentic - find your people!"
                    ]
                ),
                OnboardingPathStep(
                    id: "community_interests",
                    title: "Set Your Interests",
                    description: "What gaming communities interest you?",
                    importance: .recommended,
                    tips: [
                        "Select game genres you enjoy",
                        "Choose your preferred platforms",
                        "Mention what you're looking for in a community"
                    ]
                )
            ],
            focusAreas: [.gameSelection, .profileOptimization, .scheduleSetup],
            recommendedFeatures: ["Community Finder", "Game Channels", "Events"],
            tutorialPriority: ["discovery", "communities", "messaging", "events"]
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
            return ["welcome", "discovery", "matching", "messaging"]
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
           let goal = try? JSONDecoder().decode(GamerGoalType.self, from: data) {
            selectedGoal = goal
            recommendedPath = generatePath(for: goal)
        }
    }
}

// MARK: - SwiftUI View for Goal Selection

struct OnboardingGoalSelectionView: View {
    @ObservedObject var manager = PersonalizedOnboardingManager.shared
    @Environment(\.dismiss) var dismiss

    let onGoalSelected: (PersonalizedOnboardingManager.GamerGoalType) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("What's your gaming goal?")
                    .font(.title)
                    .fontWeight(.bold)

                Text("This helps us find the right teammates for you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)

            // Goal Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PersonalizedOnboardingManager.GamerGoalType.allCases, id: \.self) { goal in
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
                        Text("Let's Go")
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
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
    let goal: PersonalizedOnboardingManager.GamerGoalType
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
