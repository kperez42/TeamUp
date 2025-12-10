//
//  Constants.swift
//  TeamUp
//
//  Centralized constants for the gaming friend finder app
//

import Foundation
import SwiftUI

enum AppConstants {
    // MARK: - App Identity
    static let appName = "TeamUp"
    static let appTagline = "Find Your Player 2"
    static let appCategory = "Social Networking"

    // MARK: - API Configuration
    enum API {
        static let baseURL = "https://api.teamup.gg"
        static let timeout: TimeInterval = 30
        static let retryAttempts = 3
    }

    // MARK: - Content Limits
    enum Limits {
        static let maxBioLength = 500
        static let maxMessageLength = 1000
        static let maxRequestMessage = 300
        static let maxFavoriteGames = 20
        static let maxAchievements = 50
        static let maxLanguages = 5
        static let maxPhotos = 6
        static let minPasswordLength = 8
        static let maxNameLength = 50
        static let maxGamerTagLength = 30
    }

    // MARK: - Pagination
    enum Pagination {
        static let usersPerPage = 20
        static let messagesPerPage = 50
        static let connectionsPerPage = 30
        static let requestsPerPage = 20
    }

    // MARK: - Premium Pricing
    enum Premium {
        static let monthlyPrice = 9.99
        static let sixMonthPrice = 49.99
        static let yearlyPrice = 79.99

        // Features
        static let freeRequestsPerDay = 50
        static let premiumUnlimitedRequests = true
        static let premiumSeeWhoRequested = true
        static let premiumBoostProfile = true
        static let premiumAdvancedFilters = true
    }

    // MARK: - Colors (Gaming Theme)
    enum Colors {
        static let primary = Color.green           // Gaming green
        static let secondary = Color.cyan          // Accent cyan
        static let accent = Color.cyan             // Neon accent
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red

        static let gradientStart = Color.green
        static let gradientEnd = Color.cyan

