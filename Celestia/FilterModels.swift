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

    // MARK: - Location
    var distanceRadius: Int = 100 // miles (1-500) - larger for gaming since online
    var location: CLLocationCoordinate2D?
    var useCurrentLocation: Bool = true
    var region: String? // e.g., "NA East", "EU West", "Asia Pacific"

    // MARK: - Demographics
    var ageRange: AgeRange = AgeRange(min: 13, max: 99)

    // MARK: - Gaming Preferences
    var platforms: [GamingPlatformFilter] = []
    var games: [String] = []  // Game titles
    var gameGenres: [GameGenreFilter] = []
    var skillLevels: [SkillLevelFilter] = []
    var playStyles: [PlayStyleFilter] = []
    var gamerGoals: [GamerGoal] = []

    // MARK: - Availability
    var playSchedule: [PlaySchedule] = []
    var voiceChat: VoiceChatFilter = .any
    var languages: [Language] = []

    // MARK: - Preferences
    var verifiedOnly: Bool = false
    var withPhotosOnly: Bool = false
    var activeInLastDays: Int? // nil = any, or 1, 7, 30
    var newUsers: Bool = false // Joined in last 30 days
    var hasRankedStats: Bool = false
    var streamersOnly: Bool = false

    // MARK: - Metadata
    var id: String = UUID().uuidString
    var createdAt: Date = Date()
    var lastUsed: Date = Date()

    // MARK: - Helper Methods

    /// Check if filter is default (no custom filtering)
    var isDefault: Bool {
        return distanceRadius == 100 &&
               ageRange.min == 13 &&
               ageRange.max == 99 &&
               platforms.isEmpty &&
               games.isEmpty &&
               gameGenres.isEmpty &&
               skillLevels.isEmpty &&
               playStyles.isEmpty &&
               gamerGoals.isEmpty &&
               playSchedule.isEmpty &&
               voiceChat == .any &&
               !verifiedOnly
    }

    /// Count active filters
    var activeFilterCount: Int {
        var count = 0

        if distanceRadius != 100 { count += 1 }
        if ageRange.min != 13 || ageRange.max != 99 { count += 1 }
        if !platforms.isEmpty { count += 1 }
        if !games.isEmpty { count += 1 }
        if !gameGenres.isEmpty { count += 1 }
        if !skillLevels.isEmpty { count += 1 }
        if !playStyles.isEmpty { count += 1 }
        if !gamerGoals.isEmpty { count += 1 }
        if !playSchedule.isEmpty { count += 1 }
        if voiceChat != .any { count += 1 }
        if !languages.isEmpty { count += 1 }
        if verifiedOnly { count += 1 }
        if activeInLastDays != nil { count += 1 }
        if newUsers { count += 1 }
        if hasRankedStats { count += 1 }
        if streamersOnly { count += 1 }

        return count
    }

    /// Reset to default
    mutating func reset() {
        self = SearchFilter()
    }
}

// MARK: - Age Range

struct AgeRange: Codable, Equatable {
    var min: Int // 13-99
    var max: Int // 13-99

    init(min: Int = 13, max: Int = 99) {
        self.min = Swift.max(13, Swift.min(99, min))
        self.max = Swift.max(13, Swift.min(99, max))
    }

    func contains(_ age: Int) -> Bool {
        return age >= min && age <= max
    }
}

// MARK: - Gaming Platform Filter

enum GamingPlatformFilter: String, Codable, CaseIterable, Identifiable {
    case pc = "PC"
    case playstation = "PlayStation"
    case xbox = "Xbox"
    case nintendo = "Nintendo"
    case mobile = "Mobile"
    case vr = "VR"
    case tabletop = "Tabletop"

    var id: String { rawValue }

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
        case .tabletop: return "dice"
        }
    }
}

// MARK: - Game Genre Filter

