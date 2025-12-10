//
//  UserDetailView.swift
//  GamerLink
//
//  Detailed view of a gamer's profile
//

import SwiftUI

struct UserDetailView: View {
    let user: User
    let initialIsRequested: Bool
    var onRequestChanged: ((Bool) -> Void)?  // Callback to sync request state with parent

    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var showingRequestSent = false
    @State private var showingConnected = false
    @State private var showingUnrequested = false
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isSaved = false
    @State private var isSavingProfile = false
    @State private var isRequested = false
    @State private var showingChat = false
    @State private var chatMatch: Match?
    @State private var showPremiumUpgrade = false
    @State private var upgradeContextMessage = ""
    @ObservedObject private var savedProfilesVM = SavedProfilesViewModel.shared

    // Photo viewer state
    @State private var selectedPhotoIndex: Int = 0
    @State private var showFullScreenPhotos = false

    init(user: User, initialIsRequested: Bool = false, onRequestChanged: ((Bool) -> Void)? = nil) {
        self.user = user
        self.initialIsRequested = initialIsRequested
        self.onRequestChanged = onRequestChanged
    }

    // Filter out empty photo URLs
    private var validPhotos: [String] {
        let photos = user.photos.isEmpty ? [user.profileImageURL] : user.photos
        return photos.filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                photosCarousel
                profileContent
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            actionButtons
        }
        .task {
            ImageCache.shared.prefetchAdjacentPhotos(photos: validPhotos, currentIndex: selectedPhotoIndex)
        }
        .onAppear(perform: handleOnAppear)
        .onChange(of: savedProfilesVM.savedProfiles) { _ in
            isSaved = savedProfilesVM.savedProfiles.contains(where: { $0.user.effectiveId == user.effectiveId })
        }
        .alert("Request Sent!", isPresented: $showingRequestSent) {
            Button("OK") { dismiss() }
        } message: {
            Text("If \(user.gamerTag.isEmpty ? user.fullName : user.gamerTag) accepts, you'll be connected!")
        }
        .alert("Connected!", isPresented: $showingConnected) {
            Button("Send Message") {
                NotificationCenter.default.post(
                    name: .navigateToMessages,
                    object: nil,
                    userInfo: ["matchedUserId": user.id as Any]
                )
                dismiss()
            }
            Button("Keep Browsing") { dismiss() }
        } message: {
            Text("You and \(user.gamerTag.isEmpty ? user.fullName : user.gamerTag) are now gaming buddies!")
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage.isEmpty ? "Failed to send request. Please try again." : errorMessage)
        }
        .alert("Request Cancelled", isPresented: $showingUnrequested) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You cancelled your request to \(user.gamerTag.isEmpty ? user.fullName : user.gamerTag)")
        }
        .sheet(isPresented: $showingChat) {
            if let match = chatMatch {
                NavigationStack {
                    ChatView(match: match, otherUser: user)
                        .environmentObject(authService)
                }
            }
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView(contextMessage: upgradeContextMessage)
                .environmentObject(authService)
        }
    }

    // MARK: - Photos Carousel

    private var photosCarousel: some View {
        TabView(selection: $selectedPhotoIndex) {
            ForEach(Array(validPhotos.enumerated()), id: \.offset) { index, photoURL in
                CachedCardImage(
                    url: URL(string: photoURL),
                    priority: .immediate
                )
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .clipped()
                .onTapGesture {
                    selectedPhotoIndex = index
                    showFullScreenPhotos = true
                    HapticManager.shared.impact(.light)
                }
                .tag(index)
            }
        }
        .frame(height: 400)
        .tabViewStyle(.page)
        .onChange(of: selectedPhotoIndex) { _, newIndex in
            ImageCache.shared.prefetchAdjacentPhotos(photos: validPhotos, currentIndex: newIndex)
        }
        .fullScreenCover(isPresented: $showFullScreenPhotos) {
            FullScreenPhotoViewer(
                photos: validPhotos,
                selectedIndex: $selectedPhotoIndex,
                isPresented: $showFullScreenPhotos
            )
        }
    }

    // MARK: - Profile Content

    private var profileContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            headerSection
            bioSection
            gamesSection
            platformsSection
            gamingStatsSection
            scheduleSection
            externalProfilesSection
            promptsSection
            lookingForSection
        }
        .padding(20)
        .padding(.bottom, 80)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.gamerTag.isEmpty ? user.fullName : user.gamerTag)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if !user.gamerTag.isEmpty {
                        Text(user.fullName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(.cyan)
                }

                if user.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }

            // Skill & Play Style badges
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(user.skillLevel)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(20)

                HStack(spacing: 4) {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.green)
                    Text(user.playStyle)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.15))
                .cornerRadius(20)
            }
            .font(.subheadline)

            // Location & Region
            if !user.location.isEmpty || user.region != nil {
                HStack(spacing: 12) {
                    if !user.location.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.green)
                            Text("\(user.location), \(user.country)")
                                .foregroundColor(.secondary)
                        }
                    }

                    if let region = user.region {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .foregroundColor(.cyan)
                            Text(region)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .font(.subheadline)
            }

            lastActiveView
        }
    }

    private var lastActiveView: some View {
        HStack(spacing: 6) {
            let interval = Date().timeIntervalSince(user.lastActive)
            let isActive = user.isOnline || interval < 300

            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text(user.isOnline ? "Online Now" : "Active now")
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                Text("Last online \(user.lastActive.timeAgoShort()) ago")
                    .foregroundColor(.secondary)
            }
        }
        .font(.caption)
    }

    // MARK: - Bio Section

    @ViewBuilder
    private var bioSection: some View {
        if !user.bio.isEmpty {
            ProfileSectionCard(
                icon: "quote.bubble.fill",
                title: "About",
                iconColors: [.green, .cyan],
                borderColor: .green
            ) {
                Text(user.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Games Section

    @ViewBuilder
    private var gamesSection: some View {
        if !user.favoriteGames.isEmpty {
            ProfileSectionCard(
                icon: "gamecontroller.fill",
                title: "Games",
                iconColors: [.green, .cyan],
                borderColor: .green
            ) {
                VStack(spacing: 12) {
                    ForEach(user.favoriteGames) { game in
                        GameCard(game: game)
                    }
                }
            }
        }
    }

    // MARK: - Platforms Section

    @ViewBuilder
    private var platformsSection: some View {
        if !user.platforms.isEmpty {
            ProfileSectionCard(
                icon: "display",
                title: "Platforms",
                iconColors: [.blue, .cyan],
                borderColor: .blue
            ) {
                FlowLayout2(spacing: 10) {
                    ForEach(user.platforms, id: \.self) { platform in
                        PlatformTag(platform: platform)
                    }
                }
            }
        }
    }

    // MARK: - Gaming Stats Section

    @ViewBuilder
    private var gamingStatsSection: some View {
        let stats = user.gamingStats
        if stats.totalGamesPlayed > 0 || stats.weeklyHours != nil || stats.yearsGaming != nil {
            ProfileSectionCard(
                icon: "chart.bar.fill",
                title: "Gaming Stats",
                iconColors: [.orange, .yellow],
                borderColor: .orange
            ) {
                VStack(spacing: 12) {
                    if stats.totalGamesPlayed > 0 {
                        DetailRow(icon: "gamecontroller", label: "Games Played", value: "\(stats.totalGamesPlayed)")
                    }
                    if let weeklyHours = stats.weeklyHours {
                        DetailRow(icon: "clock.fill", label: "Weekly Hours", value: "\(weeklyHours)h")
                    }
                    if let yearsGaming = stats.yearsGaming {
                        DetailRow(icon: "calendar", label: "Years Gaming", value: "\(yearsGaming)+")
                    }
                    if stats.tournamentWins > 0 {
                        DetailRow(icon: "trophy.fill", label: "Tournament Wins", value: "\(stats.tournamentWins)")
                    }
                    if stats.teamCount > 0 {
                        DetailRow(icon: "person.3.fill", label: "Teams Joined", value: "\(stats.teamCount)")
                    }
                    if let favoriteGenre = stats.favoriteGenre {
                        DetailRow(icon: "star.fill", label: "Favorite Genre", value: favoriteGenre)
                    }
                }
            }
        }
    }

    // MARK: - Schedule Section

    @ViewBuilder
    private var scheduleSection: some View {
        let schedule = user.gamingSchedule
        if !schedule.preferredDays.isEmpty || schedule.weekdayStart != nil {
            ProfileSectionCard(
                icon: "calendar.badge.clock",
                title: "Gaming Schedule",
                iconColors: [.cyan, .blue],
                borderColor: .cyan
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    if !schedule.preferredDays.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Preferred Days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            FlowLayout2(spacing: 8) {
                                ForEach(schedule.preferredDays, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.cyan.opacity(0.15))
                                        .foregroundColor(.cyan)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    if let weekdayStart = schedule.weekdayStart, let weekdayEnd = schedule.weekdayEnd {
                        DetailRow(icon: "briefcase", label: "Weekdays", value: "\(weekdayStart) - \(weekdayEnd)")
                    }

                    if let weekendStart = schedule.weekendStart, let weekendEnd = schedule.weekendEnd {
                        DetailRow(icon: "sun.max.fill", label: "Weekends", value: "\(weekendStart) - \(weekendEnd)")
                    }

                    DetailRow(icon: "globe", label: "Timezone", value: schedule.timezone)
                }
            }
        }
    }

    // MARK: - External Profiles Section

    @ViewBuilder
    private var externalProfilesSection: some View {
        let hasExternalProfiles = user.discordTag != nil || user.steamId != nil ||
                                  user.twitchUsername != nil || user.riotId != nil ||
                                  user.battleNetTag != nil

        if hasExternalProfiles {
            ProfileSectionCard(
                icon: "link",
                title: "Gaming Profiles",
                iconColors: [.blue, .green],
                borderColor: .indigo
            ) {
                VStack(spacing: 12) {
                    if let discord = user.discordTag {
                        ExternalProfileRow(icon: "message.fill", platform: "Discord", username: discord, color: .indigo)
                    }
                    if let steam = user.steamId {
                        ExternalProfileRow(icon: "gamecontroller.fill", platform: "Steam", username: steam, color: .blue)
                    }
                    if let twitch = user.twitchUsername {
                        ExternalProfileRow(icon: "video.fill", platform: "Twitch", username: twitch, color: .green)
                    }
                    if let riot = user.riotId {
                        ExternalProfileRow(icon: "r.circle.fill", platform: "Riot", username: riot, color: .red)
                    }
                    if let battleNet = user.battleNetTag {
                        ExternalProfileRow(icon: "b.circle.fill", platform: "Battle.net", username: battleNet, color: .blue)
                    }
                    if let psn = user.psnId {
                        ExternalProfileRow(icon: "playstation.logo", platform: "PSN", username: psn, color: .blue)
                    }
                    if let xbox = user.xboxGamertag {
                        ExternalProfileRow(icon: "xbox.logo", platform: "Xbox", username: xbox, color: .green)
                    }
                }
            }
        }
    }

    // MARK: - Prompts Section

    @ViewBuilder
    private var promptsSection: some View {
        if !user.prompts.isEmpty {
            ProfileSectionCard(
                icon: "text.bubble.fill",
                title: "Get to Know Me",
                iconColors: [.green, .cyan],
                borderColor: .green
            ) {
                VStack(spacing: 12) {
                    ForEach(user.prompts) { prompt in
                        PromptCard(prompt: prompt)
                    }
                }
            }
        }
    }

    // MARK: - Looking For Section

    @ViewBuilder
    private var lookingForSection: some View {
        if !user.lookingFor.isEmpty {
            ProfileSectionCard(
                icon: "person.2.fill",
                title: "Show Me",
                iconColors: [.cyan, .green],
                borderColor: .cyan
            ) {
                FlowLayout2(spacing: 10) {
                    ForEach(user.lookingFor, id: \.self) { type in
                        ProfileTagView(text: type, colors: [.cyan, .green], textColor: .cyan)
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            dismissButton
            saveButton
            messageButton
            requestButton
        }
        .padding(.bottom, 30)
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.title2)
                .foregroundColor(.gray)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .accessibilityLabel("Close")
        .accessibilityHint("Return to browsing")
    }

    private var saveButton: some View {
        Button {
            guard !isSavingProfile else { return }

            HapticManager.shared.impact(.light)
            let wasAlreadySaved = isSaved
            isSaved.toggle()
            isSavingProfile = true

            Task {
                defer {
                    Task { @MainActor in
                        isSavingProfile = false
                    }
                }

                if isSaved {
                    let success = await savedProfilesVM.saveProfile(user: user)
                    if !success {
                        await MainActor.run {
                            isSaved = wasAlreadySaved
                            HapticManager.shared.notification(.error)
                        }
                    }
                } else {
                    if let userId = user.effectiveId {
                        savedProfilesVM.unsaveByUserId(userId)
                    }
                }
            }
        } label: {
            ZStack {
                if isSavingProfile {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .frame(width: 60, height: 60)
            .background(Color.white)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .disabled(isSavingProfile)
        .accessibilityLabel(isSaved ? "Remove from saved" : "Save profile")
    }

    private var messageButton: some View {
        Button {
            openChat()
        } label: {
            Image(systemName: "message.fill")
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .accessibilityLabel("Message")
        .accessibilityHint("Start a conversation")
    }

    private var requestButton: some View {
        Button {
            toggleRequest()
        } label: {
            ZStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isRequested ? .green : .white))
                        .scaleEffect(1.0)
                } else {
                    Image(systemName: isRequested ? "person.badge.minus" : "person.badge.plus")
                        .font(.title2)
                        .foregroundColor(isRequested ? .green : .white)
                }
            }
            .frame(width: 60, height: 60)
            .background(
                Group {
                    if isRequested {
                        Color.white
                    } else {
                        LinearGradient(
                            colors: [Color.green, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.1), radius: 5)
        }
        .disabled(isProcessing)
        .accessibilityLabel(isRequested ? "Cancel Request" : "Send Request")
    }

    // MARK: - Helper Functions

    private func handleOnAppear() {
        isSaved = savedProfilesVM.savedProfiles.contains(where: { $0.user.effectiveId == user.effectiveId })

        if onRequestChanged != nil {
            isRequested = initialIsRequested
        }

        Task {
            guard let currentUserId = authService.currentUser?.effectiveId,
                  let viewedUserId = user.effectiveId else { return }

            if onRequestChanged == nil {
                do {
                    let alreadyRequested = try await SwipeService.shared.checkIfLiked(
                        fromUserId: currentUserId,
                        toUserId: viewedUserId
                    )
                    await MainActor.run {
                        isRequested = alreadyRequested
                    }
                } catch {
                    Logger.shared.error("Error checking request status", category: .matching, error: error)
                }
            }

            do {
                try await ProfileStatsService.shared.recordProfileView(
                    viewerId: currentUserId,
                    viewedUserId: viewedUserId
                )
            } catch {
                Logger.shared.error("Error recording profile view", category: .general, error: error)
            }

            do {
                try await AnalyticsManager.shared.trackProfileView(
                    viewedUserId: viewedUserId,
                    viewerUserId: currentUserId
                )
            } catch {
                Logger.shared.error("Error tracking profile view analytics", category: .general, error: error)
            }
        }
    }

    func toggleRequest() {
        guard let currentUserID = authService.currentUser?.effectiveId,
              let targetUserID = user.effectiveId,
              !isProcessing else { return }

        guard currentUserID != targetUserID else {
            errorMessage = "You can't send a request to yourself!"
            showingError = true
            return
        }

        HapticManager.shared.impact(.medium)

        if !isRequested {
            let isPremium = authService.currentUser?.isPremium ?? false
            if !isPremium {
                guard RateLimiter.shared.canSendLike() else {
                    upgradeContextMessage = "You've reached your daily request limit. Subscribe to continue!"
                    showPremiumUpgrade = true
                    return
                }
            }
        }

        if isRequested {
            isProcessing = true
            isRequested = false
            onRequestChanged?(false)

            Task {
                do {
                    try await SwipeService.shared.unlikeUser(
                        fromUserId: currentUserID,
                        toUserId: targetUserID
                    )

                    await MainActor.run {
                        isProcessing = false
                        showingUnrequested = true
                    }
                } catch {
                    await MainActor.run {
                        isProcessing = false
                        isRequested = true
                        onRequestChanged?(true)
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
        } else {
            isProcessing = true
            isRequested = true
            onRequestChanged?(true)

            Task {
                do {
                    let isConnection = try await SwipeService.shared.likeUser(
                        fromUserId: currentUserID,
                        toUserId: targetUserID,
                        isSuperLike: false
                    )

                    await MainActor.run {
                        isProcessing = false

                        if isConnection {
                            showingConnected = true
                            HapticManager.shared.notification(.success)
                        } else {
                            showingRequestSent = true
                        }
                    }
                } catch {
                    await MainActor.run {
                        isProcessing = false
                        isRequested = false
                        onRequestChanged?(false)
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
        }
    }

    func openChat() {
        guard let currentUserId = authService.currentUser?.effectiveId,
              let targetUserId = user.effectiveId else { return }

        guard currentUserId != targetUserId else {
            errorMessage = "You can't message yourself!"
            showingError = true
            return
        }

        HapticManager.shared.impact(.medium)

        Task {
            do {
                var existingMatch = try await MatchService.shared.fetchMatch(user1Id: currentUserId, user2Id: targetUserId)

                if existingMatch == nil {
                    await MatchService.shared.createMatch(user1Id: currentUserId, user2Id: targetUserId)
                    try await Task.sleep(nanoseconds: 300_000_000)

                    for attempt in 1...3 {
                        existingMatch = try await MatchService.shared.fetchMatch(user1Id: currentUserId, user2Id: targetUserId)
                        if existingMatch != nil { break }
                        if attempt < 3 {
                            try await Task.sleep(nanoseconds: 200_000_000)
                        }
                    }
                }

                await MainActor.run {
                    if let match = existingMatch {
                        chatMatch = match
                        showingChat = true
                    } else {
                        errorMessage = "Unable to start conversation. Please try again."
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Unable to start conversation. Please check your connection."
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct GameCard: View {
    let game: FavoriteGame

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
                .background(Color.green.opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(game.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text(game.platform)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let rank = game.rank {
                        Text(rank)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(4)
                    }

                    if let hours = game.hoursPlayed {
                        Text("\(hours)h")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PlatformTag: View {
    let platform: String

    var platformIcon: String {
        switch platform {
        case GamingPlatform.pc.rawValue: return "desktopcomputer"
        case GamingPlatform.playstation.rawValue: return "gamecontroller"
        case GamingPlatform.xbox.rawValue: return "gamecontroller.fill"
        case GamingPlatform.nintendoSwitch.rawValue: return "gamecontroller"
        case GamingPlatform.mobile.rawValue: return "iphone"
        default: return "gamecontroller"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: platformIcon)
                .font(.caption)
            Text(platform)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.15))
        .foregroundColor(.blue)
        .cornerRadius(20)
    }
}

struct ExternalProfileRow: View {
    let icon: String
    let platform: String
    let username: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24)

            Text(platform)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(username)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Reusable Components (from original file)

struct ProfileSectionCard<Content: View>: View {
    let icon: String
    let title: String
    let iconColors: [Color]
    let borderColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(borderColor.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ProfileTagView: View {
    let text: String
    let colors: [Color]
    let textColor: Color

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [colors[0].opacity(0.15), colors[1].opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(textColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(textColor.opacity(0.2), lineWidth: 1)
            )
    }
}

struct PromptCard: View {
    let prompt: ProfilePrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prompt.question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)

            Text(prompt.answer)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.05), Color.cyan.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout2: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Full Screen Photo Viewer

struct FullScreenPhotoViewer: View {
    let photos: [String]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool

    @State private var dismissDragOffset: CGFloat = 0
    @State private var isDismissing = false

    private let dismissThreshold: CGFloat = 150

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .opacity(backgroundOpacity)
                    .ignoresSafeArea()

                TabView(selection: $selectedIndex) {
                    ForEach(Array(photos.enumerated()), id: \.offset) { index, photoURL in
                        ZoomablePhotoView(
                            url: URL(string: photoURL),
                            isCurrentPhoto: index == selectedIndex
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .offset(y: dismissDragOffset)
                .scaleEffect(dismissScale)
                .onChange(of: selectedIndex) { newIndex in
                    ImageCache.shared.prefetchAdjacentPhotos(photos: photos, currentIndex: newIndex)
                }

                VStack {
                    HStack {
                        Button {
                            HapticManager.shared.impact(.light)
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                        }

                        Spacer()

                        Text("\(selectedIndex + 1) / \(photos.count)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()
                }
                .opacity(controlsOpacity)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            dismissDragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > dismissThreshold {
                            isDismissing = true
                            HapticManager.shared.impact(.light)
                            withAnimation(.easeOut(duration: 0.2)) {
                                dismissDragOffset = geometry.size.height
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isPresented = false
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dismissDragOffset = 0
                            }
                        }
                    }
            )
        }
        .statusBarHidden()
        .onAppear {
            ImageCache.shared.prefetchAdjacentPhotos(photos: photos, currentIndex: selectedIndex)
        }
    }

    private var backgroundOpacity: Double {
        let progress = min(dismissDragOffset / dismissThreshold, 1.0)
        return 1.0 - (progress * 0.5)
    }

    private var dismissScale: CGFloat {
        let progress = min(dismissDragOffset / dismissThreshold, 1.0)
        return 1.0 - (progress * 0.1)
    }

    private var controlsOpacity: Double {
        let progress = min(dismissDragOffset / dismissThreshold, 1.0)
        return 1.0 - progress
    }
}

struct ZoomablePhotoView: View {
    let url: URL?
    let isCurrentPhoto: Bool

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    init(url: URL?, isCurrentPhoto: Bool = true) {
        self.url = url
        self.isCurrentPhoto = isCurrentPhoto
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black

                CachedCardImage(url: url, priority: isCurrentPhoto ? .immediate : .high)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                if scale < 1 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        scale = 1
                                        offset = .zero
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        scale > 1 ?
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                        : nil
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                            if scale > 1 {
                                scale = 1
                                offset = .zero
                                lastOffset = .zero
                            } else {
                                scale = 2
                            }
                        }
                        HapticManager.shared.impact(.light)
                    }
            }
        }
    }
}

#Preview {
    UserDetailView(user: User(
        email: "test@test.com",
        fullName: "Alex Storm",
        gamerTag: "StormPlayer99",
        bio: "Competitive FPS player looking for ranked teammates. Diamond in Valorant, Masters in Apex. Let's climb together!",
        location: "Los Angeles",
        country: "USA",
        region: "NA West",
        platforms: ["PC", "PlayStation"],
        favoriteGames: [
            FavoriteGame(title: "Valorant", platform: "PC", rank: "Diamond 2"),
            FavoriteGame(title: "Apex Legends", platform: "PC", rank: "Masters")
        ],
        gameGenres: ["FPS", "Battle Royale"],
        playStyle: PlayStyle.competitive.rawValue,
        skillLevel: SkillLevel.advanced.rawValue,
        voiceChatPreference: VoiceChatPreference.always.rawValue,
        lookingFor: [LookingForType.rankedTeammates.rawValue, LookingForType.competitiveTeam.rawValue]
    ))
}
