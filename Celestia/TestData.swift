//
//  TestData.swift
//  Celestia
//
//  Created by Claude
//  Test data for previews and development
//

import Foundation
import FirebaseFirestore

#if DEBUG

struct TestData {

    // MARK: - Test Users for Discover Page

    static let discoverUsers: [User] = [
        User(
            id: "test_user_1",
            email: "sarah.johnson@test.com",
            fullName: "Sarah Johnson",
            gamerTag: "SarahPlays",
            bio: "Competitive FPS player 🎯 | Diamond in Valorant | Always looking for ranked teammates!",
            location: "San Francisco",
            country: "USA",
            latitude: 37.7749,
            longitude: -122.4194,
            photos: [
                "https://picsum.photos/seed/sarah1/400/500",
                "https://picsum.photos/seed/sarah2/400/500",
                "https://picsum.photos/seed/sarah3/400/500"
            ],
            profileImageURL: "https://picsum.photos/seed/sarah1/400/500",
            platforms: ["PC", "PlayStation"],
            favoriteGames: [
                FavoriteGame(title: "Valorant", platform: "PC", rank: "Diamond 2"),
                FavoriteGame(title: "Apex Legends", platform: "PC", rank: "Masters")
            ],
            gameGenres: ["FPS", "Battle Royale"],
            playStyle: PlayStyle.competitive.rawValue,
            skillLevel: SkillLevel.advanced.rawValue,
            voiceChatPreference: VoiceChatPreference.always.rawValue,
            lookingFor: [LookingForType.rankedTeammates.rawValue, LookingForType.competitiveTeam.rawValue],
            isPremium: false,
            isVerified: true
        ),

        User(
            id: "test_user_2",
            email: "mike.chen@test.com",
            fullName: "Mike Chen",
            gamerTag: "MikeGaming",
            bio: "Casual gamer 🎮 | Love co-op games and making new friends | Stream on weekends!",
            location: "San Francisco",
            country: "USA",
            latitude: 37.7849,
            longitude: -122.4094,
            photos: [
                "https://picsum.photos/seed/mike1/400/500",
                "https://picsum.photos/seed/mike2/400/500",
                "https://picsum.photos/seed/mike3/400/500"
            ],
            profileImageURL: "https://picsum.photos/seed/mike1/400/500",
            platforms: ["PC", "Nintendo Switch"],
            favoriteGames: [
                FavoriteGame(title: "Stardew Valley", platform: "PC"),
                FavoriteGame(title: "Animal Crossing", platform: "Nintendo Switch"),
                FavoriteGame(title: "It Takes Two", platform: "PC")
            ],
            gameGenres: ["Co-op", "Simulation", "Indie"],
            playStyle: PlayStyle.casual.rawValue,
            skillLevel: SkillLevel.intermediate.rawValue,
            voiceChatPreference: VoiceChatPreference.preferred.rawValue,
            lookingFor: [LookingForType.casualCoOp.rawValue, LookingForType.streamingPartner.rawValue],
            isPremium: true,
            isVerified: true
        ),

        User(
            id: "test_user_3",
            email: "emma.wilson@test.com",
            fullName: "Emma Wilson",
            gamerTag: "EmmaRPG",
            bio: "JRPG enthusiast 🗡️ | D&D Dungeon Master | Looking for a tabletop group!",
            location: "Oakland",
            country: "USA",
            latitude: 37.8044,
            longitude: -122.2712,
            photos: [
                "https://picsum.photos/seed/emma1/400/500",
                "https://picsum.photos/seed/emma2/400/500",
                "https://picsum.photos/seed/emma3/400/500",
                "https://picsum.photos/seed/emma4/400/500"
            ],
            profileImageURL: "https://picsum.photos/seed/emma1/400/500",
            platforms: ["PlayStation", "Nintendo Switch"],
            favoriteGames: [
                FavoriteGame(title: "Final Fantasy XIV", platform: "PlayStation"),
                FavoriteGame(title: "Persona 5", platform: "PlayStation"),
                FavoriteGame(title: "Fire Emblem", platform: "Nintendo Switch")
            ],
            gameGenres: ["JRPG", "Strategy", "Tabletop"],
            playStyle: PlayStyle.social.rawValue,
            skillLevel: SkillLevel.intermediate.rawValue,
            voiceChatPreference: VoiceChatPreference.preferred.rawValue,
            lookingFor: [LookingForType.dndGroup.rawValue, LookingForType.gamingCommunity.rawValue],
            isPremium: false,
            isVerified: false
        ),

        User(
            id: "test_user_4",
            email: "alex.rodriguez@test.com",
            fullName: "Alex Rodriguez",
            gamerTag: "AlexPro",
            bio: "Esports aspirant 🏆 | Top 500 in Overwatch | Building a competitive team!",
            location: "Berkeley",
            country: "USA",
            latitude: 37.8715,
            longitude: -122.2730,
            photos: [
                "https://picsum.photos/seed/alex1/400/500",
                "https://picsum.photos/seed/alex2/400/500",
                "https://picsum.photos/seed/alex3/400/500",
                "https://picsum.photos/seed/alex4/400/500",
                "https://picsum.photos/seed/alex5/400/500"
            ],
            profileImageURL: "https://picsum.photos/seed/alex1/400/500",
            platforms: ["PC"],
            favoriteGames: [
                FavoriteGame(title: "Overwatch 2", platform: "PC", rank: "Top 500"),
                FavoriteGame(title: "League of Legends", platform: "PC", rank: "Grandmaster"),
                FavoriteGame(title: "Counter-Strike 2", platform: "PC", rank: "Global Elite")
            ],
            gameGenres: ["FPS", "MOBA", "Competitive"],
            playStyle: PlayStyle.competitive.rawValue,
            skillLevel: SkillLevel.professional.rawValue,
            voiceChatPreference: VoiceChatPreference.always.rawValue,
            lookingFor: [LookingForType.esportsTeam.rawValue, LookingForType.competitiveTeam.rawValue],
            isPremium: true,
            isVerified: true
        ),

        User(
            id: "test_user_5",
            email: "jessica.lee@test.com",
            fullName: "Jessica Lee",
            gamerTag: "JessGames",
            bio: "Board game collector 🎲 | Love game nights | Always down for Catan or Ticket to Ride!",
            location: "San Francisco",
            country: "USA",
            latitude: 37.7649,
            longitude: -122.4294,
            photos: [
                "https://picsum.photos/seed/jessica1/400/500",
                "https://picsum.photos/seed/jessica2/400/500",
                "https://picsum.photos/seed/jessica3/400/500",
                "https://picsum.photos/seed/jessica4/400/500",
                "https://picsum.photos/seed/jessica5/400/500",
                "https://picsum.photos/seed/jessica6/400/500"
            ],
            profileImageURL: "https://picsum.photos/seed/jessica1/400/500",
            platforms: ["Nintendo Switch", "Mobile"],
            favoriteGames: [
                FavoriteGame(title: "Catan Universe", platform: "Mobile"),
                FavoriteGame(title: "Mario Party", platform: "Nintendo Switch"),
                FavoriteGame(title: "Jackbox Party Pack", platform: "Nintendo Switch")
            ],
            gameGenres: ["Board Games", "Party", "Casual"],
            playStyle: PlayStyle.social.rawValue,
            skillLevel: SkillLevel.beginner.rawValue,
            voiceChatPreference: VoiceChatPreference.optional.rawValue,
            lookingFor: [LookingForType.boardGameGroup.rawValue, LookingForType.casualCoOp.rawValue],
            isPremium: false,
            isVerified: true
        )
    ]

