//
//  FilterModels.swift
//  TeamUp
//
//  Data models for advanced search and filtering - Gaming focused
//

import Foundation
import CoreLocation

// MARK: - Search Filter

struct SearchFilter: Codable, Equatable {

    // MARK: - Location & Region
    var distanceRadius: Int = 50 // miles (1-100)
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true
    var region: GamingRegion = .any

    // MARK: - Demographics
    var ageRange: AgeRange = AgeRange(min: 13, max: 99)
    var languages: [Language] = []

    // MARK: - Gaming Profile
    var games: [String] = []                           // Games played (multi-select from database)
    var platforms: [GamingPlatformFilter] = []         // Platform(s)
    var skillLevels: [SkillLevelFilter] = []           // Skill level filter
    var playStyles: [PlayStyleFilter] = []             // Play style preferences

    // MARK: - Schedule & Availability
    var playSchedule: [PlaySchedule] = []              // When do they play
    var timezone: String?                               // Timezone filter

    // MARK: - Communication
    var voiceChat: VoiceChatFilter = .any              // Voice chat preference

    // MARK: - Looking For
    var gamerGoals: [GamerGoalFilter] = []             // What they're looking for

    // MARK: - Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = false                   // Gaming - avatars are fine
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days
    var hasMicrophone: Bool? // nil = any, true = must have mic

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 50 &&
               ageRange.min == 13 &&
               ageRange.max == 99 &&
               region == .any &&
               games.isEmpty &&
               platforms.isEmpty &&
               skillLevels.isEmpty &&
               playStyles.isEmpty &&
               playSchedule.isEmpty &&
               voiceChat == .any &&
               gamerGoals.isEmpty &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 50 { count += 1 }
        if ageRange.min != 13 || ageRange.max != 99 { count += 1 }
        if region != .any { count += 1 }
        if !games.isEmpty { count += 1 }
        if !platforms.isEmpty { count += 1 }
        if !skillLevels.isEmpty { count += 1 }
        if !playStyles.isEmpty { count += 1 }
        if !playSchedule.isEmpty { count += 1 }
        if voiceChat != .any { count += 1 }
        if !gamerGoals.isEmpty { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }
        if hasMicrophone != nil { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Age Range

struct AgeRange: Codable, Equatable {
    var min: Int // 13-99 (gaming allows younger users with parental consent)
    var max: Int // 13-99

    init(min: Int = 13, max: Int = 99) {
        self.min = Swift.max(13, Swift.min(99, min))
        self.max = Swift.max(13, Swift.min(99, max))
    }

    func contains(_ age: Int) -> Bool {
        return age >= min && age <= max
    }
}

// MARK: - Gaming Region

enum GamingRegion: String, Codable, CaseIterable {
    case any = "any"
    case naEast = "na_east"
    case naWest = "na_west"
    case euWest = "eu_west"
    case euEast = "eu_east"
    case asia = "asia"
    case oceania = "oceania"
    case southAmerica = "south_america"
    case middleEast = "middle_east"
    case africa = "africa"

    var displayName: String {
        switch self {
        case .any: return "Any Region"
        case .naEast: return "NA East"
        case .naWest: return "NA West"
        case .euWest: return "EU West"
        case .euEast: return "EU East"
        case .asia: return "Asia"
        case .oceania: return "Oceania"
        case .southAmerica: return "South America"
        case .middleEast: return "Middle East"
        case .africa: return "Africa"
        }
    }

    var icon: String {
        return "globe"
    }
}

// MARK: - Gaming Platform Filter

enum GamingPlatformFilter: String, Codable, CaseIterable {
    case pc = "pc"
    case playstation = "playstation"
    case xbox = "xbox"
    case nintendo = "nintendo"
    case mobile = "mobile"
    case vr = "vr"
    case tabletop = "tabletop"

    var displayName: String {
        switch self {
        case .pc: return "PC"
        case .playstation: return "PlayStation"
        case .xbox: return "Xbox"
        case .nintendo: return "Nintendo Switch"
        case .mobile: return "Mobile"
        case .vr: return "VR"
        case .tabletop: return "Tabletop"
        }
    }

    var icon: String {
        switch self {
        case .pc: return "desktopcomputer"
        case .playstation: return "gamecontroller"
        case .xbox: return "gamecontroller.fill"
        case .nintendo: return "gamecontroller"
        case .mobile: return "iphone"
        case .vr: return "visionpro"
        case .tabletop: return "dice.fill"
        }
    }
}

// MARK: - Skill Level Filter

enum SkillLevelFilter: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    case professional = "professional"

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        case .professional: return "Professional / Pro"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "star"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.fill"
        case .expert: return "star.circle.fill"
        case .professional: return "trophy.fill"
        }
    }
}

// MARK: - Play Style Filter

enum PlayStyleFilter: String, Codable, CaseIterable {
    case competitive = "competitive"
    case casual = "casual"
    case tryhard = "tryhard"
    case social = "social"
    case roleplay = "roleplay"
    case speedrun = "speedrun"

    var displayName: String {
        switch self {
        case .competitive: return "Competitive"
        case .casual: return "Casual"
        case .tryhard: return "Tryhard"
        case .social: return "Social"
        case .roleplay: return "Roleplay"
        case .speedrun: return "Speedrun"
        }
    }

