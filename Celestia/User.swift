//
//  User.swift
//  TeamUp
//
//  Core user model for gaming teammate finder
//
//  PROFILE STATUS FLOW:
//  --------------------
//  profileStatus controls user visibility and app access:
//
//  1. "pending"   - New account awaiting admin approval (SignUpView.swift)
//                   User sees: PendingApprovalView
//                   Hidden from: Other users in Discover, Requests, Search
//
//  2. "active"    - Approved and visible to others
//                   User sees: MainTabView (full app access)
//                   Set by: AdminModerationDashboard.approveProfile()
//
//  3. "rejected"  - Rejected, user must fix issues
//                   User sees: ProfileRejectionFeedbackView
//                   Set by: AdminModerationDashboard.rejectProfile()
//                   Properties: profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions
//
//  4. "flagged"   - Under extended moderator review
//                   User sees: FlaggedAccountView
//                   Set by: AdminModerationDashboard.flagProfile()
//                   Hidden from: Other users during review
//
//  5. "suspended" - Temporarily blocked (with end date)
//                   User sees: SuspendedAccountView
//                   Properties: isSuspended, suspendedAt, suspendedUntil, suspendReason
//
//  6. "banned"    - Permanently blocked
//                   User sees: BannedAccountView
//                   Properties: isBanned, bannedAt, banReason
//
//  Routing handled by: ContentView.swift (updateAuthenticationState)
//  Filtering handled by: UserService.swift, RequestsView, SavedProfilesView, etc.
//

import Foundation
import FirebaseFirestore

// MARK: - Gaming Enums

enum GamingPlatform: String, Codable, CaseIterable, Identifiable {
    case pc = "PC"
    case playstation = "PlayStation"
    case xbox = "Xbox"
    case nintendoSwitch = "Nintendo Switch"
    case mobile = "Mobile"
    case vr = "VR"
    case tabletop = "Tabletop"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pc: return "desktopcomputer"
        case .playstation: return "gamecontroller"
        case .xbox: return "gamecontroller.fill"
        case .nintendoSwitch: return "gamecontroller"
        case .mobile: return "iphone"
        case .vr: return "visionpro"
        case .tabletop: return "dice"
        }
    }
}

enum PlayStyle: String, Codable, CaseIterable, Identifiable {
    case competitive = "Competitive"
    case casual = "Casual"
    case tryhard = "Tryhard"
    case social = "Social"
    case roleplay = "Roleplay"
    case speedrun = "Speedrun"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .competitive: return "Playing to win"
        case .casual: return "Relaxed gaming"
        case .tryhard: return "Always giving 100%"
        case .social: return "Here for the chat"
        case .roleplay: return "Immersive character play"
        case .speedrun: return "Going fast"
        }
    }

    var icon: String {
        switch self {
        case .competitive: return "trophy"
        case .casual: return "cup.and.saucer"
        case .tryhard: return "flame"
        case .social: return "message"
        case .roleplay: return "theatermasks"
        case .speedrun: return "timer"
        }
    }
}

enum SkillLevel: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    case professional = "Professional"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        case .professional: return 5
        }
    }
}

enum VoiceChatPreference: String, Codable, CaseIterable, Identifiable {
    case always = "Always"
    case preferred = "Preferred"
    case sometimes = "Sometimes"
    case textOnly = "Text Only"
    case noPreference = "No Preference"

    var id: String { rawValue }
}

enum LookingForType: String, Codable, CaseIterable, Identifiable {
    case rankedTeammates = "Ranked Teammates"
    case casualCoOp = "Casual Co-op"
    case boardGameGroup = "Board Game Group"
    case competitiveTeam = "Competitive Team"
    case streamingPartners = "Streaming Partners"
    case anyGamers = "Any Gamers"
    case tournamentTeam = "Tournament Team"
    case contentCreation = "Content Creation"

    var id: String { rawValue }
}