    // MARK: - Test Matches

    static let testMatches: [(user: User, match: Match)] = [
        (
            user: discoverUsers[0], // Sarah
            match: Match(
                id: "match_1",
                user1Id: "current_user",
                user2Id: "test_user_1",
                timestamp: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                lastMessageTimestamp: Date().addingTimeInterval(-3600 * 2), // 2 hours ago
                lastMessage: "GG! That was a great match! Same time tomorrow? 🎮",
                lastMessageSenderId: "test_user_1", // Sarah sent last - RECEIVED
                unreadCount: ["current_user": 2],
                isActive: true
            )
        ),
        (
            user: discoverUsers[1], // Mike
            match: Match(
                id: "match_2",
                user1Id: "current_user",
                user2Id: "test_user_2",
                timestamp: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                lastMessageTimestamp: Date().addingTimeInterval(-3600 * 8), // 8 hours ago
                lastMessage: "Hey, want to play some Stardew Valley co-op this weekend?",
                lastMessageSenderId: "current_user", // You sent last - SENT
                unreadCount: [:],
                isActive: true
            )
        ),
        (
            user: discoverUsers[2], // Emma
            match: Match(
                id: "match_3",
                user1Id: "current_user",
                user2Id: "test_user_3",
                timestamp: Date().addingTimeInterval(-86400), // 1 day ago
                lastMessageTimestamp: Date().addingTimeInterval(-3600 * 5), // 5 hours ago
                lastMessage: "I'd love to join your D&D campaign! What day do you usually play?",
                lastMessageSenderId: "current_user", // You sent last - SENT
                unreadCount: [:],
                isActive: true
            )
        ),
        (
            user: discoverUsers[3], // Alex - New match, no messages yet
            match: Match(
                id: "match_4",
                user1Id: "current_user",
                user2Id: "test_user_4",
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                lastMessageTimestamp: nil,
                lastMessage: nil,
                lastMessageSenderId: nil, // New match - no messages - RECEIVED (needs action)
                unreadCount: [:],
                isActive: true
            )
        ),
        (
            user: discoverUsers[4], // Jessica
            match: Match(
                id: "match_5",
                user1Id: "current_user",
                user2Id: "test_user_5",
                timestamp: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                lastMessageTimestamp: Date().addingTimeInterval(-60 * 10), // 10 mins ago
                lastMessage: "Board game night this Saturday! You in? 🎲",
                lastMessageSenderId: "test_user_5", // Jessica sent last - RECEIVED
                unreadCount: ["current_user": 1],
                isActive: true
            )
        )
    ]

