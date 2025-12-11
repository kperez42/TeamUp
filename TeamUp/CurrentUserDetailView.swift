//
//  CurrentUserDetailView.swift
//  TeamUp
//
//  Detail view for viewing own profile (similar to how other users see you)
//

import SwiftUI

struct CurrentUserDetailView: View {
    let user: User
    @Environment(\.dismiss) var dismiss

    @State private var showingEditProfile = false
    @State private var selectedPhotoIndex = 0
    @State private var showingPhotoViewer = false

    var onEditProfile: (() -> Void)?
    var onViewFullProfile: (() -> Void)?

    // Filter out empty photo URLs
    private var validPhotos: [String] {
        let photos = user.photos.isEmpty ? [user.profileImageURL] : user.photos
        return photos.filter { !$0.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photos carousel with tap to view full screen
                ZStack(alignment: .topTrailing) {
                    TabView(selection: $selectedPhotoIndex) {
                        ForEach(validPhotos.indices, id: \.self) { index in
                            CachedCardImage(url: URL(string: validPhotos[index]))
                                .frame(height: 400)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .onTapGesture {
                                    showingPhotoViewer = true
                                }
                                .tag(index)
                        }
                    }
                    .frame(height: 400)
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))

                    // "Your Profile" badge
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.caption)
                        Text("Your Profile")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.blue, .teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .padding(16)
                }

                // Profile info
                VStack(alignment: .leading, spacing: 24) {
                    // Name and gamer tag
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Text(user.gamerTag.isEmpty ? user.fullName : user.gamerTag)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text(user.skillLevel)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if user.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }

                        // Location
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                            Text("\(user.location), \(user.country)")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)

                        // Photo count
                        HStack(spacing: 6) {
                            Image(systemName: "photo.stack.fill")
                                .foregroundColor(.blue)
                            Text("\(validPhotos.count) photo\(validPhotos.count == 1 ? "" : "s")")
                                .foregroundColor(.secondary)
                        }
                        .font(.caption)
                    }

                    // Bio section
                    if !user.bio.isEmpty {
                        ProfileSectionCard(
                            icon: "quote.bubble.fill",
                            title: "About",
                            iconColors: [.blue, .teal],
                            borderColor: .blue
                        ) {
                            Text(user.bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                    }

                    // Platforms section
                    if !user.platforms.isEmpty {
                        ProfileSectionCard(
                            icon: "gamecontroller.fill",
                            title: "Platforms",
                            iconColors: [.blue, .teal],
                            borderColor: .blue
                        ) {
                            FlowLayout2(spacing: 10) {
                                ForEach(user.platforms, id: \.self) { platform in
                                    ProfileTagView(text: platform, colors: [.blue, .teal], textColor: .blue)
                                }
                            }
                        }
                    }

                    // Favorite Games section
                    if !user.favoriteGames.isEmpty {
                        ProfileSectionCard(
                            icon: "sparkles",
                            title: "Favorite Games",
                            iconColors: [.orange, .teal],
                            borderColor: .orange
                        ) {
                            FlowLayout2(spacing: 10) {
                                ForEach(user.favoriteGames, id: \.id) { game in
                                    ProfileTagView(text: game.title, colors: [.orange, .teal], textColor: .orange)
                                }
                            }
                        }
                    }

                    // Prompts section
                    if !user.prompts.isEmpty {
                        ProfileSectionCard(
                            icon: "quote.bubble.fill",
                            title: "Get to Know Me",
                            iconColors: [.blue, .teal],
                            borderColor: .blue
                        ) {
                            VStack(spacing: 12) {
                                ForEach(user.prompts) { prompt in
                                    PromptCard(prompt: prompt)
                                }
                            }
                        }
                    }

                    // Gaming Details section
                    ProfileSectionCard(
                        icon: "person.text.rectangle",
                        title: "Gaming Details",
                        iconColors: [.blue, .teal],
                        borderColor: .indigo
                    ) {
                        VStack(spacing: 12) {
                            DetailRow(icon: "star.fill", label: "Skill Level", value: user.skillLevel)
                            DetailRow(icon: "flame.fill", label: "Play Style", value: user.playStyle)
                            DetailRow(icon: "mic.fill", label: "Voice Chat", value: user.voiceChatPreference)
                            if let region = user.region {
                                DetailRow(icon: "globe", label: "Region", value: region)
                            }
                        }
                    }

                    // Gaming Schedule section
                    if !user.gamingSchedule.preferredDays.isEmpty || user.gamingSchedule.weekdayStart != nil {
                        ProfileSectionCard(
                            icon: "clock.fill",
                            title: "Gaming Schedule",
                            iconColors: [.blue, .mint],
                            borderColor: .blue
                        ) {
                            VStack(spacing: 12) {
                                DetailRow(icon: "globe.americas", label: "Timezone", value: user.gamingSchedule.timezone)
                                if let weekdayStart = user.gamingSchedule.weekdayStart, let weekdayEnd = user.gamingSchedule.weekdayEnd {
                                    DetailRow(icon: "calendar", label: "Weekdays", value: "\(weekdayStart) - \(weekdayEnd)")
                                }
                                if let weekendStart = user.gamingSchedule.weekendStart, let weekendEnd = user.gamingSchedule.weekendEnd {
                                    DetailRow(icon: "calendar.badge.clock", label: "Weekends", value: "\(weekendStart) - \(weekendEnd)")
                                }
                                if !user.gamingSchedule.preferredDays.isEmpty {
                                    DetailRow(icon: "checkmark.circle", label: "Days", value: user.gamingSchedule.preferredDays.joined(separator: ", "))
                                }
                            }
                        }
                    }

                    // Show Me section
                    if !user.lookingFor.isEmpty {
                        ProfileSectionCard(
                            icon: "person.2.fill",
                            title: "Show Me",
                            iconColors: [.blue, .teal],
                            borderColor: .blue
                        ) {
                            FlowLayout2(spacing: 10) {
                                ForEach(user.lookingFor, id: \.self) { goal in
                                    ProfileTagView(text: goal, colors: [.blue, .teal], textColor: .blue)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
                .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .bottom) {
            // Action buttons
            HStack(spacing: 20) {
                // Close button
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

                // Edit Profile button
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onEditProfile?()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.title3)
                        Text("Edit")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(width: 120, height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.4), radius: 10)
                }
                .accessibilityLabel("Edit Profile")
            }
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $showingPhotoViewer) {
            PhotoViewerView(
                photos: validPhotos,
                selectedIndex: $selectedPhotoIndex
            )
        }
    }

}

#Preview {
    CurrentUserDetailView(
        user: User(
            email: "test@example.com",
            fullName: "John Doe",
            gamerTag: "JDGamer",
            bio: "Competitive FPS player looking for ranked teammates. Love Valorant and Apex!",
            location: "San Francisco",
            country: "USA",
            platforms: ["PC", "PlayStation"],
            favoriteGames: [
                FavoriteGame(title: "Valorant", platform: "PC", rank: "Diamond 2"),
                FavoriteGame(title: "Apex Legends", platform: "PC")
            ],
            playStyle: PlayStyle.competitive.rawValue,
            skillLevel: SkillLevel.advanced.rawValue,
            lookingFor: [LookingForType.rankedTeammates.rawValue, LookingForType.competitiveTeam.rawValue]
        )
    )
}
