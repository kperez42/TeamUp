//
//  ImprovedUserCard.swift
//  TeamUp
//
//  Enhanced gamer profile card with depth, shadows, and smooth gestures
//  For finding gaming teammates and friends
//  ACCESSIBILITY: Full VoiceOver support, Dynamic Type, Reduce Motion, and WCAG 2.1 AA compliant
//

import SwiftUI

struct ImprovedUserCard: View {
    let user: User
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    private let swipeThreshold: CGFloat = 100

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main card
            cardContent

            // Swipe indicators
            swipeIndicators

            // Bottom gradient info overlay
            bottomInfoOverlay
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .conditionalShadow(enabled: true)
        .scaleEffect(scale)
        .offset(offset)
        .rotationEffect(.degrees(reduceMotion ? 0 : rotation))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(user.gamerTag.isEmpty ? user.fullName : user.gamerTag), \(user.skillLevel)")
        .accessibilityValue(buildAccessibilityValue())
        .accessibilityHint("Swipe right to team up, swipe left to pass, or tap for gaming profile")
        .accessibilityIdentifier(AccessibilityIdentifier.userCard)
        .accessibilityActions([
            AccessibilityCustomAction(name: "Send Team Up Request") {
                onSwipe(.right)
            },
            AccessibilityCustomAction(name: "Pass") {
                onSwipe(.left)
            },
            AccessibilityCustomAction(name: "View Gaming Profile") {
                onTap()
            }
        ])
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    rotation = Double(gesture.translation.width / 20)

                    // Slight scale down when dragging
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        scale = 0.95
                    }
                }
                .onEnded { gesture in
                    let horizontalSwipe = gesture.translation.width

                    if abs(horizontalSwipe) > swipeThreshold {
                        // Complete the swipe
                        let direction: SwipeDirection = horizontalSwipe > 0 ? .right : .left

                        let animation: Animation? = reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7)
                        withAnimation(animation) {
                            offset = CGSize(
                                width: horizontalSwipe > 0 ? 500 : -500,
                                height: gesture.translation.height
                            )
                            rotation = reduceMotion ? 0 : (horizontalSwipe > 0 ? 20 : -20)
                        }

                        // Announce action to VoiceOver
                        VoiceOverAnnouncement.announce(direction == .right ? "Team up request sent" : "Passed")

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipe(direction)
                            resetCard()
                        }

                        HapticManager.shared.impact(.medium)
                    } else {
                        // Snap back
                        let animation: Animation? = reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7)
                        withAnimation(animation) {
                            offset = .zero
                            rotation = 0
                            scale = 1.0
                        }
                    }
                }
        )
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image or gradient - PERFORMANCE: Use CachedAsyncImage for smooth scrolling
                if let imageURL = URL(string: user.profileImageURL), !user.profileImageURL.isEmpty {
                    CachedAsyncImage(
                        url: imageURL,
                        content: { image in
                            image
                                .resizable()
                                .interpolation(.high)
                                .antialiased(true)
                                .renderingMode(.original)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .crispImageRendering()
                        },
                        placeholder: {
                            placeholderGradient
                        }
                    )
                } else {
                    placeholderGradient
                        .overlay {
                            Text(user.gamerTag.isEmpty ? user.fullName.prefix(1) : user.gamerTag.prefix(1))
                                .font(.system(size: 120, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                }

                // Online Status Indicator - Top Right
                VStack {
                    HStack {
                        Spacer()
                        OnlineStatusIndicator(user: user)
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                    }
                    Spacer()
                }
            }
        }
    }

    private var placeholderGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.7),
                Color.blue.opacity(0.6),
                Color.teal.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Swipe Indicators

    private var swipeIndicators: some View {
        ZStack {
            // TEAM UP indicator (right swipe)
            if offset.width > 20 {
                SwipeLabel(
                    text: "TEAM UP",
                    icon: "gamecontroller.fill",
                    color: .blue,
                    rotation: -15
                )
                .opacity(min(Double(offset.width / swipeThreshold), 1.0))
                .offset(x: -100, y: -200)
            }

            // PASS indicator (left swipe)
            if offset.width < -20 {
                SwipeLabel(
                    text: "PASS",
                    icon: "xmark",
                    color: .red,
                    rotation: 15
                )
                .opacity(min(Double(-offset.width / swipeThreshold), 1.0))
                .offset(x: 100, y: -200)
            }
        }
    }

    // MARK: - Bottom Info Overlay

    private var bottomInfoOverlay: some View {
        VStack(alignment: .leading, spacing: 10) {
            // GamerTag and badges
            HStack(alignment: .center, spacing: 8) {
                Text(user.gamerTag.isEmpty ? user.fullName : user.gamerTag)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .dynamicTypeSize(min: .large, max: .accessibility2)

                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .accessibilityLabel("Verified")
                }

                if user.isPremium {
                    Image(systemName: "crown.fill")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                        .accessibilityLabel("Premium member")
                }

                Spacer()
            }
            .accessibilityElement(children: .combine)

            // Skill Level & Play Style
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text(user.skillLevel)
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.yellow)

                HStack(spacing: 4) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.caption)
                    Text(user.playStyle)
                        .font(.subheadline)
                }
                .foregroundColor(.white.opacity(0.9))
            }

            // Bio preview
            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 : 2)
                    .padding(.top, 4)
                    .dynamicTypeSize(min: .small, max: .accessibility1)
                    .accessibilityLabel("Bio: \(user.bio)")
            }

            // Gaming info chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Platforms
                    ForEach(user.platforms.prefix(3), id: \.self) { platform in
                        InfoChip(icon: platformIcon(for: platform), text: platform)
                            .accessibilityLabel("Platform: \(platform)")
                    }

                    // Favorite Games
                    ForEach(user.favoriteGames.prefix(2), id: \.id) { game in
                        InfoChip(icon: "gamecontroller", text: game.title)
                            .accessibilityLabel("Plays \(game.title)")
                    }

                    // Voice Chat Preference
                    InfoChip(icon: voiceChatIcon, text: user.voiceChatPreference)
                        .accessibilityLabel("Voice chat: \(user.voiceChatPreference)")

                    // Show Me (first one)
                    if let firstLookingFor = user.lookingFor.first {
                        InfoChip(icon: "person.2.fill", text: firstLookingFor)
                            .accessibilityLabel("Show Me: \(firstLookingFor)")
                    }

                    // Region if available
                    if let region = user.region {
                        InfoChip(icon: "globe", text: region)
                            .accessibilityLabel("Region: \(region)")
                    }
                }
            }
            .padding(.top, 8)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Gaming details and platforms")

            // Games in common indicator (if we have current user context)
            if !user.favoriteGames.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(user.favoriteGames.count) games listed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 4)
            }

            // Tap to view more
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle")
                        .font(.caption)
                        .accessibilityHidden(true)
                    Text("Tap to view gaming profile")
                        .font(.caption)
                        .fontWeight(.medium)
                        .dynamicTypeSize(min: .xSmall, max: .large)
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.4), Color.teal.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
                Spacer()
            }
            .padding(.top, 8)
            .accessibilityHidden(true)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Helper Properties

    private var voiceChatIcon: String {
        switch user.voiceChatPreference {
        case VoiceChatPreference.always.rawValue, VoiceChatPreference.preferred.rawValue:
            return "mic.fill"
        case VoiceChatPreference.textOnly.rawValue:
            return "mic.slash"
        default:
            return "mic"
        }
    }

    private func platformIcon(for platform: String) -> String {
        switch platform {
        case GamingPlatform.pc.rawValue:
            return "desktopcomputer"
        case GamingPlatform.playstation.rawValue:
            return "gamecontroller"
        case GamingPlatform.xbox.rawValue:
            return "gamecontroller.fill"
        case GamingPlatform.nintendoSwitch.rawValue:
            return "gamecontroller"
        case GamingPlatform.mobile.rawValue:
            return "iphone"
        default:
            return "gamecontroller"
        }
    }

    // MARK: - Helper Functions

    private func resetCard() {
        offset = .zero
        rotation = 0
        scale = 1.0
    }

    /// Builds a comprehensive accessibility value string
    private func buildAccessibilityValue() -> String {
        var components: [String] = []

        if !user.location.isEmpty {
            components.append("from \(user.location)")
        }

        if user.isVerified {
            components.append("verified")
        }

        if user.isPremium {
            components.append("premium member")
        }

        components.append("Skill level: \(user.skillLevel)")
        components.append("Play style: \(user.playStyle)")

        if !user.platforms.isEmpty {
            let platforms = user.platforms.prefix(3).joined(separator: ", ")
            components.append("Platforms: \(platforms)")
        }

        if !user.favoriteGames.isEmpty {
            let games = user.favoriteGames.prefix(3).map { $0.title }.joined(separator: ", ")
            components.append("Games: \(games)")
        }

        if !user.lookingFor.isEmpty {
            let lookingFor = user.lookingFor.joined(separator: ", ")
            components.append("Looking for: \(lookingFor)")
        }

        components.append("Voice chat: \(user.voiceChatPreference)")

        if !user.bio.isEmpty {
            components.append("Bio: \(user.bio)")
        }

        return components.joined(separator: ". ")
    }
}

