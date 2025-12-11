//
//  ProfileEnhancementView.swift
//  TeamUp
//
//  Additional gaming profile information collection view
//  Shown after sign-up to help users get better squad matches
//

import SwiftUI
import UIKit

struct ProfileEnhancementView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    // Gaming fields
    @State private var platforms: Set<GamingPlatform> = []
    @State private var gameGenres: Set<GameGenre> = []
    @State private var voiceChatPreference: VoiceChatPreference = .noPreference
    @State private var weeklyHours: Int = 10
    @State private var discordTag: String = ""
    @State private var steamId: String = ""

    let totalSteps = 3

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.08),
                        Color.blue.opacity(0.05),
                        Color.teal.opacity(0.03)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress indicator
                    progressHeader

                    // Content
                    TabView(selection: $currentStep) {
                        gamingStep1.tag(0)
                        gamingStep2.tag(1)
                        gamingStep3.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentStep)

                    // Navigation
                    navigationButtons
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Step \(currentStep + 1)/\(totalSteps)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadExistingData()
            }
        }
    }

    // MARK: - Load Existing Data

    private func loadExistingData() {
        guard let user = authService.currentUser else { return }
        platforms = Set(user.platforms.compactMap { GamingPlatform(rawValue: $0) })
        gameGenres = Set(user.gameGenres.compactMap { GameGenre(rawValue: $0) })
        voiceChatPreference = VoiceChatPreference(rawValue: user.voiceChatPreference) ?? .noPreference
        weeklyHours = user.gamingStats.weeklyHours ?? 10
        discordTag = user.discordTag ?? ""
        steamId = user.steamId ?? ""
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Progress dots
            HStack(spacing: 12) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(
                            currentStep >= step ?
                            LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: currentStep == step ? 12 : 8, height: currentStep == step ? 12 : 8)
                        .animation(.spring(response: 0.3), value: currentStep)
                }
            }

            VStack(spacing: 4) {
                Text(stepTitle)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Help us find your perfect squad")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Gaming Platforms"
        case 1: return "Game Preferences"
        case 2: return "Connect & Play"
        default: return ""
        }
    }

    // MARK: - Step 1: Platforms

    private var gamingStep1: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                Text("Where Do You Play?")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Select all platforms you game on")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Platform selection grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(GamingPlatform.allCases, id: \.self) { platform in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if platforms.contains(platform) {
                                    platforms.remove(platform)
                                } else {
                                    platforms.insert(platform)
                                }
                            }
                            HapticManager.shared.impact(.light)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: platform.icon)
                                    .font(.title2)
                                Text(platform.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(platforms.contains(platform) ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(platforms.contains(platform) ?
                                        AnyShapeStyle(LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                                        AnyShapeStyle(Color.white))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(platforms.contains(platform) ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: platforms.contains(platform) ? .blue.opacity(0.3) : .clear, radius: 5, y: 2)
                        }
                    }
                }

                infoCard(
                    icon: "person.3.fill",
                    text: "We'll match you with gamers on the same platforms",
                    color: .blue
                )
            }
            .padding(20)
            .padding(.top, 10)
        }
    }

    // MARK: - Step 2: Game Preferences

    private var gamingStep2: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                Text("What Do You Play?")
                    .font(.title2)
                    .fontWeight(.bold)

                // Game Genres
                VStack(alignment: .leading, spacing: 12) {
                    Text("Favorite Genres")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                        ForEach(GameGenre.allCases, id: \.self) { genre in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if gameGenres.contains(genre) {
                                        gameGenres.remove(genre)
                                    } else {
                                        gameGenres.insert(genre)
                                    }
                                }
                                HapticManager.shared.impact(.light)
                            } label: {
                                Text(genre.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(gameGenres.contains(genre) ? .white : .primary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(gameGenres.contains(genre) ?
                                                AnyShapeStyle(LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing)) :
                                                AnyShapeStyle(Color.white))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(gameGenres.contains(genre) ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }

                // Weekly Hours
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("Weekly Gaming Hours")
                            .font(.headline)
                        Spacer()
                        Text("\(weeklyHours)h")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }

                    Slider(value: Binding(
                        get: { Double(weeklyHours) },
                        set: { weeklyHours = Int($0) }
                    ), in: 1...50, step: 1)
                    .tint(.blue)

                    HStack {
                        Text("1h")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("50h+")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)

                infoCard(
                    icon: "sparkles",
                    text: "Find teammates who play what you love",
                    color: .orange
                )
            }
            .padding(20)
            .padding(.top, 10)
        }
    }

    // MARK: - Step 3: Connect & Play

    private var gamingStep3: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "link")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                Text("Connect With Teammates")
                    .font(.title2)
                    .fontWeight(.bold)

                // Voice Chat Preference
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.blue)
                        Text("Voice Chat Preference")
                            .font(.headline)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                        ForEach(VoiceChatPreference.allCases, id: \.self) { pref in
                            Button {
                                withAnimation { voiceChatPreference = pref }
                                HapticManager.shared.impact(.light)
                            } label: {
                                Text(pref.rawValue)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(voiceChatPreference == pref ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(voiceChatPreference == pref ?
                                                AnyShapeStyle(LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing)) :
                                                AnyShapeStyle(Color.white))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(voiceChatPreference == pref ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                // External Profiles
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "link.badge.plus")
                            .foregroundColor(.purple)
                        Text("Gaming Profiles (Optional)")
                            .font(.headline)
                    }

                    // Discord
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundColor(.indigo)
                            .frame(width: 24)
                        TextField("Discord Tag", text: $discordTag)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                    )

                    // Steam
                    HStack {
                        Image(systemName: "laptopcomputer")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        TextField("Steam ID", text: $steamId)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)

                // Completion stats
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.blue)

                        Text("Complete profiles get")
                            .font(.subheadline)

                        Text("3x more squad invites!")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(20)
            .padding(.top, 10)
        }
    }

    // MARK: - Helper Views

    private func infoCard(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                        HapticManager.shared.impact(.light)
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
            }

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                        HapticManager.shared.impact(.medium)
                    }
                } else {
                    saveAndComplete()
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(currentStep < totalSteps - 1 ? "Continue" : "Complete Profile")
                            .fontWeight(.semibold)

                        Image(systemName: currentStep < totalSteps - 1 ? "chevron.right" : "checkmark")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(isLoading)
        }
        .padding(20)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: -2)
    }

    // MARK: - Save Data

    private func saveAndComplete() {
        isLoading = true

        Task {
            do {
                guard var user = authService.currentUser else { return }

                // Update gaming profile fields
                user.platforms = platforms.map { $0.rawValue }
                user.gameGenres = gameGenres.map { $0.rawValue }
                user.voiceChatPreference = voiceChatPreference.rawValue
                user.gamingStats.weeklyHours = weeklyHours
                user.discordTag = discordTag.isEmpty ? nil : discordTag
                user.steamId = steamId.isEmpty ? nil : steamId

                try await authService.updateUser(user)

                await MainActor.run {
                    isLoading = false
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Prompt-based Profile Enhancement

struct ProfilePromptsOnboardingView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var prompts: [ProfilePrompt] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""

    let availablePrompts = [
        "A perfect gaming session would be...",
        "I'm looking for teammates who...",
        "My best gaming memory is...",
        "Two truths and a lie...",
        "My gaming hot take is...",
        "I geek out on...",
        "My most clutch moment was...",
        "I'm convinced that...",
        "The game that changed my life...",
        "My gaming guilty pleasure is..."
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(
                                    LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }

                        Text("Add Profile Prompts")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Answer prompts to show your personality")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)

                    // Current prompts
                    if !prompts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Prompts (\(prompts.count)/3)")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ForEach(prompts) { prompt in
                                promptCard(prompt: prompt)
                            }
                        }
                    }

                    // Add prompt section
                    if prompts.count < 3 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a prompt")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ForEach(availablePrompts.filter { question in
                                !prompts.contains { $0.question == question }
                            }, id: \.self) { question in
                                Button {
                                    addPrompt(question: question)
                                } label: {
                                    HStack {
                                        Text(question)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)

                                        Spacer()

                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // Info card
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)

                        Text("Profiles with prompts get 40% more squad invites!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile Prompts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePrompts()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .disabled(prompts.isEmpty || isLoading)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func promptCard(prompt: ProfilePrompt) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(prompt.question)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)

                Spacer()

                Button {
                    withAnimation {
                        prompts.removeAll { $0.id == prompt.id }
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }

            Text(prompt.answer)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func addPrompt(question: String) {
        let alert = UIAlertController(title: question, message: "Write your answer", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Your answer..."
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let answer = alert.textFields?.first?.text, !answer.isEmpty {
                let newPrompt = ProfilePrompt(
                    id: UUID().uuidString,
                    question: question,
                    answer: answer
                )
                withAnimation {
                    prompts.append(newPrompt)
                }
                HapticManager.shared.notification(.success)
            }
        })

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(alert, animated: true)
        }
    }

    private func savePrompts() {
        isLoading = true

        Task {
            do {
                guard var user = authService.currentUser else { return }
                user.prompts = prompts

                try await authService.updateUser(user)

                await MainActor.run {
                    isLoading = false
                    HapticManager.shared.notification(.success)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Profile Completion Card (for MainTabView)

struct ProfileCompletionCard: View {
    @EnvironmentObject var authService: AuthService
    @State private var showEnhancement = false
    @State private var showPrompts = false

    var completionPercentage: Int {
        guard let user = authService.currentUser else { return 0 }

        var completed = 0
        let total = 10

        // Required fields (always complete after sign-up)
        if !user.fullName.isEmpty { completed += 1 }
        if !user.gamerTag.isEmpty { completed += 1 }
        if !user.platforms.isEmpty { completed += 1 }
        if !user.location.isEmpty { completed += 1 }

        // Optional but valuable
        if !user.bio.isEmpty { completed += 1 }
        if user.photos.count >= 3 { completed += 1 }
        if !user.favoriteGames.isEmpty { completed += 1 }

        // Advanced fields
        if !user.gameGenres.isEmpty { completed += 1 }
        if !user.playStyle.isEmpty { completed += 1 }
        if !user.prompts.isEmpty { completed += 1 }

        return (completed * 100) / total
    }

    var body: some View {
        if completionPercentage < 100 {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Complete Your Profile")
                            .font(.headline)

                        Text("\(completionPercentage)% complete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 50, height: 50)

                        Circle()
                            .trim(from: 0, to: CGFloat(completionPercentage) / 100)
                            .stroke(
                                LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))

                        Text("\(completionPercentage)%")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        showEnhancement = true
                    } label: {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                            Text("Gaming Setup")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }

                    Button {
                        showPrompts = true
                    } label: {
                        HStack {
                            Image(systemName: "text.bubble")
                            Text("Add Prompts")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
            .sheet(isPresented: $showEnhancement) {
                ProfileEnhancementView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showPrompts) {
                ProfilePromptsOnboardingView()
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    ProfileEnhancementView()
        .environmentObject(AuthService.shared)
}