enum GameGenre: String, Codable, CaseIterable, Identifiable {
    case fps = "FPS"
    case moba = "MOBA"
    case battleRoyale = "Battle Royale"
    case rpg = "RPG"
    case mmorpg = "MMORPG"
    case sports = "Sports"
    case racing = "Racing"
    case fighting = "Fighting"
    case strategy = "Strategy"
    case simulation = "Simulation"
    case survival = "Survival"
    case horror = "Horror"
    case puzzle = "Puzzle"
    case platformer = "Platformer"
    case sandbox = "Sandbox"
    case cardGame = "Card Game"
    case boardGame = "Board Game"
    case indie = "Indie"
    case coOp = "Co-op"
    case party = "Party Games"

    var id: String { rawValue }
}

// MARK: - Game Model

struct FavoriteGame: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var platform: String
    var hoursPlayed: Int?
    var rank: String?
    var mainCharacter: String?

    init(id: String = UUID().uuidString, title: String, platform: String, hoursPlayed: Int? = nil, rank: String? = nil, mainCharacter: String? = nil) {
        self.id = id
        self.title = title
        self.platform = platform
        self.hoursPlayed = hoursPlayed
        self.rank = rank
        self.mainCharacter = mainCharacter
    }
}

// MARK: - Gaming Stats

struct GamingStats: Codable, Equatable {
    var totalGamesPlayed: Int
    var favoriteGenre: String?
    var weeklyHours: Int?
    var yearsGaming: Int?
    var tournamentWins: Int
    var teamCount: Int
    var achievementsUnlocked: Int

    init(
        totalGamesPlayed: Int = 0,
        favoriteGenre: String? = nil,
        weeklyHours: Int? = nil,
        yearsGaming: Int? = nil,
        tournamentWins: Int = 0,
        teamCount: Int = 0,
        achievementsUnlocked: Int = 0
    ) {
        self.totalGamesPlayed = totalGamesPlayed
        self.favoriteGenre = favoriteGenre
        self.weeklyHours = weeklyHours
        self.yearsGaming = yearsGaming
        self.tournamentWins = tournamentWins
        self.teamCount = teamCount
        self.achievementsUnlocked = achievementsUnlocked
    }

    init(dictionary: [String: Any]) {
        self.totalGamesPlayed = dictionary["totalGamesPlayed"] as? Int ?? 0
        self.favoriteGenre = dictionary["favoriteGenre"] as? String
        self.weeklyHours = dictionary["weeklyHours"] as? Int
        self.yearsGaming = dictionary["yearsGaming"] as? Int
        self.tournamentWins = dictionary["tournamentWins"] as? Int ?? 0
        self.teamCount = dictionary["teamCount"] as? Int ?? 0
        self.achievementsUnlocked = dictionary["achievementsUnlocked"] as? Int ?? 0
    }
}

// MARK: - Gaming Schedule

struct GamingSchedule: Codable, Equatable {
    var timezone: String
    var weekdayStart: String?  // e.g., "18:00"
    var weekdayEnd: String?    // e.g., "23:00"
    var weekendStart: String?
    var weekendEnd: String?
    var preferredDays: [String]  // ["Monday", "Friday", "Saturday"]

    init(
        timezone: String = TimeZone.current.identifier,
        weekdayStart: String? = nil,
        weekdayEnd: String? = nil,
        weekendStart: String? = nil,
        weekendEnd: String? = nil,
        preferredDays: [String] = []
    ) {
        self.timezone = timezone
        self.weekdayStart = weekdayStart
        self.weekdayEnd = weekdayEnd
        self.weekendStart = weekendStart
        self.weekendEnd = weekendEnd
        self.preferredDays = preferredDays
    }

    init(dictionary: [String: Any]) {
        self.timezone = dictionary["timezone"] as? String ?? TimeZone.current.identifier
        self.weekdayStart = dictionary["weekdayStart"] as? String
        self.weekdayEnd = dictionary["weekdayEnd"] as? String
        self.weekendStart = dictionary["weekendStart"] as? String
        self.weekendEnd = dictionary["weekendEnd"] as? String
        self.preferredDays = dictionary["preferredDays"] as? [String] ?? []
    }
}

// MARK: - Gaming Achievement

struct GamingAchievement: Codable, Equatable, Identifiable {
    var id: String
    var title: String
    var game: String
    var description: String?
    var earnedDate: Date?
    var iconURL: String?

    init(id: String = UUID().uuidString, title: String, game: String, description: String? = nil, earnedDate: Date? = nil, iconURL: String? = nil) {
        self.id = id
        self.title = title
        self.game = game
        self.description = description
        self.earnedDate = earnedDate
        self.iconURL = iconURL
    }
}

