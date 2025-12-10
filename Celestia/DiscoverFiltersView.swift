//
//  DiscoverFiltersView.swift
//  TeamUp
//
//  Professional filter settings for discovery
//

import SwiftUI

struct DiscoverFiltersView: View {
    @ObservedObject var filters = DiscoveryFilters.shared
    @Environment(\.dismiss) var dismiss

    // Section expansion state - basics, gaming, and preferences open by default
    @State private var expandedSections: Set<FilterSection> = [.basics, .gaming, .preferences]

    enum FilterSection: String, CaseIterable {
        case basics = "Basics"
        case gaming = "Gaming"
        case preferences = "Preferences"
        case availability = "Availability"
    }

    // Gaming platforms
    let platformOptions = [
        "PC", "PlayStation", "Xbox", "Nintendo Switch",
        "Mobile", "VR", "Tabletop"
    ]

    // Game genres
    let genreOptions = [
        "FPS", "MOBA", "Battle Royale", "RPG", "MMORPG",
        "Sports", "Racing", "Fighting", "Strategy", "Simulation",
        "Survival", "Horror", "Puzzle", "Platformer", "Sandbox",
        "Card Game", "Board Game", "Indie", "Co-op", "Party"
    ]

    // Skill levels
    let skillLevelOptions = [
        "Beginner", "Intermediate", "Advanced", "Expert", "Professional"
    ]

    // Gaming goals
    let gamingGoalOptions = [
        "Casual Gaming", "Regular Squad", "Competitive Team",
        "Streaming Partners", "Tournament Team", "Any Gamers"
    ]

    // Voice chat preferences
    let voiceChatOptions = ["Always", "Preferred", "Sometimes", "Text Only", "No Preference"]

    // Play style
    let playStyleOptions = ["Competitive", "Casual", "Ranked", "Social", "Tryhard", "Chill", "Roleplay", "Speedrun"]