    // MARK: - Test Messages

    static func messagesForMatch(_ matchId: String) -> [Message] {
        switch matchId {
        case "match_1": // Sarah
            return [
                Message(
                    id: "msg_1_1",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_1",
                    text: "Hey Sarah! Saw you're Diamond in Valorant. I'm Plat 3, looking to climb. Want to duo?",
                    timestamp: Date().addingTimeInterval(-86400 * 2),
                    isRead: true
                ),
                Message(
                    id: "msg_1_2",
                    matchId: matchId,
                    senderId: "test_user_1",
                    receiverId: "current_user",
                    text: "Hey! Yeah I'd be down! What agents do you main?",
                    timestamp: Date().addingTimeInterval(-86400 * 2 + 600),
                    isRead: true
                ),
                Message(
                    id: "msg_1_3",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_1",
                    text: "I usually play Sova or Omen. Flex between initiator and controller.",
                    timestamp: Date().addingTimeInterval(-86400 * 2 + 1200),
                    isRead: true
                ),
                Message(
                    id: "msg_1_4",
                    matchId: matchId,
                    senderId: "test_user_1",
                    receiverId: "current_user",
                    text: "Perfect! I main Jett and Reyna. We'd have good synergy! Free tonight?",
                    timestamp: Date().addingTimeInterval(-86400 * 2 + 1800),
                    isRead: true
                ),
                Message(
                    id: "msg_1_5",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_1",
                    text: "Yeah! I can be on around 8pm PST. Send me your Riot ID!",
                    timestamp: Date().addingTimeInterval(-3600 * 3),
                    isRead: true
                ),
                Message(
                    id: "msg_1_6",
                    matchId: matchId,
                    senderId: "test_user_1",
                    receiverId: "current_user",
                    text: "SarahPlays#NA1 - See you then!",
                    timestamp: Date().addingTimeInterval(-3600 * 2.5),
                    isRead: false
                ),
                Message(
                    id: "msg_1_7",
                    matchId: matchId,
                    senderId: "test_user_1",
                    receiverId: "current_user",
                    text: "GG! That was a great match! Same time tomorrow? 🎮",
                    timestamp: Date().addingTimeInterval(-3600 * 2),
                    isRead: false
                )
            ]

        case "match_2": // Mike
            return [
                Message(
                    id: "msg_2_1",
                    matchId: matchId,
                    senderId: "test_user_2",
                    receiverId: "current_user",
                    text: "Hey! Saw you also play co-op games. What have you been playing lately?",
                    timestamp: Date().addingTimeInterval(-86400 * 5),
                    isRead: true
                ),
                Message(
                    id: "msg_2_2",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_2",
                    text: "Just finished It Takes Two! Looking for the next co-op adventure.",
                    timestamp: Date().addingTimeInterval(-86400 * 5 + 1800),
                    isRead: true
                ),
                Message(
                    id: "msg_2_3",
                    matchId: matchId,
                    senderId: "test_user_2",
                    receiverId: "current_user",
                    text: "Nice! Have you tried Stardew Valley multiplayer? It's so chill.",
                    timestamp: Date().addingTimeInterval(-86400 * 5 + 3600),
                    isRead: true
                ),
                Message(
                    id: "msg_2_4",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_2",
                    text: "Hey, want to play some Stardew Valley co-op this weekend?",
                    timestamp: Date().addingTimeInterval(-3600 * 8),
                    isRead: true
                )
            ]

        case "match_3": // Emma
            return [
                Message(
                    id: "msg_3_1",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_3",
                    text: "Hey Emma! I saw you're a DM. I've been wanting to get into D&D!",
                    timestamp: Date().addingTimeInterval(-86400),
                    isRead: true
                ),
                Message(
                    id: "msg_3_2",
                    matchId: matchId,
                    senderId: "test_user_3",
                    receiverId: "current_user",
                    text: "That's awesome! 🎲 I actually have a beginner-friendly campaign starting next month!",
                    timestamp: Date().addingTimeInterval(-86400 + 3600),
                    isRead: true
                ),
                Message(
                    id: "msg_3_3",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_3",
                    text: "That sounds perfect! What edition do you play?",
                    timestamp: Date().addingTimeInterval(-3600 * 6),
                    isRead: true
                ),
                Message(
                    id: "msg_3_4",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_3",
                    text: "I'd love to join your D&D campaign! What day do you usually play?",
                    timestamp: Date().addingTimeInterval(-3600 * 5),
                    isRead: true
                )
            ]

        case "match_4": // Alex
            return [
                Message(
                    id: "msg_4_1",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_4",
                    text: "Hey! Top 500 in Overwatch is insane! What role do you main?",
                    timestamp: Date().addingTimeInterval(-1800),
                    isRead: true
                )
            ]

        case "match_5": // Jessica
            return [
                Message(
                    id: "msg_5_1",
                    matchId: matchId,
                    senderId: "test_user_5",
                    receiverId: "current_user",
                    text: "Hey! Saw you're interested in board games too! 🎲",
                    timestamp: Date().addingTimeInterval(-86400 * 3),
                    isRead: true
                ),
                Message(
                    id: "msg_5_2",
                    matchId: matchId,
                    senderId: "current_user",
                    receiverId: "test_user_5",
                    text: "Yes! I love Catan and Ticket to Ride. What's your favorite?",
                    timestamp: Date().addingTimeInterval(-86400 * 3 + 7200),
                    isRead: true
                ),
                Message(
                    id: "msg_5_3",
                    matchId: matchId,
                    senderId: "test_user_5",
                    receiverId: "current_user",
                    text: "Catan is a classic! I also love Wingspan and Azul.",
                    timestamp: Date().addingTimeInterval(-86400 * 2),
                    isRead: true
                ),
                Message(
                    id: "msg_5_4",
                    matchId: matchId,
                    senderId: "test_user_5",
                    receiverId: "current_user",
                    text: "Board game night this Saturday! You in? 🎲",
                    timestamp: Date().addingTimeInterval(-60 * 10),
                    isRead: false
                )
            ]

        default:
            return []
        }
    }