// MARK: - User Model

struct User: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    // Manual ID for test data (bypasses @DocumentID restrictions)
    // This is used when creating test users in DEBUG mode
    private var _manualId: String?

    // Computed property that returns manual ID if set, otherwise @DocumentID value
    var effectiveId: String? {
        _manualId ?? id
    }

    // Equatable implementation - compare by id
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.effectiveId == rhs.effectiveId
    }

    // MARK: - Basic Info
    var email: String
    var fullName: String
    var gamerTag: String  // Gaming username/handle
    var bio: String       // Gaming bio/about

    // MARK: - Location (for regional matchmaking)
    var location: String
    var country: String
    var latitude: Double?
    var longitude: Double?
    var region: String?   // e.g., "NA East", "EU West", "Asia Pacific"

    // MARK: - Profile Media
    var photos: [String]
    var profileImageURL: String

    // MARK: - Gaming Profile
    var platforms: [String]           // GamingPlatform raw values
    var favoriteGames: [FavoriteGame]
    var gameGenres: [String]          // GameGenre raw values
    var playStyle: String             // PlayStyle raw value
    var skillLevel: String            // SkillLevel raw value
    var voiceChatPreference: String   // VoiceChatPreference raw value
    var lookingFor: [String]          // LookingForType raw values

    // MARK: - Gaming Schedule
    var gamingSchedule: GamingSchedule

    // MARK: - Gaming Stats & Achievements
    var gamingStats: GamingStats
    var achievements: [GamingAchievement]

    // MARK: - External Gaming Profiles
    var steamId: String?
    var discordTag: String?
    var twitchUsername: String?
    var youtubeChannel: String?
    var psnId: String?
    var xboxGamertag: String?
    var nintendoFriendCode: String?
    var epicGamesId: String?
    var riotId: String?
    var battleNetTag: String?

    // MARK: - Gaming Prompts (conversation starters)
    var prompts: [ProfilePrompt]

    // MARK: - Timestamps
    var timestamp: Date
    var lastActive: Date
    var isOnline: Bool = false

    // MARK: - Premium & Verification
    var isPremium: Bool
    var isVerified: Bool = false
    var premiumTier: String?
    var subscriptionExpiryDate: Date?

    // ID Verification Rejection
    var idVerificationRejected: Bool = false
    var idVerificationRejectedAt: Date?
    var idVerificationRejectionReason: String?

    // Admin Access
    var isAdmin: Bool = false

    // MARK: - Profile Status (for content moderation)
    var profileStatus: String = "pending"
    var profileStatusReason: String?
    var profileStatusReasonCode: String?
    var profileStatusFixInstructions: String?
    var profileStatusUpdatedAt: Date?

    // Suspension Info
    var isSuspended: Bool = false
    var suspendedAt: Date?
    var suspendedUntil: Date?
    var suspendReason: String?

    // Ban Info
    var isBanned: Bool = false
    var bannedAt: Date?
    var banReason: String?

    // Warnings
    var warningCount: Int = 0
    var hasUnreadWarning: Bool = false
    var lastWarningReason: String?

    // MARK: - Discovery Preferences
    var maxDistance: Int
    var showMeInSearch: Bool = true
    var preferredSkillLevels: [String]  // SkillLevel raw values
    var preferredPlayStyles: [String]   // PlayStyle raw values

    // MARK: - Stats
    var requestsSent: Int = 0
    var requestsReceived: Int = 0
    var connectionCount: Int = 0
    var profileViews: Int = 0

    // MARK: - Consumables (Premium Features)
    var superRequestsRemaining: Int = 0
    var boostsRemaining: Int = 0
    var rewindsRemaining: Int = 0

    // Daily Limits (Free Users)
    var requestsRemainingToday: Int = 50
    var lastRequestResetDate: Date = Date()

    // Boost Status
    var isBoostActive: Bool = false
    var boostExpiryDate: Date?

    // MARK: - Notifications
    var fcmToken: String?
    var notificationsEnabled: Bool = true

    // Referral System
    var referralStats: ReferralStats = ReferralStats()
    var referredByCode: String?

    // MARK: - Search Fields (for efficient Firestore queries)
    var fullNameLowercase: String = ""
    var countryLowercase: String = ""
    var locationLowercase: String = ""
    var gamerTagLowercase: String = ""

    // Helper computed property for backward compatibility
    var name: String {
        get { fullName }
        set { fullName = newValue }
    }

    // Update lowercase fields when main fields change
    mutating func updateSearchFields() {
        fullNameLowercase = fullName.lowercased()
        countryLowercase = country.lowercased()
        locationLowercase = location.lowercased()
        gamerTagLowercase = gamerTag.lowercased()
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case email, fullName, gamerTag, bio
        case location, country, latitude, longitude, region
        case photos, profileImageURL
        case platforms, favoriteGames, gameGenres, playStyle, skillLevel, voiceChatPreference, lookingFor
        case gamingSchedule, gamingStats, achievements
        case steamId, discordTag, twitchUsername, youtubeChannel
        case psnId, xboxGamertag, nintendoFriendCode, epicGamesId, riotId, battleNetTag
        case prompts
        case timestamp, lastActive, isOnline
        case isPremium, isVerified, isAdmin, premiumTier, subscriptionExpiryDate
        case idVerificationRejected, idVerificationRejectedAt, idVerificationRejectionReason
        case profileStatus, profileStatusReason, profileStatusReasonCode, profileStatusFixInstructions, profileStatusUpdatedAt
        case isSuspended, suspendedAt, suspendedUntil, suspendReason
        case isBanned, bannedAt, banReason
        case warningCount, hasUnreadWarning, lastWarningReason
        case maxDistance, showMeInSearch, preferredSkillLevels, preferredPlayStyles
        case requestsSent, requestsReceived, connectionCount, profileViews
        case superRequestsRemaining, boostsRemaining, rewindsRemaining
        case requestsRemainingToday, lastRequestResetDate
        case isBoostActive, boostExpiryDate
        case fcmToken, notificationsEnabled
        case referralStats, referredByCode
        case fullNameLowercase, countryLowercase, locationLowercase, gamerTagLowercase
    }

    // MARK: - Custom Encoding

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(gamerTag, forKey: .gamerTag)
        try container.encode(bio, forKey: .bio)
        try container.encode(location, forKey: .location)
        try container.encode(country, forKey: .country)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encode(photos, forKey: .photos)
        try container.encode(profileImageURL, forKey: .profileImageURL)
        try container.encode(platforms, forKey: .platforms)
        try container.encode(favoriteGames, forKey: .favoriteGames)
        try container.encode(gameGenres, forKey: .gameGenres)
        try container.encode(playStyle, forKey: .playStyle)
        try container.encode(skillLevel, forKey: .skillLevel)
        try container.encode(voiceChatPreference, forKey: .voiceChatPreference)
        try container.encode(lookingFor, forKey: .lookingFor)
        try container.encode(gamingSchedule, forKey: .gamingSchedule)
        try container.encode(gamingStats, forKey: .gamingStats)
        try container.encode(achievements, forKey: .achievements)
        try container.encodeIfPresent(steamId, forKey: .steamId)
        try container.encodeIfPresent(discordTag, forKey: .discordTag)
        try container.encodeIfPresent(twitchUsername, forKey: .twitchUsername)
        try container.encodeIfPresent(youtubeChannel, forKey: .youtubeChannel)
        try container.encodeIfPresent(psnId, forKey: .psnId)
        try container.encodeIfPresent(xboxGamertag, forKey: .xboxGamertag)
        try container.encodeIfPresent(nintendoFriendCode, forKey: .nintendoFriendCode)
        try container.encodeIfPresent(epicGamesId, forKey: .epicGamesId)
        try container.encodeIfPresent(riotId, forKey: .riotId)
        try container.encodeIfPresent(battleNetTag, forKey: .battleNetTag)
        try container.encode(prompts, forKey: .prompts)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lastActive, forKey: .lastActive)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(isVerified, forKey: .isVerified)
        try container.encode(isAdmin, forKey: .isAdmin)
        try container.encodeIfPresent(premiumTier, forKey: .premiumTier)
        try container.encodeIfPresent(subscriptionExpiryDate, forKey: .subscriptionExpiryDate)
        try container.encode(idVerificationRejected, forKey: .idVerificationRejected)
        try container.encodeIfPresent(idVerificationRejectedAt, forKey: .idVerificationRejectedAt)
        try container.encodeIfPresent(idVerificationRejectionReason, forKey: .idVerificationRejectionReason)
        try container.encode(profileStatus, forKey: .profileStatus)
        try container.encodeIfPresent(profileStatusReason, forKey: .profileStatusReason)
        try container.encodeIfPresent(profileStatusReasonCode, forKey: .profileStatusReasonCode)
        try container.encodeIfPresent(profileStatusFixInstructions, forKey: .profileStatusFixInstructions)
        try container.encodeIfPresent(profileStatusUpdatedAt, forKey: .profileStatusUpdatedAt)
        try container.encode(isSuspended, forKey: .isSuspended)
        try container.encodeIfPresent(suspendedAt, forKey: .suspendedAt)
        try container.encodeIfPresent(suspendedUntil, forKey: .suspendedUntil)
        try container.encodeIfPresent(suspendReason, forKey: .suspendReason)
        try container.encode(isBanned, forKey: .isBanned)
        try container.encodeIfPresent(bannedAt, forKey: .bannedAt)
        try container.encodeIfPresent(banReason, forKey: .banReason)
        try container.encode(warningCount, forKey: .warningCount)
        try container.encode(hasUnreadWarning, forKey: .hasUnreadWarning)
        try container.encodeIfPresent(lastWarningReason, forKey: .lastWarningReason)
        try container.encode(maxDistance, forKey: .maxDistance)
        try container.encode(showMeInSearch, forKey: .showMeInSearch)
        try container.encode(preferredSkillLevels, forKey: .preferredSkillLevels)
        try container.encode(preferredPlayStyles, forKey: .preferredPlayStyles)
        try container.encode(requestsSent, forKey: .requestsSent)
        try container.encode(requestsReceived, forKey: .requestsReceived)
        try container.encode(connectionCount, forKey: .connectionCount)
        try container.encode(profileViews, forKey: .profileViews)
        try container.encode(superRequestsRemaining, forKey: .superRequestsRemaining)
        try container.encode(boostsRemaining, forKey: .boostsRemaining)
        try container.encode(rewindsRemaining, forKey: .rewindsRemaining)
        try container.encode(requestsRemainingToday, forKey: .requestsRemainingToday)
        try container.encode(lastRequestResetDate, forKey: .lastRequestResetDate)
        try container.encode(isBoostActive, forKey: .isBoostActive)
        try container.encodeIfPresent(boostExpiryDate, forKey: .boostExpiryDate)
        try container.encodeIfPresent(fcmToken, forKey: .fcmToken)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(referralStats, forKey: .referralStats)
        try container.encodeIfPresent(referredByCode, forKey: .referredByCode)
        try container.encode(fullNameLowercase, forKey: .fullNameLowercase)
        try container.encode(countryLowercase, forKey: .countryLowercase)
        try container.encode(locationLowercase, forKey: .locationLowercase)
        try container.encode(gamerTagLowercase, forKey: .gamerTagLowercase)
    }

    // MARK: - Dictionary Initializer

    init(dictionary: [String: Any]) {
        let dictId = dictionary["id"] as? String
        self.id = dictId
        self._manualId = dictId
        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? dictionary["name"] as? String ?? ""
        self.gamerTag = dictionary["gamerTag"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.location = dictionary["location"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.region = dictionary["region"] as? String
        self.photos = dictionary["photos"] as? [String] ?? []
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""

        // Gaming Profile
        self.platforms = dictionary["platforms"] as? [String] ?? []

        if let gamesData = dictionary["favoriteGames"] as? [[String: Any]] {
            self.favoriteGames = gamesData.compactMap { gameDict in
                guard let title = gameDict["title"] as? String,
                      let platform = gameDict["platform"] as? String else {
                    return nil
                }
                return FavoriteGame(
                    id: gameDict["id"] as? String ?? UUID().uuidString,
                    title: title,
                    platform: platform,
                    hoursPlayed: gameDict["hoursPlayed"] as? Int,
                    rank: gameDict["rank"] as? String,
                    mainCharacter: gameDict["mainCharacter"] as? String
                )
            }
        } else {
            self.favoriteGames = []
        }

        self.gameGenres = dictionary["gameGenres"] as? [String] ?? []
        self.playStyle = dictionary["playStyle"] as? String ?? PlayStyle.casual.rawValue
        self.skillLevel = dictionary["skillLevel"] as? String ?? SkillLevel.intermediate.rawValue
        self.voiceChatPreference = dictionary["voiceChatPreference"] as? String ?? VoiceChatPreference.noPreference.rawValue
        self.lookingFor = dictionary["lookingFor"] as? [String] ?? [LookingForType.anyGamers.rawValue]

        // Gaming Schedule
        if let scheduleDict = dictionary["gamingSchedule"] as? [String: Any] {
            self.gamingSchedule = GamingSchedule(dictionary: scheduleDict)
        } else {
            self.gamingSchedule = GamingSchedule()
        }

        // Gaming Stats
        if let statsDict = dictionary["gamingStats"] as? [String: Any] {
            self.gamingStats = GamingStats(dictionary: statsDict)
        } else {
            self.gamingStats = GamingStats()
        }

        // Achievements
        if let achievementsData = dictionary["achievements"] as? [[String: Any]] {
            self.achievements = achievementsData.compactMap { achDict in
                guard let title = achDict["title"] as? String,
                      let game = achDict["game"] as? String else {
                    return nil
                }
                var earnedDate: Date? = nil
                if let ts = achDict["earnedDate"] as? Timestamp {
                    earnedDate = ts.dateValue()
                }
                return GamingAchievement(
                    id: achDict["id"] as? String ?? UUID().uuidString,
                    title: title,
                    game: game,
                    description: achDict["description"] as? String,
                    earnedDate: earnedDate,
                    iconURL: achDict["iconURL"] as? String
                )
            }
        } else {
            self.achievements = []
        }

        // External Gaming Profiles
        self.steamId = dictionary["steamId"] as? String
        self.discordTag = dictionary["discordTag"] as? String
        self.twitchUsername = dictionary["twitchUsername"] as? String
        self.youtubeChannel = dictionary["youtubeChannel"] as? String
        self.psnId = dictionary["psnId"] as? String
        self.xboxGamertag = dictionary["xboxGamertag"] as? String
        self.nintendoFriendCode = dictionary["nintendoFriendCode"] as? String
        self.epicGamesId = dictionary["epicGamesId"] as? String
        self.riotId = dictionary["riotId"] as? String
        self.battleNetTag = dictionary["battleNetTag"] as? String

        // Profile Prompts
        if let promptsData = dictionary["prompts"] as? [[String: Any]] {
            self.prompts = promptsData.compactMap { promptDict in
                guard let question = promptDict["question"] as? String,
                      let answer = promptDict["answer"] as? String else {
                    return nil
                }
                let id = promptDict["id"] as? String ?? UUID().uuidString
                return ProfilePrompt(id: id, question: question, answer: answer)
            }
        } else {
            self.prompts = []
        }

        // Timestamps
        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        if let lastActive = dictionary["lastActive"] as? Timestamp {
            self.lastActive = lastActive.dateValue()
        } else {
            self.lastActive = Date()
        }

        self.isOnline = dictionary["isOnline"] as? Bool ?? false

        // Premium & Verification
        self.isPremium = dictionary["isPremium"] as? Bool ?? false
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        self.isAdmin = dictionary["isAdmin"] as? Bool ?? false
        self.premiumTier = dictionary["premiumTier"] as? String

        if let expiryDate = dictionary["subscriptionExpiryDate"] as? Timestamp {
            self.subscriptionExpiryDate = expiryDate.dateValue()
        }

        self.idVerificationRejected = dictionary["idVerificationRejected"] as? Bool ?? false
        if let rejectedAt = dictionary["idVerificationRejectedAt"] as? Timestamp {
            self.idVerificationRejectedAt = rejectedAt.dateValue()
        }
        self.idVerificationRejectionReason = dictionary["idVerificationRejectionReason"] as? String

        // Profile Status
        self.profileStatus = dictionary["profileStatus"] as? String ?? "pending"
        self.profileStatusReason = dictionary["profileStatusReason"] as? String
        self.profileStatusReasonCode = dictionary["profileStatusReasonCode"] as? String
        self.profileStatusFixInstructions = dictionary["profileStatusFixInstructions"] as? String
        if let statusUpdatedAt = dictionary["profileStatusUpdatedAt"] as? Timestamp {
            self.profileStatusUpdatedAt = statusUpdatedAt.dateValue()
        }

        // Suspension info
        self.isSuspended = dictionary["isSuspended"] as? Bool ?? false
        if let suspendedAtTs = dictionary["suspendedAt"] as? Timestamp {
            self.suspendedAt = suspendedAtTs.dateValue()
        }
        if let suspendedUntilTs = dictionary["suspendedUntil"] as? Timestamp {
            self.suspendedUntil = suspendedUntilTs.dateValue()
        }
        self.suspendReason = dictionary["suspendReason"] as? String

        self.isBanned = dictionary["isBanned"] as? Bool ?? false
        if let bannedAtTs = dictionary["bannedAt"] as? Timestamp {
            self.bannedAt = bannedAtTs.dateValue()
        }
        self.banReason = dictionary["banReason"] as? String

        // Warnings
        self.warningCount = dictionary["warningCount"] as? Int ?? 0
        self.hasUnreadWarning = dictionary["hasUnreadWarning"] as? Bool ?? false
        self.lastWarningReason = dictionary["lastWarningReason"] as? String

        // Discovery Preferences
        self.maxDistance = dictionary["maxDistance"] as? Int ?? 100
        self.showMeInSearch = dictionary["showMeInSearch"] as? Bool ?? true
        self.preferredSkillLevels = dictionary["preferredSkillLevels"] as? [String] ?? []
        self.preferredPlayStyles = dictionary["preferredPlayStyles"] as? [String] ?? []

        // Stats
        self.requestsSent = dictionary["requestsSent"] as? Int ?? 0
        self.requestsReceived = dictionary["requestsReceived"] as? Int ?? 0
        self.connectionCount = dictionary["connectionCount"] as? Int ?? 0
        self.profileViews = dictionary["profileViews"] as? Int ?? 0

        // Consumables
        self.superRequestsRemaining = dictionary["superRequestsRemaining"] as? Int ?? 0
        self.boostsRemaining = dictionary["boostsRemaining"] as? Int ?? 0
        self.rewindsRemaining = dictionary["rewindsRemaining"] as? Int ?? 0
        self.requestsRemainingToday = dictionary["requestsRemainingToday"] as? Int ?? 50

        if let resetDate = dictionary["lastRequestResetDate"] as? Timestamp {
            self.lastRequestResetDate = resetDate.dateValue()
        } else {
            self.lastRequestResetDate = Date()
        }

        self.isBoostActive = dictionary["isBoostActive"] as? Bool ?? false
        if let boostExpiry = dictionary["boostExpiryDate"] as? Timestamp {
            self.boostExpiryDate = boostExpiry.dateValue()
        }

        // Notifications
        self.fcmToken = dictionary["fcmToken"] as? String
        self.notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? true

        // Referral System
        if let referralStatsDict = dictionary["referralStats"] as? [String: Any] {
            self.referralStats = ReferralStats(dictionary: referralStatsDict)
        } else {
            self.referralStats = ReferralStats()
        }
        self.referredByCode = dictionary["referredByCode"] as? String

        // Search fields
        self.fullNameLowercase = (dictionary["fullNameLowercase"] as? String) ?? fullName.lowercased()
        self.countryLowercase = (dictionary["countryLowercase"] as? String) ?? country.lowercased()
        self.locationLowercase = (dictionary["locationLowercase"] as? String) ?? location.lowercased()
        self.gamerTagLowercase = (dictionary["gamerTagLowercase"] as? String) ?? gamerTag.lowercased()
    }

    // MARK: - Standard Initializer

    init(
        id: String? = nil,
        email: String,
        fullName: String,
        gamerTag: String = "",
        bio: String = "",
        location: String,
        country: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        region: String? = nil,
        photos: [String] = [],
        profileImageURL: String = "",
        platforms: [String] = [],
        favoriteGames: [FavoriteGame] = [],
        gameGenres: [String] = [],
        playStyle: String = PlayStyle.casual.rawValue,
        skillLevel: String = SkillLevel.intermediate.rawValue,
        voiceChatPreference: String = VoiceChatPreference.noPreference.rawValue,
        lookingFor: [String] = [LookingForType.anyGamers.rawValue],
        gamingSchedule: GamingSchedule = GamingSchedule(),
        gamingStats: GamingStats = GamingStats(),
        achievements: [GamingAchievement] = [],
        prompts: [ProfilePrompt] = [],
        timestamp: Date = Date(),
        isPremium: Bool = false,
        isVerified: Bool = false,
        lastActive: Date = Date(),
        maxDistance: Int = 100,
        preferredSkillLevels: [String] = [],
        preferredPlayStyles: [String] = []
    ) {
        self.id = id
        self._manualId = id
        self.email = email
        self.fullName = fullName
        self.gamerTag = gamerTag
        self.bio = bio
        self.location = location
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.region = region
        self.photos = photos
        self.profileImageURL = profileImageURL
        self.platforms = platforms
        self.favoriteGames = favoriteGames
        self.gameGenres = gameGenres
        self.playStyle = playStyle
        self.skillLevel = skillLevel
        self.voiceChatPreference = voiceChatPreference
        self.lookingFor = lookingFor
        self.gamingSchedule = gamingSchedule
        self.gamingStats = gamingStats
        self.achievements = achievements
        self.prompts = prompts
        self.timestamp = timestamp
        self.isPremium = isPremium
        self.isVerified = isVerified
        self.lastActive = lastActive
        self.maxDistance = maxDistance
        self.preferredSkillLevels = preferredSkillLevels
        self.preferredPlayStyles = preferredPlayStyles

        // Initialize lowercase search fields
        self.fullNameLowercase = fullName.lowercased()
        self.countryLowercase = country.lowercased()
        self.locationLowercase = location.lowercased()
        self.gamerTagLowercase = gamerTag.lowercased()
    }
}

// MARK: - User Factory Methods

extension User {
    /// Factory method to create a minimal User object for notifications
    static func createMinimal(
        id: String,
        fullName: String,
        from data: [String: Any]
    ) throws -> User {
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        return User(
            id: id,
            email: email,
            fullName: fullName,
            gamerTag: data["gamerTag"] as? String ?? "",
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }

    /// Factory method to create User from Firestore data with validation
    static func fromFirestore(id: String, data: [String: Any]) throws -> User {
        guard let email = data["email"] as? String, !email.isEmpty else {
            throw UserCreationError.missingRequiredField("email")
        }

        guard let fullName = data["fullName"] as? String, !fullName.isEmpty else {
            throw UserCreationError.missingRequiredField("fullName")
        }

        return User(
            id: id,
            email: email,
            fullName: fullName,
            gamerTag: data["gamerTag"] as? String ?? "",
            location: data["location"] as? String ?? "",
            country: data["country"] as? String ?? ""
        )
    }

    /// Check if user has games in common with another user
    func hasGamesInCommon(with other: User) -> Bool {
        let myGames = Set(favoriteGames.map { $0.title.lowercased() })
        let theirGames = Set(other.favoriteGames.map { $0.title.lowercased() })
        return !myGames.isDisjoint(with: theirGames)
    }

    /// Get games in common with another user
    func gamesInCommon(with other: User) -> [String] {
        let myGames = Set(favoriteGames.map { $0.title })
        let theirGames = Set(other.favoriteGames.map { $0.title })
        return Array(myGames.intersection(theirGames))
    }

    /// Check if user has platforms in common with another user
    func hasPlatformsInCommon(with other: User) -> Bool {
        let myPlatforms = Set(platforms)
        let theirPlatforms = Set(other.platforms)
        return !myPlatforms.isDisjoint(with: theirPlatforms)
    }

    /// Get platforms in common with another user
    func platformsInCommon(with other: User) -> [String] {
        let myPlatforms = Set(platforms)
        let theirPlatforms = Set(other.platforms)
        return Array(myPlatforms.intersection(theirPlatforms))
    }
}

// MARK: - User Creation Errors

enum UserCreationError: LocalizedError {
    case missingRequiredField(String)
    case invalidField(String, String)

    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidField(let field, let reason):
            return "Invalid field '\(field)': \(reason)"
        }
    }
}