    var icon: String {
        switch self {
        case .competitive: return "flame.fill"
        case .casual: return "face.smiling"
        case .tryhard: return "bolt.fill"
        case .social: return "bubble.left.and.bubble.right.fill"
        case .roleplay: return "theatermasks.fill"
        case .speedrun: return "hare.fill"
        }
    }
}

// MARK: - Play Schedule

enum PlaySchedule: String, Codable, CaseIterable {
    case weekdayMornings = "weekday_mornings"
    case weekdayAfternoons = "weekday_afternoons"
    case weekdayEvenings = "weekday_evenings"
    case weekdayLateNight = "weekday_late_night"
    case weekendMornings = "weekend_mornings"
    case weekendAfternoons = "weekend_afternoons"
    case weekendEvenings = "weekend_evenings"
    case weekendLateNight = "weekend_late_night"

    var displayName: String {
        switch self {
        case .weekdayMornings: return "Weekday Mornings"
        case .weekdayAfternoons: return "Weekday Afternoons"
        case .weekdayEvenings: return "Weekday Evenings"
        case .weekdayLateNight: return "Weekday Late Night"
        case .weekendMornings: return "Weekend Mornings"
        case .weekendAfternoons: return "Weekend Afternoons"
        case .weekendEvenings: return "Weekend Evenings"
        case .weekendLateNight: return "Weekend Late Night"
        }
    }

    var icon: String {
        switch self {
        case .weekdayMornings, .weekendMornings: return "sunrise.fill"
        case .weekdayAfternoons, .weekendAfternoons: return "sun.max.fill"
        case .weekdayEvenings, .weekendEvenings: return "sunset.fill"
        case .weekdayLateNight, .weekendLateNight: return "moon.stars.fill"
        }
    }
}

// MARK: - Voice Chat Filter

enum VoiceChatFilter: String, Codable, CaseIterable {
    case any = "any"
    case required = "required"
    case preferred = "preferred"
    case optional = "optional"
    case noVoice = "no_voice"

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .required: return "Voice Required"
        case .preferred: return "Voice Preferred"
        case .optional: return "Voice Optional"
        case .noVoice: return "No Voice Chat"
        }
    }

    var icon: String {
        switch self {
        case .any: return "mic"
        case .required: return "mic.fill"
        case .preferred: return "mic.circle.fill"
        case .optional: return "mic.badge.plus"
        case .noVoice: return "mic.slash"
        }
    }
}

// MARK: - Gamer Goal Filter

enum GamerGoalFilter: String, Codable, CaseIterable {
    case rankedTeammates = "ranked_teammates"
    case casualCoOp = "casual_coop"
    case competitiveTeam = "competitive_team"
    case boardGameGroup = "board_game_group"
    case dndGroup = "dnd_group"
    case streamingPartner = "streaming_partner"
    case esportsTeam = "esports_team"
    case gamingCommunity = "gaming_community"

    var displayName: String {
        switch self {
        case .rankedTeammates: return "Ranked Teammates"
        case .casualCoOp: return "Casual Co-op"
        case .competitiveTeam: return "Competitive Team"
        case .boardGameGroup: return "Board Game Group"
        case .dndGroup: return "D&D / Tabletop"
        case .streamingPartner: return "Streaming Partner"
        case .esportsTeam: return "Esports Team"
        case .gamingCommunity: return "Gaming Community"
        }
    }

    var icon: String {
        switch self {
        case .rankedTeammates: return "trophy.fill"
        case .casualCoOp: return "gamecontroller.fill"
        case .competitiveTeam: return "person.3.fill"
        case .boardGameGroup: return "dice.fill"
        case .dndGroup: return "sparkles"
        case .streamingPartner: return "video.fill"
        case .esportsTeam: return "star.fill"
        case .gamingCommunity: return "bubble.left.and.bubble.right.fill"
        }
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"
    case polish = "pl"
    case dutch = "nl"
    case swedish = "sv"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Spanish"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        case .polish: return "Polish"
        case .dutch: return "Dutch"
        case .swedish: return "Swedish"
        case .thai: return "Thai"
        case .vietnamese: return "Vietnamese"
        case .indonesian: return "Indonesian"
        }
    }
}

// MARK: - Game Rank (for ranked games)

struct GameRank: Codable, Equatable {
    var game: String
    var rank: String
    var tier: String?
    var rating: Int?

    init(game: String, rank: String, tier: String? = nil, rating: Int? = nil) {
        self.game = game
        self.rank = rank
        self.tier = tier
        self.rating = rating
    }
}

// MARK: - Filter Preset

struct FilterPreset: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    var filter: SearchFilter
    var createdAt: Date
    var lastUsed: Date
    var usageCount: Int

    init(
        id: String = UUID().uuidString,
        name: String,
        filter: SearchFilter,
        createdAt: Date = Date(),
        lastUsed: Date = Date(),
        usageCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.filter = filter
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.usageCount = usageCount
    }
}

// MARK: - Search History Entry

struct SearchHistoryEntry: Codable, Identifiable, Equatable {
    let id: String
    let filter: SearchFilter
    let timestamp: Date
    let resultsCount: Int

    init(
        id: String = UUID().uuidString,
        filter: SearchFilter,
        timestamp: Date = Date(),
        resultsCount: Int
    ) {
        self.id = id
        self.filter = filter
        self.timestamp = timestamp
        self.resultsCount = resultsCount
    }
}

// MARK: - CLLocationCoordinate2D Extension

extension CLLocationCoordinate2D: @retroactive Codable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }


    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
}