// MARK: - Info Chip

struct InfoChip: View {
    let icon: String
    let text: String
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .accessibilityHidden(true)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .dynamicTypeSize(min: .xSmall, max: .large)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.25))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Swipe Label

struct SwipeLabel: View {
    let text: String
    var icon: String? = nil
    let color: Color
    let rotation: Double
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        VStack(spacing: 8) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(color)
            }
            Text(text)
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(color)
        }
        .padding(20)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color, lineWidth: 4)
        )
        .rotationEffect(.degrees(reduceMotion ? 0 : rotation))
        .shadow(color: color.opacity(0.5), radius: 10)
        .accessibilityHidden(true) // Visual indicator only, redundant with VoiceOver announcements
    }
}

// MARK: - Swipe Direction

enum SwipeDirection {
    case left, right
}

enum CardSwipeAction {
    case request, pass
}

#Preview {
    ImprovedUserCard(
        user: User(
            email: "test@example.com",
            fullName: "Alex Storm",
            gamerTag: "StormPlayer99",
            bio: "Competitive FPS player looking for ranked teammates. Diamond in Valorant, Masters in Apex. Let's climb!",
            location: "Los Angeles",
            country: "USA",
            profileImageURL: "",
            platforms: ["PC", "PlayStation"],
            favoriteGames: [
                FavoriteGame(title: "Valorant", platform: "PC", rank: "Diamond 2"),
                FavoriteGame(title: "Apex Legends", platform: "PC", rank: "Masters")
            ],
            gameGenres: ["FPS", "Battle Royale"],
            playStyle: PlayStyle.competitive.rawValue,
            skillLevel: SkillLevel.advanced.rawValue,
            voiceChatPreference: VoiceChatPreference.always.rawValue,
            lookingFor: [LookingForType.rankedTeammates.rawValue]
        ),
        onSwipe: { _ in },
        onTap: {}
    )
    .frame(height: 600)
    .padding()
}
