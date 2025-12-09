//
//  ProfileTip.swift
//  TeamUp
//
//  Model for profile completion tips
//

import Foundation

struct ProfileTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let action: TipAction
    let priority: Int

    enum TipAction {
        case addPhotos
        case writeBio
        case addInterests
        case addLanguages
        case getVerified
    }

    static func generateTips(for user: User) -> [ProfileTip] {
        var tips: [ProfileTip] = []

        // Photo tips
        if user.photos.isEmpty {
            tips.append(ProfileTip(
                icon: "photo.on.rectangle",
                title: "Add Photos",
                description: "Profiles with 3+ photos get 5x more matches",
                action: .addPhotos,
                priority: 1
            ))
        } else if user.photos.count < 3 {
            tips.append(ProfileTip(
                icon: "photo.on.rectangle",
                title: "Add More Photos",
                description: "Add \(3 - user.photos.count) more photos",
                action: .addPhotos,
                priority: 3
            ))
        }

        // Bio tip
        if user.bio.isEmpty {
            tips.append(ProfileTip(
                icon: "text.alignleft",
                title: "Write Your Bio",
                description: "Tell people what makes you unique",
                action: .writeBio,
                priority: 2
            ))
        }

        // Games tip
        if user.favoriteGames.count < 3 {
            tips.append(ProfileTip(
                icon: "gamecontroller.fill",
                title: "Add Games",
                description: "Help people find common games to play",
                action: .addInterests,
                priority: 4
            ))
        }

        // Platforms tip
        if user.platforms.isEmpty {
            tips.append(ProfileTip(
                icon: "desktopcomputer",
                title: "Add Platforms",
                description: "Show which platforms you game on",
                action: .addLanguages,
                priority: 5
            ))
        }

        // Verification tip
        if !user.isVerified {
            tips.append(ProfileTip(
                icon: "checkmark.seal.fill",
                title: "Get Verified",
                description: "Build trust and get 3x more matches",
                action: .getVerified,
                priority: 0
            ))
        }

        return tips.sorted { $0.priority < $1.priority }
    }
}
