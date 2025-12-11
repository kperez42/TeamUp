//
//  EditProfileViewModel.swift
//  TeamUp
//
//  ViewModel for Edit Profile - centralizes state and business logic
//  Extracted from EditProfileView.swift to reduce file size and improve testability
//

import SwiftUI
import PhotosUI

@MainActor
class EditProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    // Basic Info
    @Published var fullName: String
    @Published var gamerTag: String
    @Published var bio: String
    @Published var location: String
    @Published var country: String

    // Gaming-specific
    @Published var platforms: [String]
    @Published var favoriteGames: [FavoriteGame]
    @Published var gameGenres: [String]
    @Published var playStyle: String
    @Published var skillLevel: String
    @Published var voiceChatPreference: String
    @Published var lookingFor: [String]

    // Collections
    @Published var prompts: [ProfilePrompt]
    @Published var photos: [String]

    // UI State
    @Published var newPlatform = ""
    @Published var newGenre = ""
    @Published var isLoading = false
    @Published var showImagePicker = false
    @Published var selectedImage: PhotosPickerItem?
    @Published var profileImage: UIImage?
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    @Published var showPlatformPicker = false
    @Published var showGenrePicker = false
    @Published var showPromptsEditor = false
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var isUploadingPhotos = false
    @Published var uploadProgress: Double = 0.0

    // MARK: - Constants

    let platformOptions = ["PC", "PlayStation", "Xbox", "Nintendo Switch", "Mobile", "Steam Deck"]
    let genreOptions = ["FPS", "RPG", "MMORPG", "Battle Royale", "Strategy", "Sports", "Racing", "Fighting", "Puzzle", "Simulation", "Horror", "Adventure", "Indie"]
    let playStyleOptions = [PlayStyle.casual.rawValue, PlayStyle.competitive.rawValue, PlayStyle.social.rawValue]
    let skillLevelOptions = [SkillLevel.beginner.rawValue, SkillLevel.intermediate.rawValue, SkillLevel.advanced.rawValue, SkillLevel.professional.rawValue]
    let voiceChatOptions = [VoiceChatPreference.always.rawValue, VoiceChatPreference.preferred.rawValue, VoiceChatPreference.sometimes.rawValue, VoiceChatPreference.textOnly.rawValue, VoiceChatPreference.noPreference.rawValue]
    let lookingForOptions = [LookingForType.rankedTeammates.rawValue, LookingForType.casualCoOp.rawValue, LookingForType.boardGameGroup.rawValue, LookingForType.competitiveTeam.rawValue, LookingForType.streamingPartners.rawValue, LookingForType.anyGamers.rawValue]

    // MARK: - Initialization

    init(user: User? = nil) {
        let currentUser = user ?? AuthService.shared.currentUser

        // Initialize basic info
        self.fullName = currentUser?.fullName ?? ""
        self.gamerTag = currentUser?.gamerTag ?? ""
        self.bio = currentUser?.bio ?? ""
        self.location = currentUser?.location ?? ""
        self.country = currentUser?.country ?? ""

        // Initialize gaming fields
        self.platforms = currentUser?.platforms ?? []
        self.favoriteGames = currentUser?.favoriteGames ?? []
        self.gameGenres = currentUser?.gameGenres ?? []
        self.playStyle = currentUser?.playStyle ?? PlayStyle.casual.rawValue
        self.skillLevel = currentUser?.skillLevel ?? SkillLevel.beginner.rawValue
        self.voiceChatPreference = currentUser?.voiceChatPreference ?? VoiceChatPreference.noPreference.rawValue
        self.lookingFor = currentUser?.lookingFor ?? [LookingForType.anyGamers.rawValue]

        // Initialize collections
        self.prompts = currentUser?.prompts ?? []
        self.photos = currentUser?.photos ?? []
    }

    // MARK: - Computed Properties

    var isFormValid: Bool {
        !fullName.isEmpty &&
        !gamerTag.isEmpty &&
        !location.isEmpty &&
        !country.isEmpty
    }

    var completionProgress: Double {
        var completed: Double = 0
        let total: Double = 7

        if !fullName.isEmpty { completed += 1 }
        if !gamerTag.isEmpty { completed += 1 }
        if !bio.isEmpty { completed += 1 }
        if !platforms.isEmpty { completed += 1 }
        if !favoriteGames.isEmpty { completed += 1 }
        if !photos.isEmpty { completed += 1 }
        if !gameGenres.isEmpty { completed += 1 }

        return completed / total
    }

    // MARK: - Actions

    func addPlatform(_ platform: String) {
        guard !platform.isEmpty, !platforms.contains(platform) else { return }
        platforms.append(platform)
        newPlatform = ""
        showPlatformPicker = false
    }

    func removePlatform(_ platform: String) {
        platforms.removeAll { $0 == platform }
    }

    func addGenre(_ genre: String) {
        guard !genre.isEmpty, !gameGenres.contains(genre), gameGenres.count < 10 else { return }
        gameGenres.append(genre)
        newGenre = ""
        showGenrePicker = false
    }

    func removeGenre(_ genre: String) {
        gameGenres.removeAll { $0 == genre }
    }

    func saveProfile(authService: AuthService, completion: @escaping () -> Void) async {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showErrorAlert = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Upload profile image if selected
            if let image = profileImage {
                let imageURL = try await uploadProfileImage(image, authService: authService)
                await updateUserProfile(authService: authService, profileImageURL: imageURL)
            } else {
                await updateUserProfile(authService: authService, profileImageURL: nil)
            }

            showSuccessAlert = true
            HapticManager.shared.notification(.success)

            // Delay dismissal to show success message
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            completion()

        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            HapticManager.shared.notification(.error)
        }
    }

    // MARK: - Private Helpers

    private func uploadProfileImage(_ image: UIImage, authService: AuthService) async throws -> String {
        guard let userId = authService.currentUser?.id else {
            throw NSError(domain: "EditProfile", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        // ImageUploadService.uploadImage expects a directory path
        // It will append its own UUID filename to the path
        return try await ImageUploadService.shared.uploadImage(
            image,
            path: "profile_images/\(userId)"
        )
    }

    private func updateUserProfile(authService: AuthService, profileImageURL: String?) async {
        guard let userId = authService.currentUser?.id else { return }

        var updateData: [String: Any] = [
            "fullName": fullName,
            "gamerTag": gamerTag,
            "bio": bio,
            "location": location,
            "country": country,
            "platforms": platforms,
            "favoriteGames": favoriteGames.map { $0.toDictionary() },
            "gameGenres": gameGenres,
            "playStyle": playStyle,
            "skillLevel": skillLevel,
            "voiceChatPreference": voiceChatPreference,
            "lookingFor": lookingFor,
            "prompts": prompts.map { $0.toDictionary() },
            "photos": photos
        ]

        // Add optional fields if present
        if let profileImageURL = profileImageURL {
            updateData["profileImageURL"] = profileImageURL
        }

        do {
            try await UserService.shared.updateUserFields(userId: userId, fields: updateData)
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