enum GameGenreFilter: String, Codable, CaseIterable, Identifiable {
    case fps = "FPS"
    case moba = "MOBA"
    case battleRoyale = "Battle Royale"
    case mmo = "MMO"
    case rpg = "RPG"
    case sports = "Sports"
    case racing = "Racing"
    case fighting = "Fighting"
    case strategy = "Strategy"
    case survival = "Survival"
    case horror = "Horror"
    case puzzle = "Puzzle"
    case sandbox = "Sandbox"
    case cardGame = "Card Games"
    case boardGame = "Board Games"
    case tabletopRPG = "Tabletop RPG"
    case coOp = "Co-op"
    case party = "Party Games"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .fps: return "scope"
        case .moba: return "map"
        case .battleRoyale: return "person.3"
        case .mmo: return "globe"
        case .rpg: return "wand.and.stars"
        case .sports: return "sportscourt"
        case .racing: return "car"
        case .fighting: return "figure.boxing"
        case .strategy: return "brain"
        case .survival: return "tent"
        case .horror: return "moon.stars"
        case .puzzle: return "puzzlepiece"
        case .sandbox: return "cube"
        case .cardGame: return "rectangle.stack"
        case .boardGame: return "dice"
        case .tabletopRPG: return "book"
        case .coOp: return "person.2"
        case .party: return "party.popper"
        }
    }
}

// MARK: - Skill Level Filter

enum SkillLevelFilter: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case casual = "Casual"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    case professional = "Pro/Semi-Pro"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var description: String {
        switch self {
        case .beginner: return "Just starting out"
        case .casual: return "Play for fun, not too serious"
        case .intermediate: return "Know the basics, improving"
        case .advanced: return "Skilled, play regularly"
        case .expert: return "Highly skilled, competitive"
        case .professional: return "Tournament/pro level"
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "star"
        case .casual: return "star.leadinghalf.filled"
        case .intermediate: return "star.fill"
        case .advanced: return "star.square"
        case .expert: return "star.square.fill"
        case .professional: return "trophy"
        }
    }
}

// MARK: - Play Style Filter

enum PlayStyleFilter: String, Codable, CaseIterable, Identifiable {
    case competitive = "Competitive"
    case casual = "Casual"
    case tryhard = "Tryhard"
    case social = "Social"
    case roleplay = "Roleplay"
    case speedrun = "Speedrun"
    case completionist = "Completionist"
    case streamer = "Streamer"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var description: String {
        switch self {
        case .competitive: return "Playing to win"
        case .casual: return "Relaxed gaming"
        case .tryhard: return "Always giving 100%"
        case .social: return "Here for the chat"
        case .roleplay: return "Immersive character play"
        case .speedrun: return "Going fast"
        case .completionist: return "100% everything"
        case .streamer: return "Content creation"
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
        case .completionist: return "checkmark.seal"
        case .streamer: return "video"
        }
    }
}

// MARK: - Gamer Goal

enum GamerGoal: String, Codable, CaseIterable, Identifiable {
    case findRankedTeammates = "ranked_teammates"
    case casualCoOp = "casual_coop"
    case competitiveTeam = "competitive_team"
    case boardGameGroup = "board_game_group"
    case dndGroup = "dnd_group"
    case streamingPartner = "streaming_partner"
    case esportsTeam = "esports_team"
    case gamingCommunity = "gaming_community"
    case contentCreation = "content_creation"
    case tournamentSquad = "tournament_squad"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .findRankedTeammates: return "Find Ranked Teammates"
        case .casualCoOp: return "Casual Co-op Gaming"
        case .competitiveTeam: return "Competitive Team"
        case .boardGameGroup: return "Board Game Group"
        case .dndGroup: return "D&D / TTRPG Group"
        case .streamingPartner: return "Streaming Partner"
        case .esportsTeam: return "Esports Team"
        case .gamingCommunity: return "Gaming Community"
        case .contentCreation: return "Content Creation"
        case .tournamentSquad: return "Tournament Squad"
        }
    }

    var icon: String {
        switch self {
        case .findRankedTeammates: return "chart.bar.fill"
        case .casualCoOp: return "gamecontroller"
        case .competitiveTeam: return "person.3.fill"
        case .boardGameGroup: return "dice"
        case .dndGroup: return "wand.and.stars"
        case .streamingPartner: return "video.fill"
        case .esportsTeam: return "trophy.fill"
        case .gamingCommunity: return "person.2.circle"
        case .contentCreation: return "play.rectangle"
        case .tournamentSquad: return "medal"
        }
    }

    var description: String {
        switch self {
        case .findRankedTeammates: return "Climb the ladder together"
        case .casualCoOp: return "Chill gaming sessions"
        case .competitiveTeam: return "Train and compete as a team"
        case .boardGameGroup: return "Tabletop gaming nights"
        case .dndGroup: return "Dice rolling adventures"
        case .streamingPartner: return "Create content together"
        case .esportsTeam: return "Go pro together"
        case .gamingCommunity: return "Find your gaming family"
        case .contentCreation: return "YouTube, TikTok, clips"
        case .tournamentSquad: return "Enter tournaments together"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .findRankedTeammates: return .orange
        case .casualCoOp: return .green
        case .competitiveTeam: return .red
        case .boardGameGroup: return .brown
        case .dndGroup: return .purple
        case .streamingPartner: return .pink
        case .esportsTeam: return .yellow
        case .gamingCommunity: return .blue
        case .contentCreation: return .cyan
        case .tournamentSquad: return .mint
        }
    }
}