        static func primaryGradient() -> LinearGradient {
            LinearGradient(
                colors: [gradientStart, gradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func accentGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color.blue, Color.teal],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        static func gamingGradient() -> LinearGradient {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    // MARK: - Animation Durations
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        static let splash: TimeInterval = 2.0
    }

    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 16
        static let smallCornerRadius: CGFloat = 10
        static let largeCornerRadius: CGFloat = 20
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
    }

    // MARK: - Image Sizes
    enum ImageSize {
        static let thumbnail: CGFloat = 50
        static let small: CGFloat = 70
        static let medium: CGFloat = 100
        static let large: CGFloat = 150
        static let profile: CGFloat = 130
        static let hero: CGFloat = 400
    }

    // MARK: - Feature Flags
    enum Features {
        static let voiceChatEnabled = true
        static let videoCallsEnabled = false
        static let gameClipsEnabled = false
        static let groupChatsEnabled = true
        static let gifSupportEnabled = true
        static let regionMatchingEnabled = true
        static let steamIntegrationEnabled = true
        static let discordIntegrationEnabled = true
    }

    // MARK: - Firebase Collections
    enum Collections {
        static let users = "users"
        static let connections = "connections"      // renamed from matches
        static let messages = "messages"
        static let requests = "requests"            // renamed from interests
        static let reports = "reports"
        static let blockedUsers = "blocked_users"
        static let analytics = "analytics"
        static let games = "games"                  // game database
        static let teams = "teams"                  // gaming teams/squads
    }

    // MARK: - Storage Paths
    enum StoragePaths {
        static let profileImages = "profile_images"
        static let chatImages = "chat_images"
        static let userPhotos = "user_photos"
        static let gameClips = "game_clips"
        static let achievements = "achievements"
    }

    // MARK: - Rate Limiting
    // PRODUCTION: These limits apply to free users only
    // Premium users bypass these limits entirely (check in RateLimiter)
    enum RateLimit {
        static let messageInterval: TimeInterval = 0.5
        static let requestInterval: TimeInterval = 1.0
        static let searchInterval: TimeInterval = 0.3
        static let maxMessagesPerMinute = 30
        static let maxRequestsPerDay = 10 // Free users get 10 requests per day, premium unlimited
        static let maxDailyMessagesForFreeUsers = 10 // Free users get 10 messages per day total, premium unlimited
    }

    // MARK: - Cache
    enum Cache {
        static let maxImageCacheSize = 100
        static let imageCacheDuration: TimeInterval = 3600 // 1 hour
        static let userDataCacheDuration: TimeInterval = 300 // 5 minutes
        static let gameDataCacheDuration: TimeInterval = 86400 // 24 hours
    }

    // MARK: - Notifications
    enum Notifications {
        static let newConnectionTitle = "New Squad Member!"
        static let newMessageTitle = "New Message"
        static let newRequestTitle = "Someone wants to squad up!"
        static let teamInviteTitle = "Team Invite"
        static let gameSessionTitle = "Game Session Starting"
        static let lfgPostTitle = "New LFG Post"
    }

    // MARK: - Analytics Events
    enum AnalyticsEvents {
        static let appLaunched = "app_launched"
        static let userSignedUp = "user_signed_up"
        static let userSignedIn = "user_signed_in"
        static let profileViewed = "profile_viewed"
        static let connectionCreated = "connection_created"
        static let messageSent = "message_sent"
        static let requestSent = "request_sent"
        static let requestAccepted = "request_accepted"
        static let requestDeclined = "request_declined"
        static let profileEdited = "profile_edited"
        static let premiumViewed = "premium_viewed"
        static let premiumPurchased = "premium_purchased"
        static let gameAdded = "game_added"
        static let platformLinked = "platform_linked"
        static let filterApplied = "filter_applied"
    }

    // MARK: - Error Messages
    enum ErrorMessages {
        static let networkError = "Please check your internet connection and try again."
        static let genericError = "Something went wrong. Please try again."
        static let authError = "Authentication failed. Please try again."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 8 characters with numbers and letters."
        static let passwordMismatch = "Passwords do not match."
        static let accountNotFound = "No account found with this email."
        static let emailInUse = "This email is already registered."
        static let bioTooLong = "Bio must be less than 500 characters."
        static let messageTooLong = "Message must be less than 1000 characters."
        static let gamerTagTaken = "This gamer tag is already taken."
        static let invalidGamerTag = "Gamer tag must be 3-30 characters."
    }

    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://teamup.gg/privacy"
        static let termsOfService = "https://teamup.gg/terms"
        static let support = "mailto:support@teamup.gg"
        static let website = "https://teamup.gg"
        static let discordServer = "https://discord.gg/teamup"
        static let twitterURL = "https://twitter.com/teamupgg"
        static let twitchURL = "https://twitch.tv/teamupgg"
    }

    // MARK: - Gaming Prompts (for profile questions)
    enum GamingPrompts {
        static let all: [String] = [
            "My most epic gaming moment was...",
            "The game that got me into gaming was...",
            "My unpopular gaming opinion is...",
            "I'm looking for teammates who...",
            "My favorite gaming memory is...",
            "The game I've sunk the most hours into is...",
            "My gaming setup includes...",
            "I get competitive when...",
            "My go-to gaming snack is...",
            "The achievement I'm most proud of is...",
            "I prefer gaming late at night because...",
            "My dream gaming collab would be with...",
            "The hardest boss I've ever beaten was...",
            "My gaming hot take is...",
            "If I could only play one game forever, it would be..."
        ]
    }

    // MARK: - Game Database (categorized)
    enum GameDatabase {
        // FPS Games
        static let fps: [String] = [
            "Valorant", "Counter-Strike 2", "Overwatch 2",
            "Call of Duty: Warzone", "Apex Legends", "Rainbow Six Siege",
            "Halo Infinite", "Destiny 2", "Team Fortress 2", "Battlefield 2042"
        ]

