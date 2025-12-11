//
//  CurrentUserProfileCard.swift
//  TeamUp
//
//  Current user's profile card for display at top of discover feed
//  Tappable to navigate to full ProfileView for viewing and editing
//

import SwiftUI

struct CurrentUserProfileCard: View {
    let user: User
    let onTap: () -> Void

    // Get the best available photo URL (photos array first, then profileImageURL)
    private var displayPhotoURL: String {
        if let firstPhoto = user.photos.first, !firstPhoto.isEmpty {
            return firstPhoto
        }
        return user.profileImageURL
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Profile Image with badge
            ZStack(alignment: .topTrailing) {
                CachedCardImage(url: URL(string: displayPhotoURL))
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(16, corners: [.topLeft, .topRight])

                // "Your Profile" badge
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white)

                    Text("Your Profile")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
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
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                .padding(12)
            }

            // Simple user info and tap hint
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if !user.gamerTag.isEmpty {
                        Text("@\(user.gamerTag)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }

                if user.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.body)
                        .foregroundColor(.blue)
                }

                Spacer()

                // Tap hint
                HStack(spacing: 4) {
                    Text("View Profile")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .teal.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.impact(.medium)
            onTap()
        }
    }
}

#Preview {
    ScrollView {
        CurrentUserProfileCard(
            user: User(
                email: "me@test.com",
                fullName: "John Doe",
                gamerTag: "JDGamer",
                bio: "Tech enthusiast and competitive gamer",
                location: "Los Angeles",
                country: "USA",
                photos: [
                    "https://example.com/photo1.jpg",
                    "https://example.com/photo2.jpg",
                    "https://example.com/photo3.jpg"
                ],
                platforms: ["PC", "PlayStation", "Xbox"],
                playStyle: PlayStyle.competitive.rawValue,
                skillLevel: SkillLevel.advanced.rawValue,
                lookingFor: [LookingForType.rankedTeammates.rawValue]
            ),
            onTap: {
                print("Navigate to profile")
            }
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