    // MARK: - Test Likes Data

    /// Users who liked the current user (for "Liked Me" tab)
    static let usersWhoLikedMe: [User] = [
        discoverUsers[0], // Sarah
        discoverUsers[2], // Emma
        discoverUsers[4]  // Jessica
    ]

    /// Users the current user liked (for "My Likes" tab)
    static let usersILiked: [User] = [
        discoverUsers[0], // Sarah - mutual
        discoverUsers[1], // Mike
        discoverUsers[2], // Emma - mutual
        discoverUsers[3], // Alex
        discoverUsers[4]  // Jessica - mutual
    ]

    /// Mutual likes (both liked each other) - for "Mutual Likes" tab
    static let mutualLikes: [User] = [
        discoverUsers[0], // Sarah
        discoverUsers[2], // Emma
        discoverUsers[4]  // Jessica
    ]

    // MARK: - Test Profile Viewers Data

    /// Users who viewed the current user's profile (for Profile Viewers page)
    static let profileViewers: [(user: User, timestamp: Date)] = [
        (discoverUsers[0], Date().addingTimeInterval(-3600)),        // Sarah - 1 hour ago
        (discoverUsers[1], Date().addingTimeInterval(-3600 * 3)),    // Mike - 3 hours ago
        (discoverUsers[2], Date().addingTimeInterval(-3600 * 8)),    // Emma - 8 hours ago
        (discoverUsers[3], Date().addingTimeInterval(-86400)),       // Alex - 1 day ago
        (discoverUsers[4], Date().addingTimeInterval(-86400 * 2)),   // Jessica - 2 days ago
        (discoverUsers[0], Date().addingTimeInterval(-86400 * 4)),   // Sarah again - 4 days ago
        (discoverUsers[1], Date().addingTimeInterval(-86400 * 6))    // Mike again - 6 days ago
    ]