        // MOBA Games
        static let moba: [String] = [
            "League of Legends", "Dota 2", "Smite", "Heroes of the Storm",
            "Mobile Legends", "Wild Rift", "Pokemon Unite"
        ]

        // Battle Royale Games
        static let battleRoyale: [String] = [
            "Fortnite", "PUBG", "Call of Duty: Warzone", "Apex Legends",
            "Fall Guys", "Super People", "The Finals"
        ]

        // MMO Games
        static let mmo: [String] = [
            "World of Warcraft", "Final Fantasy XIV", "Elder Scrolls Online",
            "Guild Wars 2", "Lost Ark", "New World", "Black Desert Online"
        ]

        // Sports Games
        static let sports: [String] = [
            "FIFA 24", "EA FC 24", "NBA 2K24", "Rocket League", "Madden 24",
            "NHL 24", "MLB The Show 24", "F1 24", "Gran Turismo 7"
        ]

        // Survival/Sandbox Games
        static let survival: [String] = [
            "Minecraft", "Rust", "ARK: Survival Evolved", "Valheim",
            "Terraria", "Palworld", "Sons of the Forest", "7 Days to Die"
        ]

        // Co-op/Horror Games
        static let coopHorror: [String] = [
            "Phasmophobia", "Dead by Daylight", "Lethal Company",
            "Among Us", "Devour", "Forewarned", "The Forest"
        ]

        // Fighting Games
        static let fighting: [String] = [
            "Street Fighter 6", "Tekken 8", "Mortal Kombat 1",
            "Super Smash Bros. Ultimate", "Guilty Gear Strive", "Dragon Ball FighterZ"
        ]

        // RPG Games
        static let rpg: [String] = [
            "Baldur's Gate 3", "Diablo IV", "Path of Exile", "Elden Ring",
            "Genshin Impact", "Honkai: Star Rail", "Dragon Age: The Veilguard"
        ]

        // Board/Card Games
        static let boardCard: [String] = [
            "Chess.com", "Poker", "Tabletop Simulator", "Hearthstone",
            "Magic: The Gathering Arena", "Legends of Runeterra", "Uno"
        ]

        // Tabletop RPGs
        static let tabletop: [String] = [
            "Dungeons & Dragons", "Pathfinder", "Call of Cthulhu",
            "Warhammer 40K", "Starfinder", "Vampire: The Masquerade"
        ]

        // Party Games
        static let party: [String] = [
            "Mario Kart 8", "Mario Party Superstars", "Jackbox Party Packs",
            "Gang Beasts", "Human Fall Flat", "Overcooked 2"
        ]

        // All games combined
        static var all: [String] {
            return fps + moba + battleRoyale + mmo + sports + survival +
                   coopHorror + fighting + rpg + boardCard + tabletop + party
        }

        // Category names for UI
        static let categories: [(name: String, games: [String])] = [
            ("FPS", fps),
            ("MOBA", moba),
            ("Battle Royale", battleRoyale),
            ("MMO", mmo),
            ("Sports", sports),
            ("Survival/Sandbox", survival),
            ("Co-op/Horror", coopHorror),
            ("Fighting", fighting),
            ("RPG", rpg),
            ("Board/Card", boardCard),
            ("Tabletop RPG", tabletop),
            ("Party", party)
        ]
    }

    // Legacy support
    enum PopularGames {
        static var all: [String] { GameDatabase.all }
    }

    // MARK: - Debug
    enum Debug {
        #if DEBUG
        static let loggingEnabled = true
        static let showDebugInfo = true
        #else
        static let loggingEnabled = false
        static let showDebugInfo = false
        #endif
    }
}

// MARK: - Convenience Extensions

extension AppConstants {
    static func log(_ message: String, category: String = "General") {
        if Debug.loggingEnabled {
            print("[\(category)] \(message)")
        }
    }

    static func logError(_ error: Error, context: String = "") {
        if Debug.loggingEnabled {
            print("[\(context)] Error: \(error.localizedDescription)")
        }
    }
}