    // Availability
    let availabilityOptions = ["Weekday Mornings", "Weekday Afternoons", "Weekday Evenings", "Weekday Nights", "Weekends", "Flexible"]
    let weeklyHoursOptions = ["5+ hrs", "10+ hrs", "15+ hrs", "20+ hrs", "25+ hrs"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Active Filters Summary (no quick filters - cleaner UI)
                    if filters.hasActiveFilters {
                        activeFiltersSummary
                    }

                    // Filter Sections
                    VStack(spacing: 12) {
                        // Basics Section
                        filterSection(
                            section: .basics,
                            icon: "slider.horizontal.3",
                            content: {
                                VStack(spacing: 20) {
                                    ageRangeSection
                                    Divider().padding(.horizontal)
                                    verificationSection
                                }
                            }
                        )

                        // Gaming Section
                        filterSection(
                            section: .gaming,
                            icon: "gamecontroller.fill",
                            content: {
                                VStack(spacing: 20) {
                                    platformsSection
                                    Divider().padding(.horizontal)
                                    genresSection
                                    Divider().padding(.horizontal)
                                    skillLevelSection
                                }
                            }
                        )

                        // Preferences Section
                        filterSection(
                            section: .preferences,
                            icon: "person.2.fill",
                            content: {
                                VStack(spacing: 20) {
                                    gamingGoalsSection
                                    Divider().padding(.horizontal)
                                    voiceChatSection
                                    Divider().padding(.horizontal)
                                    playStyleSection
                                }
                            }
                        )

                        // Availability Section
                        filterSection(
                            section: .availability,
                            icon: "clock.fill",
                            content: {
                                VStack(spacing: 20) {
                                    availabilityTimesSection
                                    Divider().padding(.horizontal)
                                    weeklyHoursSection
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    // Reset button
                    if filters.hasActiveFilters {
                        resetButton
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    } else {
                        Spacer().frame(height: 32)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.shared.impact(.medium)
                        filters.saveToUserDefaults()
                        dismiss()
                    } label: {
                        Text("Apply")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                    }
                }
            }
        }
    }

    // MARK: - Active Filters Summary

    private var activeFiltersSummary: some View {
        let activeCount = countActiveFilters()

        return HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.blue)

            Text("\(activeCount) filter\(activeCount == 1 ? "" : "s") active")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Spacer()

            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3)) {
                    filters.resetFilters()
                }
            } label: {
                Text("Clear All")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.blue.opacity(0.08))
    }

    // MARK: - Filter Section Container

    private func filterSection<Content: View>(
        section: FilterSection,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Section Header
            Button {
                HapticManager.shared.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expandedSections.contains(section) {
                        expandedSections.remove(section)
                    } else {
                        expandedSections.insert(section)
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32)

                    Text(section.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    // Section filter count badge
                    if let count = sectionFilterCount(section), count > 0 {
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(expandedSections.contains(section) ? 90 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            // Section Content
            if expandedSections.contains(section) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }

    // MARK: - Age Range Section

    private var ageRangeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Age Range")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(filters.minAge) - \(filters.maxAge)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }

            // Combined range slider visualization
            VStack(spacing: 8) {
                // Min age slider
                VStack(alignment: .leading, spacing: 4) {
                    Text("Min: \(filters.minAge)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { Double(filters.minAge) },
                        set: { filters.minAge = Int($0) }
                    ), in: 18...Double(filters.maxAge - 1), step: 1)
                    .tint(.blue)
                }

                // Max age slider
                VStack(alignment: .leading, spacing: 4) {
                    Text("Max: \(filters.maxAge)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Slider(value: Binding(
                        get: { Double(filters.maxAge) },
                        set: { filters.maxAge = Int($0) }
                    ), in: Double(filters.minAge + 1)...65, step: 1)
                    .tint(.teal)
                }
            }
        }
    }

    // MARK: - Verification Section

    private var verificationSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Verified Users Only")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Only show profiles with ID verification")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $filters.showVerifiedOnly)
                .labelsHidden()
                .tint(.blue)
        }
    }

    // MARK: - Platforms Section

    private var platformsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "desktopcomputer")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("Platforms")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.selectedInterests.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.selectedInterests.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Find gamers on these platforms")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(platformOptions, id: \.self) { platform in
                    SelectableFilterChip(
                        title: platform,
                        isSelected: filters.selectedInterests.contains(platform)
                    ) {
                        toggleInterest(platform)
                    }
                }
            }
        }
    }

    // MARK: - Genres Section

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "square.grid.2x2.fill")
                    .font(.subheadline)
                    .foregroundColor(.teal)

                Text("Game Genres")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.educationLevels.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.educationLevels.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Filter by favorite game genres")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(genreOptions, id: \.self) { genre in
                    SelectableFilterChip(
                        title: genre,
                        isSelected: filters.educationLevels.contains(genre)
                    ) {
                        toggleEducation(genre)
                    }
                }
            }
        }
    }

    // MARK: - Skill Level Section

    private var skillLevelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.subheadline)
                    .foregroundColor(.yellow)

                Text("Skill Level")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.religions.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.religions.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Match with gamers at your level")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(skillLevelOptions, id: \.self) { level in
                    SelectableFilterChip(
                        title: level,
                        isSelected: filters.religions.contains(level)
                    ) {
                        toggleReligion(level)
                    }
                }
            }
        }
    }

    // MARK: - Gaming Goals Section

    private var gamingGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flag.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Text("Looking For")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.relationshipGoals.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.relationshipGoals.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("What type of teammates are you looking for?")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(gamingGoalOptions, id: \.self) { goal in
                    SelectableFilterChip(
                        title: goal,
                        isSelected: filters.relationshipGoals.contains(goal)
                    ) {
                        toggleRelationshipGoal(goal)
                    }
                }
            }
        }
    }

    // MARK: - Voice Chat Section

    private var voiceChatSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("Voice Chat")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.smokingPreferences.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.smokingPreferences.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Voice chat preference")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(voiceChatOptions, id: \.self) { option in
                    SelectableFilterChip(
                        title: option,
                        isSelected: filters.smokingPreferences.contains(option)
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.smokingPreferences.contains(option) {
                            filters.smokingPreferences.remove(option)
                        } else {
                            filters.smokingPreferences.insert(option)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Play Style Section

    private var playStyleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                Text("Play Style")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.drinkingPreferences.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.drinkingPreferences.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("How do you like to play?")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(playStyleOptions, id: \.self) { style in
                    SelectableFilterChip(
                        title: style,
                        isSelected: filters.drinkingPreferences.contains(style)
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.drinkingPreferences.contains(style) {
                            filters.drinkingPreferences.remove(style)
                        } else {
                            filters.drinkingPreferences.insert(style)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Availability Times Section

    private var availabilityTimesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.green)

                Text("When You Play")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.petPreferences.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.petPreferences.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Find gamers available when you are")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(availabilityOptions, id: \.self) { time in
                    SelectableFilterChip(
                        title: time,
                        isSelected: filters.petPreferences.contains(time)
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.petPreferences.contains(time) {
                            filters.petPreferences.remove(time)
                        } else {
                            filters.petPreferences.insert(time)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Weekly Hours Section

    private var weeklyHoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.subheadline)
                    .foregroundColor(.teal)

                Text("Weekly Gaming Hours")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if !filters.exercisePreferences.isEmpty {
                    Button("Clear") {
                        HapticManager.shared.impact(.light)
                        filters.exercisePreferences.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }

            Text("Match with gamers who play similar hours")
                .font(.caption)
                .foregroundColor(.secondary)

            FlowLayout(spacing: 8) {
                ForEach(weeklyHoursOptions, id: \.self) { hours in
                    SelectableFilterChip(
                        title: hours,
                        isSelected: filters.exercisePreferences.contains(hours)
                    ) {
                        HapticManager.shared.impact(.light)
                        if filters.exercisePreferences.contains(hours) {
                            filters.exercisePreferences.remove(hours)
                        } else {
                            filters.exercisePreferences.insert(hours)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            HapticManager.shared.notification(.warning)
            withAnimation(.spring(response: 0.3)) {
                filters.resetFilters()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body.weight(.medium))
                Text("Reset All Filters")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.red)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Helper Functions

    private func countActiveFilters() -> Int {
        var count = 0
        // Basics
        if filters.minAge > 18 { count += 1 }
        if filters.maxAge < 65 { count += 1 }
        if filters.showVerifiedOnly { count += 1 }
        // Gaming (Platforms, Genres, Skill Level)
        count += filters.selectedInterests.count
        count += filters.educationLevels.count
        count += filters.religions.count
        // Preferences (Gaming Goals, Voice Chat, Play Style)
        count += filters.relationshipGoals.count
        count += filters.smokingPreferences.count
        count += filters.drinkingPreferences.count
        // Availability (When You Play, Weekly Hours)
        count += filters.petPreferences.count
        count += filters.exercisePreferences.count
        return count
    }

    private func sectionFilterCount(_ section: FilterSection) -> Int? {
        switch section {
        case .basics:
            var count = 0
            if filters.minAge > 18 || filters.maxAge < 65 { count += 1 }
            if filters.showVerifiedOnly { count += 1 }
            return count > 0 ? count : nil
        case .gaming:
            var count = 0
            count += filters.selectedInterests.count // Platforms
            count += filters.educationLevels.count // Genres
            count += filters.religions.count // Skill Level
            return count > 0 ? count : nil
        case .preferences:
            var count = 0
            count += filters.relationshipGoals.count // Gaming Goals
            count += filters.smokingPreferences.count // Voice Chat
            count += filters.drinkingPreferences.count // Play Style
            return count > 0 ? count : nil
        case .availability:
            let count = filters.petPreferences.count + // When You Play
                       filters.exercisePreferences.count // Weekly Hours
            return count > 0 ? count : nil
        }
    }

    private func toggleInterest(_ interest: String) {
        HapticManager.shared.impact(.light)
        if filters.selectedInterests.contains(interest) {
            filters.selectedInterests.remove(interest)
        } else {
            filters.selectedInterests.insert(interest)
        }
    }

    private func toggleEducation(_ option: String) {
        HapticManager.shared.impact(.light)
        if filters.educationLevels.contains(option) {
            filters.educationLevels.remove(option)
        } else {
            filters.educationLevels.insert(option)
        }
    }

    private func toggleReligion(_ option: String) {
        HapticManager.shared.impact(.light)
        if filters.religions.contains(option) {
            filters.religions.remove(option)
        } else {
            filters.religions.insert(option)
        }
    }

    private func toggleRelationshipGoal(_ option: String) {
        HapticManager.shared.impact(.light)
        if filters.relationshipGoals.contains(option) {
            filters.relationshipGoals.remove(option)
        } else {
            filters.relationshipGoals.insert(option)
        }
    }
}

// MARK: - Quick Filter Chip

struct QuickFilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundColor(isActive ? .white : color)
            .background(
                isActive ?
                AnyShapeStyle(color) :
                AnyShapeStyle(color.opacity(0.1))
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(isActive ? 0 : 0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Selectable Filter Chip

struct SelectableFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    isSelected ?
                    Color.blue :
                    Color(.systemGray6)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Interest Chip (Legacy support)

struct InterestChip: View {
    let interest: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SelectableFilterChip(title: interest, isSelected: isSelected, action: action)
    }
}

#Preview {
    DiscoverFiltersView()
}