// MARK: - Play Schedule

enum PlaySchedule: String, Codable, CaseIterable, Identifiable {
    case weekdayMornings = "weekday_mornings"
    case weekdayAfternoons = "weekday_afternoons"
    case weekdayEvenings = "weekday_evenings"
    case weekdayLateNight = "weekday_late_night"
    case weekendMornings = "weekend_mornings"
    case weekendAfternoons = "weekend_afternoons"
    case weekendEvenings = "weekend_evenings"
    case weekendLateNight = "weekend_late_night"
    case flexible = "flexible"

    var id: String { rawValue }

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
        case .flexible: return "Flexible Schedule"
        }
    }

    var timeRange: String {
        switch self {
        case .weekdayMornings, .weekendMornings: return "6am - 12pm"
        case .weekdayAfternoons, .weekendAfternoons: return "12pm - 6pm"
        case .weekdayEvenings, .weekendEvenings: return "6pm - 12am"
        case .weekdayLateNight, .weekendLateNight: return "12am - 6am"
        case .flexible: return "Anytime"
        }
    }

    var icon: String {
        switch self {
        case .weekdayMornings, .weekendMornings: return "sunrise"
        case .weekdayAfternoons, .weekendAfternoons: return "sun.max"
        case .weekdayEvenings, .weekendEvenings: return "sunset"
        case .weekdayLateNight, .weekendLateNight: return "moon.stars"
        case .flexible: return "clock"
        }
    }
}

// MARK: - Voice Chat Filter

enum VoiceChatFilter: String, Codable, CaseIterable, Identifiable {
    case any = "any"
    case required = "required"
    case preferred = "preferred"
    case optional = "optional"
    case textOnly = "text_only"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .required: return "Voice Chat Required"
        case .preferred: return "Voice Chat Preferred"
        case .optional: return "Voice Chat Optional"
        case .textOnly: return "Text Only"
        }
    }

    var icon: String {
        switch self {
        case .any: return "mic"
        case .required: return "mic.fill"
        case .preferred: return "mic.badge.plus"
        case .optional: return "mic"
        case .textOnly: return "mic.slash"
        }
    }
}

// MARK: - Language

enum Language: String, Codable, CaseIterable, Identifiable {
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
    case norwegian = "no"
    case danish = "da"
    case finnish = "fi"
    case turkish = "tr"
    case thai = "th"
    case vietnamese = "vi"
    case indonesian = "id"

    var id: String { rawValue }

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
        case .norwegian: return "Norwegian"
        case .danish: return "Danish"
        case .finnish: return "Finnish"
        case .turkish: return "Turkish"
        case .thai: return "Thai"
        case .vietnamese: return "Vietnamese"
        case .indonesian: return "Indonesian"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇧🇷"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        case .hindi: return "🇮🇳"
        case .polish: return "🇵🇱"
        case .dutch: return "🇳🇱"
        case .swedish: return "🇸🇪"
        case .norwegian: return "🇳🇴"
        case .danish: return "🇩🇰"
        case .finnish: return "🇫🇮"
        case .turkish: return "🇹🇷"
        case .thai: return "🇹🇭"
        case .vietnamese: return "🇻🇳"
        case .indonesian: return "🇮🇩"
        }
    }
}

// MARK: - Server Region

enum ServerRegion: String, Codable, CaseIterable, Identifiable {
    case naEast = "NA East"
    case naWest = "NA West"
    case naCentral = "NA Central"
    case euWest = "EU West"
    case euNorth = "EU North"
    case euEast = "EU East"
    case asiaPacific = "Asia Pacific"
    case oceania = "Oceania"
    case southAmerica = "South America"
    case middleEast = "Middle East"
    case africa = "Africa"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String { "globe" }
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

// MARK: - SwiftUI Import for Color
import SwiftUI
