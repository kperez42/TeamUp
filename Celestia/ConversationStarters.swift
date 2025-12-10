//
//  ConversationStarters.swift
//  TeamUp
//
//  Service for generating smart conversation starters for gamers
//

import Foundation

// MARK: - Conversation Starter Model

struct ConversationStarter: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let category: StarterCategory

    enum StarterCategory {
        case sharedGame
        case sharedPlatform
        case sharedGenre
        case location
        case bio
        case generic
    }
}

// MARK: - Conversation Starters Service

class ConversationStarters {
    static let shared = ConversationStarters()

    private init() {}

    func generateStarters(currentUser: User, otherUser: User) -> [ConversationStarter] {
        var starters: [ConversationStarter] = []

        // Shared favorite games
        let currentGameTitles = Set(currentUser.favoriteGames.map { $0.title.lowercased() })
        let otherGameTitles = otherUser.favoriteGames.map { $0.title }
        if let sharedGame = otherGameTitles.first(where: { currentGameTitles.contains($0.lowercased()) }) {
            starters.append(ConversationStarter(
                text: "I see you play \(sharedGame) too! What's your rank?",
                icon: "gamecontroller.fill",
                category: .sharedGame
            ))
        }

        // Shared platforms
        let sharedPlatforms = Set(currentUser.platforms).intersection(Set(otherUser.platforms))
        if let platform = sharedPlatforms.first {
            starters.append(ConversationStarter(
                text: "Nice, another \(platform) player! What's your gamertag?",
                icon: "display",
                category: .sharedPlatform
            ))
        }

        // Shared game genres
        let sharedGenres = Set(currentUser.gameGenres).intersection(Set(otherUser.gameGenres))
        if let genre = sharedGenres.first {
            starters.append(ConversationStarter(
                text: "I'm into \(genre) games too! What are you playing lately?",
                icon: "star.fill",
                category: .sharedGenre
            ))
        }

        // Location-based
        if !otherUser.location.isEmpty {
            starters.append(ConversationStarter(
                text: "How's the gaming scene in \(otherUser.location)?",
                icon: "mappin.circle.fill",
                category: .location
            ))
        }

        // Bio-based (gaming keywords)
        if !otherUser.bio.isEmpty {
            if otherUser.bio.lowercased().contains("stream") {
                starters.append(ConversationStarter(
                    text: "I saw you stream! What platform do you use?",
                    icon: "video.fill",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("competitive") || otherUser.bio.lowercased().contains("ranked") {
                starters.append(ConversationStarter(
                    text: "Fellow competitive player! What rank are you grinding for?",
                    icon: "trophy.fill",
                    category: .bio
                ))
            } else if otherUser.bio.lowercased().contains("chill") || otherUser.bio.lowercased().contains("casual") {
                starters.append(ConversationStarter(
                    text: "I'm down for some chill gaming sessions! What do you play to unwind?",
                    icon: "cup.and.saucer.fill",
                    category: .bio
                ))
            }
        }

        // Generic gaming starters
        let genericStarters = [
            ConversationStarter(
                text: "What game are you most hyped for right now?",
                icon: "sparkles",
                category: .generic
            ),
            ConversationStarter(
                text: "Do you prefer solo queue or playing with a squad?",
                icon: "person.3.fill",
                category: .generic
            ),
            ConversationStarter(
                text: "What's your all-time favorite game?",
                icon: "gamecontroller",
                category: .generic
            ),
            ConversationStarter(
                text: "Any gaming sessions planned this weekend?",
                icon: "calendar",
                category: .generic
            )
        ]

        // Add generic starters to fill up to 5 total
        let remainingCount = max(0, 5 - starters.count)
        starters.append(contentsOf: genericStarters.prefix(remainingCount))

        return Array(starters.prefix(5))
    }
}
