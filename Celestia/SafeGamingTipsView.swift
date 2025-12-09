//
//  SafeGamingTipsView.swift
//  TeamUp
//
//  Safety tips and resources for online gaming
//

import SwiftUI

struct SafeGamingTipsView: View {
    @State private var selectedCategory: GamingTipCategory = .accountSafety

    var body: some View {
        VStack(spacing: 0) {
            // Category Picker
            categoryPicker

            // Tips List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(GamingSafetyTip.tips(for: selectedCategory)) { tip in
                        GamingSafetyTipCard(tip: tip)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Online Safety Tips")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(GamingTipCategory.allCases, id: \.self) { category in
                    GamingCategoryTab(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Category Tab

struct GamingCategoryTab: View {
    let category: GamingTipCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.title)
                    .font(.caption.bold())
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                LinearGradient(
                    colors: [.green, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0.05), radius: 5, y: 2)
        }
    }
}

// MARK: - Safety Tip Card

struct GamingSafetyTipCard: View {
    let tip: GamingSafetyTip

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tip.priority.color.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: tip.icon)
                        .font(.title3)
                        .foregroundColor(tip.priority.color)
                }

                Text(tip.title)
                    .font(.headline)

                Spacer()

                if tip.priority == .critical {
                    Text("IMPORTANT")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(6)
                }
            }

            // Description
            Text(tip.description)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Action items if present
            if !tip.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tip.actionItems, id: \.self) { item in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)

                            Text(item)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(12)
                .background(Color.green.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Models

enum GamingTipCategory: CaseIterable {
    case accountSafety
    case voiceChat
    case meetingPlayers
    case scamPrevention
    case resources

    var title: String {
        switch self {
        case .accountSafety: return "Account"
        case .voiceChat: return "Voice Chat"
        case .meetingPlayers: return "Meeting Up"
        case .scamPrevention: return "Scams"
        case .resources: return "Resources"
        }
    }

    var icon: String {
        switch self {
        case .accountSafety: return "lock.shield"
        case .voiceChat: return "mic.fill"
        case .meetingPlayers: return "person.2.fill"
        case .scamPrevention: return "exclamationmark.triangle.fill"
        case .resources: return "link"
        }
    }
}

enum GamingTipPriority {
    case critical
    case important
    case helpful

    var color: Color {
        switch self {
        case .critical: return .red
        case .important: return .orange
        case .helpful: return .green
        }
    }
}

struct GamingSafetyTip: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let priority: GamingTipPriority
    let actionItems: [String]

    static func tips(for category: GamingTipCategory) -> [GamingSafetyTip] {
        switch category {
        case .accountSafety:
            return [
                GamingSafetyTip(
                    icon: "lock.fill",
                    title: "Use Strong Passwords",
                    description: "Use unique passwords for gaming accounts. Enable 2FA wherever possible.",
                    priority: .critical,
                    actionItems: [
                        "Use a password manager",
                        "Enable two-factor authentication",
                        "Never reuse passwords"
                    ]
                ),
                GamingSafetyTip(
                    icon: "eye.slash.fill",
                    title: "Protect Personal Info",
                    description: "Don't share your real name, location, school, or workplace with strangers online.",
                    priority: .critical,
                    actionItems: [
                        "Use a gamer tag, not your real name",
                        "Don't share your address",
                        "Be vague about your location"
                    ]
                ),
                GamingSafetyTip(
                    icon: "link.badge.plus",
                    title: "Secure Linked Accounts",
                    description: "Review which apps have access to your gaming accounts and revoke unnecessary permissions.",
                    priority: .important,
                    actionItems: [
                        "Check Steam/Xbox/PSN linked apps",
                        "Remove old authorizations",
                        "Review Discord bot permissions"
                    ]
                ),
                GamingSafetyTip(
                    icon: "envelope.badge.shield.half.filled",
                    title: "Watch for Phishing",
                    description: "Fake 'Steam Guard' emails and Discord DMs are common. Always verify URLs before clicking.",
                    priority: .important,
                    actionItems: [
                        "Check sender email addresses",
                        "Don't click suspicious links",
                        "Go directly to official sites"
                    ]
                )
            ]

        case .voiceChat:
            return [
                GamingSafetyTip(
                    icon: "mic.slash.fill",
                    title: "Control What You Share",
                    description: "Be mindful of background noise and conversations that might reveal personal information.",
                    priority: .important,
                    actionItems: [
                        "Use push-to-talk when possible",
                        "Check what's audible in your space",
                        "Mute when not speaking"
                    ]
                ),
                GamingSafetyTip(
                    icon: "hand.raised.fill",
                    title: "Handle Toxicity",
                    description: "You can always mute, block, or leave. No game is worth enduring harassment.",
                    priority: .critical,
                    actionItems: [
                        "Use mute liberally",
                        "Report toxic players",
                        "Leave toxic environments"
                    ]
                ),
                GamingSafetyTip(
                    icon: "waveform",
                    title: "Voice Changers Are OK",
                    description: "Using a voice changer for privacy is perfectly acceptable. Your comfort matters.",
                    priority: .helpful,
                    actionItems: [
                        "Consider voice modulation software",
                        "Set boundaries you're comfortable with",
                        "You don't owe anyone your real voice"
                    ]
                ),
                GamingSafetyTip(
                    icon: "person.crop.circle.badge.minus",
                    title: "Trust Your Instincts",
                    description: "If someone makes you uncomfortable, trust that feeling. You don't need a 'good reason' to disconnect.",
                    priority: .important,
                    actionItems: [
                        "It's OK to leave mid-game",
                        "Block without explanation",
                        "Your safety comes first"
                    ]
                )
            ]

        case .meetingPlayers:
            return [
                GamingSafetyTip(
                    icon: "person.2.badge.gearshape",
                    title: "LAN Parties & Meetups",
                    description: "If meeting online friends IRL, always meet in public places first.",
                    priority: .critical,
                    actionItems: [
                        "Meet at gaming cafes or conventions",
                        "Bring a friend the first time",
                        "Tell someone where you're going"
                    ]
                ),
                GamingSafetyTip(
                    icon: "video.fill",
                    title: "Video Chat First",
                    description: "Before meeting in person, video chat to verify they are who they say they are.",
                    priority: .important,
                    actionItems: [
                        "Use Discord video call",
                        "Verify they match their profile",
                        "Build trust over time"
                    ]
                ),
                GamingSafetyTip(
                    icon: "calendar.badge.clock",
                    title: "Take Your Time",
                    description: "There's no rush to meet IRL. Get to know people online first over weeks or months.",
                    priority: .helpful,
                    actionItems: [
                        "Play together regularly first",
                        "Voice chat before video",
                        "Build genuine connection"
                    ]
                ),
                GamingSafetyTip(
                    icon: "location.slash.fill",
                    title: "Protect Your Location",
                    description: "Don't share your home address. Meet at neutral gaming venues or public spaces.",
                    priority: .critical,
                    actionItems: [
                        "Never invite strangers home",
                        "Use gaming cafes for meetups",
                        "Keep your address private"
                    ]
                )
            ]

        case .scamPrevention:
            return [
                GamingSafetyTip(
                    icon: "dollarsign.circle.fill",
                    title: "Free V-Bucks/Skins Scams",
                    description: "There's no such thing as free premium currency generators. These are always scams.",
                    priority: .critical,
                    actionItems: [
                        "Never enter credentials on third-party sites",
                        "Report scam links",
                        "Only buy from official stores"
                    ]
                ),
                GamingSafetyTip(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Trade Scams",
                    description: "Use official trading systems. Middleman scams and 'trust trades' are how people lose valuable items.",
                    priority: .critical,
                    actionItems: [
                        "Use Steam's official trading",
                        "Never 'trust trade' items",
                        "If it seems too good, it's a scam"
                    ]
                ),
                GamingSafetyTip(
                    icon: "trophy.fill",
                    title: "Boosting Services",
                    description: "Account boosting services often steal accounts. Plus, it's against most games' TOS.",
                    priority: .important,
                    actionItems: [
                        "Never share your password",
                        "Earn your rank legitimately",
                        "Report boosting advertisements"
                    ]
                ),
                GamingSafetyTip(
                    icon: "person.fill.questionmark",
                    title: "Impersonation Scams",
                    description: "Scammers impersonate streamers, pro players, and tournament organizers. Verify identities.",
                    priority: .important,
                    actionItems: [
                        "Check official social media",
                        "Verify through multiple channels",
                        "Real pros don't DM for money"
                    ]
                )
            ]

        case .resources:
            return [
                GamingSafetyTip(
                    icon: "shield.checkered",
                    title: "Report In-Game",
                    description: "Most games have reporting systems. Use them - reports do get reviewed.",
                    priority: .important,
                    actionItems: [
                        "Report harassment in-game",
                        "Save evidence (screenshots/clips)",
                        "Block and move on"
                    ]
                ),
                GamingSafetyTip(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Crisis Text Line",
                    description: "Text HOME to 741741 for free, 24/7 crisis support if gaming communities have affected your mental health.",
                    priority: .helpful,
                    actionItems: [
                        "Text HOME to 741741",
                        "Available 24/7",
                        "Confidential support"
                    ]
                ),
                GamingSafetyTip(
                    icon: "network",
                    title: "Platform Safety Centers",
                    description: "Each platform has dedicated safety resources. Know where to find them.",
                    priority: .helpful,
                    actionItems: [
                        "Steam: help.steampowered.com",
                        "Discord: discord.com/safety",
                        "Xbox: support.xbox.com/safety"
                    ]
                ),
                GamingSafetyTip(
                    icon: "brain.head.profile",
                    title: "Gaming & Mental Health",
                    description: "If gaming is affecting your wellbeing, reach out. Balance is important.",
                    priority: .helpful,
                    actionItems: [
                        "Take regular breaks",
                        "Maintain real-life connections",
                        "Seek help if needed"
                    ]
                )
            ]
        }
    }
}

// Backward compatibility alias
typealias SafeDatingTipsView = SafeGamingTipsView

#Preview {
    NavigationStack {
        SafeGamingTipsView()
    }
}