    // MARK: - Helper to get current user for testing

    static let currentUser = User(
        id: "current_user",
        email: "you@test.com",
        fullName: "Kevin Perez",
        gamerTag: "KevinPlays",
        bio: "iOS Developer by day, gamer by night! 🎮 Love FPS games and co-op adventures. Always down to play!",
        location: "San Francisco",
        country: "USA",
        latitude: 37.7749,
        longitude: -122.4194,
        photos: [
            "https://picsum.photos/seed/kevin1/400/500",
            "https://picsum.photos/seed/kevin2/400/500",
            "https://picsum.photos/seed/kevin3/400/500"
        ],
        profileImageURL: "https://picsum.photos/seed/kevin1/400/500",
        platforms: ["PC", "PlayStation", "Nintendo Switch"],
        favoriteGames: [
            FavoriteGame(title: "Valorant", platform: "PC", rank: "Platinum 3"),
            FavoriteGame(title: "Stardew Valley", platform: "PC"),
            FavoriteGame(title: "Mario Kart 8", platform: "Nintendo Switch")
        ],
        gameGenres: ["FPS", "Co-op", "Racing"],
        playStyle: PlayStyle.casual.rawValue,
        skillLevel: SkillLevel.intermediate.rawValue,
        voiceChatPreference: VoiceChatPreference.preferred.rawValue,
        lookingFor: [LookingForType.rankedTeammates.rawValue, LookingForType.casualCoOp.rawValue],
        isPremium: true,
        isVerified: true
    )
}

#endif
