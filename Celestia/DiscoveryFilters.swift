//
//  DiscoveryFilters.swift
//  GamerLink
//
//  Discovery filter preferences for finding gaming friends
//

import Foundation

@MainActor
class DiscoveryFilters: ObservableObject {
    static let shared = DiscoveryFilters()

    // MARK: - Basic Filters
    @Published var maxDistance: Double = 100 // miles (for regional matchmaking)
    @Published var showVerifiedOnly: Bool = false
    @Published var showOnlineOnly: Bool = false

    // MARK: - User Preference Filters
    @Published var minAge: Int = 18
    @Published var maxAge: Int = 65
    @Published var selectedInterests: Set<String> = []
    @Published var educationLevels: Set<String> = []
    @Published var minHeight: Int? = nil
    @Published var maxHeight: Int? = nil
    @Published var religions: Set<String> = []
    @Published var relationshipGoals: Set<String> = []
    @Published var smokingPreferences: Set<String> = []
    @Published var drinkingPreferences: Set<String> = []
    @Published var petPreferences: Set<String> = []
    @Published var exercisePreferences: Set<String> = []
    @Published var dietPreferences: Set<String> = []

    // MARK: - Platform Filters
    @Published var selectedPlatforms: Set<String> = []  // GamingPlatform raw values

    // MARK: - Game Filters
    @Published var selectedGames: Set<String> = []      // Game titles
    @Published var selectedGenres: Set<String> = []     // GameGenre raw values
    @Published var mustHaveGamesInCommon: Bool = false

    // MARK: - Skill & Play Style Filters
    @Published var selectedSkillLevels: Set<String> = []  // SkillLevel raw values
    @Published var selectedPlayStyles: Set<String> = []   // PlayStyle raw values

    // MARK: - Looking For Type Filter
    @Published var selectedLookingForTypes: Set<String> = []  // LookingForType raw values

    // MARK: - Voice Chat Filter
    @Published var selectedVoiceChatPreferences: Set<String> = []  // VoiceChatPreference raw values

    // MARK: - Schedule Filters
    @Published var preferredTimezone: String? = nil
    @Published var scheduleMustOverlap: Bool = false

    // MARK: - Region Filter
    @Published var selectedRegions: Set<String> = []  // e.g., "NA East", "EU West"

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - Filter Logic

    /// Convenience overload that accepts location tuple instead of full User object
    func matchesFilters(user: User, currentUserLocation: (lat: Double, lon: Double)?) -> Bool {
        // Verification filter
        if showVerifiedOnly && !user.isVerified {
            return false
        }

        // Online only filter
        if showOnlineOnly && !user.isOnline {
            return false
        }

        // Distance filter (for regional matchmaking)
        if let currentLocation = currentUserLocation,
           let userLat = user.latitude,
           let userLon = user.longitude {
            let distance = calculateDistance(
                from: currentLocation,
                to: (userLat, userLon)
            )
            if distance > maxDistance {
                return false
            }
        }

        // Age filter
        if user.age < minAge || user.age > maxAge {
            return false
        }

        // Interests filter
        if !selectedInterests.isEmpty {
            let userInterests = Set(user.interests)
            if selectedInterests.isDisjoint(with: userInterests) {
                return false
            }
        }

        // Education filter
        if !educationLevels.isEmpty {
            if let userEducation = user.educationLevel, !educationLevels.contains(userEducation) {
                return false
            } else if user.educationLevel == nil {
                return false
            }
        }

        // Height filter
        if let minH = minHeight, let userHeight = user.height, userHeight < minH {
            return false
        }
        if let maxH = maxHeight, let userHeight = user.height, userHeight > maxH {
            return false
        }

        // Religion filter
        if !religions.isEmpty {
            if let userReligion = user.religion, !religions.contains(userReligion) {
                return false
            } else if user.religion == nil {
                return false
            }
        }

        // Gaming goals filter
        if !relationshipGoals.isEmpty {
            if let userGoal = user.relationshipGoal, !relationshipGoals.contains(userGoal) {
                return false
            } else if user.relationshipGoal == nil {
                return false
            }
        }

        // Lifestyle filters
        if !smokingPreferences.isEmpty {
            if let userSmoking = user.smoking, !smokingPreferences.contains(userSmoking) {
                return false
            } else if user.smoking == nil {
                return false
            }
        }

        if !drinkingPreferences.isEmpty {
            if let userDrinking = user.drinking, !drinkingPreferences.contains(userDrinking) {
                return false
            } else if user.drinking == nil {
                return false
            }
        }

        if !petPreferences.isEmpty {
            if let userPets = user.pets, !petPreferences.contains(userPets) {
                return false
            } else if user.pets == nil {
                return false
            }
        }

        if !exercisePreferences.isEmpty {
            if let userExercise = user.exercise, !exercisePreferences.contains(userExercise) {
                return false
            } else if user.exercise == nil {
                return false
            }
        }

        if !dietPreferences.isEmpty {
            if let userDiet = user.diet, !dietPreferences.contains(userDiet) {
                return false
            } else if user.diet == nil {
                return false
            }
        }

        return true
    }

    func matchesFilters(user: User, currentUser: User?) -> Bool {
        // Verification filter
        if showVerifiedOnly && !user.isVerified {
            return false
        }

        // Online only filter
        if showOnlineOnly && !user.isOnline {
            return false
        }

        // Distance filter (for regional matchmaking)
        if let currentUser = currentUser,
           let currentLat = currentUser.latitude,
           let currentLon = currentUser.longitude,
           let userLat = user.latitude,
           let userLon = user.longitude {
            let distance = calculateDistance(
                from: (currentLat, currentLon),
                to: (userLat, userLon)
            )
            if distance > maxDistance {
                return false
            }
        }

        // Platform filter (user must have at least one matching platform)
        if !selectedPlatforms.isEmpty {
            let userPlatforms = Set(user.platforms)
            if selectedPlatforms.isDisjoint(with: userPlatforms) {
                return false
            }
        }

        // Games filter (user must play at least one selected game)
        if !selectedGames.isEmpty {
            let userGames = Set(user.favoriteGames.map { $0.title.lowercased() })
            let lowercaseSelectedGames = Set(selectedGames.map { $0.lowercased() })
            if lowercaseSelectedGames.isDisjoint(with: userGames) {
                return false
            }
        }

        // Must have games in common with current user
        if mustHaveGamesInCommon, let currentUser = currentUser {
            if !currentUser.hasGamesInCommon(with: user) {
                return false
            }
        }

        // Genre filter
        if !selectedGenres.isEmpty {
            let userGenres = Set(user.gameGenres)
            if selectedGenres.isDisjoint(with: userGenres) {
                return false
            }
        }

        // Skill level filter
        if !selectedSkillLevels.isEmpty {
            if !selectedSkillLevels.contains(user.skillLevel) {
                return false
            }
        }

        // Play style filter
        if !selectedPlayStyles.isEmpty {
            if !selectedPlayStyles.contains(user.playStyle) {
                return false
            }
        }

        // Looking for type filter
        if !selectedLookingForTypes.isEmpty {
            let userLookingFor = Set(user.lookingFor)
            if selectedLookingForTypes.isDisjoint(with: userLookingFor) {
                return false
            }
        }

        // Voice chat preference filter
        if !selectedVoiceChatPreferences.isEmpty {
            if !selectedVoiceChatPreferences.contains(user.voiceChatPreference) {
                return false
            }
        }

        // Region filter
        if !selectedRegions.isEmpty {
            if let userRegion = user.region {
                if !selectedRegions.contains(userRegion) {
                    return false
                }
            } else {
                // If user hasn't set region and we have region filters, exclude them
                return false
            }
        }

        // Schedule overlap filter
        if scheduleMustOverlap, let currentUser = currentUser {
            if !hasScheduleOverlap(user1: currentUser, user2: user) {
                return false
            }
        }

        return true
    }

    // MARK: - Helper Methods

    private func calculateDistance(from: (lat: Double, lon: Double), to: (lat: Double, lon: Double)) -> Double {
        // Validate coordinates
        guard isValidLatitude(from.lat), isValidLongitude(from.lon),
              isValidLatitude(to.lat), isValidLongitude(to.lon) else {
            Logger.shared.warning("Invalid coordinates: from(\(from.lat), \(from.lon)) to(\(to.lat), \(to.lon))", category: .matching)
            return Double.infinity
        }

        let earthRadiusMiles = 3958.8

        let lat1 = from.lat * .pi / 180
        let lon1 = from.lon * .pi / 180
        let lat2 = to.lat * .pi / 180
        let lon2 = to.lon * .pi / 180

        let dLat = lat2 - lat1
        let dLon = lon2 - lon1

        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))

        let distance = earthRadiusMiles * c

        guard distance.isFinite, distance >= 0 else {
            Logger.shared.warning("Invalid distance calculation result: \(distance)", category: .matching)
            return Double.infinity
        }

        return distance
    }

    private func isValidLatitude(_ lat: Double) -> Bool {
        return lat >= -90 && lat <= 90 && lat.isFinite
    }

    private func isValidLongitude(_ lon: Double) -> Bool {
        return lon >= -180 && lon <= 180 && lon.isFinite
    }

    private func hasScheduleOverlap(user1: User, user2: User) -> Bool {
        // Check if users have overlapping preferred days
        let days1 = Set(user1.gamingSchedule.preferredDays)
        let days2 = Set(user2.gamingSchedule.preferredDays)

        if !days1.isEmpty && !days2.isEmpty && days1.isDisjoint(with: days2) {
            return false
        }

        // Check timezone compatibility (within 4 hours)
        if let tz1 = TimeZone(identifier: user1.gamingSchedule.timezone),
           let tz2 = TimeZone(identifier: user2.gamingSchedule.timezone) {
            let hoursDiff = abs(tz1.secondsFromGMT() - tz2.secondsFromGMT()) / 3600
            if hoursDiff > 4 {
                return false
            }
        }

        return true
    }

    // MARK: - Match Score Calculation

    func calculateMatchScore(for user: User, currentUser: User?) -> Int {
        var score = 0

        guard let currentUser = currentUser else { return score }

        // Games in common (highest weight - 30 points per game, max 150)
        let commonGames = currentUser.gamesInCommon(with: user)
        score += min(commonGames.count * 30, 150)

        // Platforms in common (20 points per platform, max 60)
        let commonPlatforms = currentUser.platformsInCommon(with: user)
        score += min(commonPlatforms.count * 20, 60)

        // Same play style (50 points)
        if currentUser.playStyle == user.playStyle {
            score += 50
        }

        // Similar skill level (40 points for same, 20 for adjacent)
        let skillDiff = abs(skillLevelOrder(currentUser.skillLevel) - skillLevelOrder(user.skillLevel))
        if skillDiff == 0 {
            score += 40
        } else if skillDiff == 1 {
            score += 20
        }

        // Matching looking for types (25 points per match, max 75)
        let currentLookingFor = Set(currentUser.lookingFor)
        let userLookingFor = Set(user.lookingFor)
        let matchingTypes = currentLookingFor.intersection(userLookingFor).count
        score += min(matchingTypes * 25, 75)

        // Compatible voice chat preferences (30 points)
        if isVoiceChatCompatible(currentUser.voiceChatPreference, user.voiceChatPreference) {
            score += 30
        }

        // Genre overlap (10 points per genre, max 50)
        let currentGenres = Set(currentUser.gameGenres)
        let userGenres = Set(user.gameGenres)
        let genreOverlap = currentGenres.intersection(userGenres).count
        score += min(genreOverlap * 10, 50)

        // Schedule overlap bonus (35 points)
        if hasScheduleOverlap(user1: currentUser, user2: user) {
            score += 35
        }

        // Online bonus (15 points)
        if user.isOnline {
            score += 15
        }

        // Verified bonus (10 points)
        if user.isVerified {
            score += 10
        }

        return score
    }

    private func skillLevelOrder(_ level: String) -> Int {
        switch level {
        case SkillLevel.beginner.rawValue: return 1
        case SkillLevel.intermediate.rawValue: return 2
        case SkillLevel.advanced.rawValue: return 3
        case SkillLevel.expert.rawValue: return 4
        case SkillLevel.professional.rawValue: return 5
        default: return 2
        }
    }

    private func isVoiceChatCompatible(_ pref1: String, _ pref2: String) -> Bool {
        // Text only users shouldn't be matched with always voice chat users
        if pref1 == VoiceChatPreference.textOnly.rawValue && pref2 == VoiceChatPreference.always.rawValue {
            return false
        }
        if pref2 == VoiceChatPreference.textOnly.rawValue && pref1 == VoiceChatPreference.always.rawValue {
            return false
        }
        return true
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        UserDefaults.standard.set(maxDistance, forKey: "gl_maxDistance")
        UserDefaults.standard.set(showVerifiedOnly, forKey: "gl_showVerifiedOnly")
        UserDefaults.standard.set(showOnlineOnly, forKey: "gl_showOnlineOnly")

        UserDefaults.standard.set(Array(selectedPlatforms), forKey: "gl_selectedPlatforms")
        UserDefaults.standard.set(Array(selectedGames), forKey: "gl_selectedGames")
        UserDefaults.standard.set(Array(selectedGenres), forKey: "gl_selectedGenres")
        UserDefaults.standard.set(mustHaveGamesInCommon, forKey: "gl_mustHaveGamesInCommon")

        UserDefaults.standard.set(Array(selectedSkillLevels), forKey: "gl_selectedSkillLevels")
        UserDefaults.standard.set(Array(selectedPlayStyles), forKey: "gl_selectedPlayStyles")
        UserDefaults.standard.set(Array(selectedLookingForTypes), forKey: "gl_selectedLookingForTypes")
        UserDefaults.standard.set(Array(selectedVoiceChatPreferences), forKey: "gl_selectedVoiceChatPreferences")

        UserDefaults.standard.set(preferredTimezone, forKey: "gl_preferredTimezone")
        UserDefaults.standard.set(scheduleMustOverlap, forKey: "gl_scheduleMustOverlap")
        UserDefaults.standard.set(Array(selectedRegions), forKey: "gl_selectedRegions")

        // User preference filters
        UserDefaults.standard.set(minAge, forKey: "gl_minAge")
        UserDefaults.standard.set(maxAge, forKey: "gl_maxAge")
        UserDefaults.standard.set(Array(selectedInterests), forKey: "gl_selectedInterests")
        UserDefaults.standard.set(Array(educationLevels), forKey: "gl_educationLevels")
        UserDefaults.standard.set(minHeight, forKey: "gl_minHeight")
        UserDefaults.standard.set(maxHeight, forKey: "gl_maxHeight")
        UserDefaults.standard.set(Array(religions), forKey: "gl_religions")
        UserDefaults.standard.set(Array(relationshipGoals), forKey: "gl_relationshipGoals")
        UserDefaults.standard.set(Array(smokingPreferences), forKey: "gl_smokingPreferences")
        UserDefaults.standard.set(Array(drinkingPreferences), forKey: "gl_drinkingPreferences")
        UserDefaults.standard.set(Array(petPreferences), forKey: "gl_petPreferences")
        UserDefaults.standard.set(Array(exercisePreferences), forKey: "gl_exercisePreferences")
        UserDefaults.standard.set(Array(dietPreferences), forKey: "gl_dietPreferences")
    }

    private func loadFromUserDefaults() {
        if let distance = UserDefaults.standard.object(forKey: "gl_maxDistance") as? Double {
            maxDistance = distance
        }
        showVerifiedOnly = UserDefaults.standard.bool(forKey: "gl_showVerifiedOnly")
        showOnlineOnly = UserDefaults.standard.bool(forKey: "gl_showOnlineOnly")

        if let platforms = UserDefaults.standard.array(forKey: "gl_selectedPlatforms") as? [String] {
            selectedPlatforms = Set(platforms)
        }
        if let games = UserDefaults.standard.array(forKey: "gl_selectedGames") as? [String] {
            selectedGames = Set(games)
        }
        if let genres = UserDefaults.standard.array(forKey: "gl_selectedGenres") as? [String] {
            selectedGenres = Set(genres)
        }
        mustHaveGamesInCommon = UserDefaults.standard.bool(forKey: "gl_mustHaveGamesInCommon")

        if let skillLevels = UserDefaults.standard.array(forKey: "gl_selectedSkillLevels") as? [String] {
            selectedSkillLevels = Set(skillLevels)
        }
        if let playStyles = UserDefaults.standard.array(forKey: "gl_selectedPlayStyles") as? [String] {
            selectedPlayStyles = Set(playStyles)
        }
        if let lookingFor = UserDefaults.standard.array(forKey: "gl_selectedLookingForTypes") as? [String] {
            selectedLookingForTypes = Set(lookingFor)
        }
        if let voiceChat = UserDefaults.standard.array(forKey: "gl_selectedVoiceChatPreferences") as? [String] {
            selectedVoiceChatPreferences = Set(voiceChat)
        }

        preferredTimezone = UserDefaults.standard.string(forKey: "gl_preferredTimezone")
        scheduleMustOverlap = UserDefaults.standard.bool(forKey: "gl_scheduleMustOverlap")
        if let regions = UserDefaults.standard.array(forKey: "gl_selectedRegions") as? [String] {
            selectedRegions = Set(regions)
        }

        // User preference filters
        if let savedMinAge = UserDefaults.standard.object(forKey: "gl_minAge") as? Int {
            minAge = savedMinAge
        }
        if let savedMaxAge = UserDefaults.standard.object(forKey: "gl_maxAge") as? Int {
            maxAge = savedMaxAge
        }
        if let interests = UserDefaults.standard.array(forKey: "gl_selectedInterests") as? [String] {
            selectedInterests = Set(interests)
        }
        if let education = UserDefaults.standard.array(forKey: "gl_educationLevels") as? [String] {
            educationLevels = Set(education)
        }
        minHeight = UserDefaults.standard.object(forKey: "gl_minHeight") as? Int
        maxHeight = UserDefaults.standard.object(forKey: "gl_maxHeight") as? Int
        if let savedReligions = UserDefaults.standard.array(forKey: "gl_religions") as? [String] {
            religions = Set(savedReligions)
        }
        if let goals = UserDefaults.standard.array(forKey: "gl_relationshipGoals") as? [String] {
            relationshipGoals = Set(goals)
        }
        if let smoking = UserDefaults.standard.array(forKey: "gl_smokingPreferences") as? [String] {
            smokingPreferences = Set(smoking)
        }
        if let drinking = UserDefaults.standard.array(forKey: "gl_drinkingPreferences") as? [String] {
            drinkingPreferences = Set(drinking)
        }
        if let pets = UserDefaults.standard.array(forKey: "gl_petPreferences") as? [String] {
            petPreferences = Set(pets)
        }
        if let exercise = UserDefaults.standard.array(forKey: "gl_exercisePreferences") as? [String] {
            exercisePreferences = Set(exercise)
        }
        if let diet = UserDefaults.standard.array(forKey: "gl_dietPreferences") as? [String] {
            dietPreferences = Set(diet)
        }
    }

    func resetFilters() {
        maxDistance = 100
        showVerifiedOnly = false
        showOnlineOnly = false

        selectedPlatforms.removeAll()
        selectedGames.removeAll()
        selectedGenres.removeAll()
        mustHaveGamesInCommon = false

        selectedSkillLevels.removeAll()
        selectedPlayStyles.removeAll()
        selectedLookingForTypes.removeAll()
        selectedVoiceChatPreferences.removeAll()

        preferredTimezone = nil
        scheduleMustOverlap = false
        selectedRegions.removeAll()

        // User preference filters
        minAge = 18
        maxAge = 65
        selectedInterests.removeAll()
        educationLevels.removeAll()
        minHeight = nil
        maxHeight = nil
        religions.removeAll()
        relationshipGoals.removeAll()
        smokingPreferences.removeAll()
        drinkingPreferences.removeAll()
        petPreferences.removeAll()
        exercisePreferences.removeAll()
        dietPreferences.removeAll()

        saveToUserDefaults()
    }

    var hasActiveFilters: Bool {
        return showVerifiedOnly || showOnlineOnly ||
               !selectedPlatforms.isEmpty || !selectedGames.isEmpty ||
               !selectedGenres.isEmpty || mustHaveGamesInCommon ||
               !selectedSkillLevels.isEmpty || !selectedPlayStyles.isEmpty ||
               !selectedLookingForTypes.isEmpty || !selectedVoiceChatPreferences.isEmpty ||
               preferredTimezone != nil || scheduleMustOverlap || !selectedRegions.isEmpty ||
               minAge > 18 || maxAge < 65 ||
               !selectedInterests.isEmpty || !educationLevels.isEmpty ||
               minHeight != nil || maxHeight != nil ||
               !religions.isEmpty || !relationshipGoals.isEmpty ||
               !smokingPreferences.isEmpty || !drinkingPreferences.isEmpty ||
               !petPreferences.isEmpty || !exercisePreferences.isEmpty || !dietPreferences.isEmpty
    }

    var activeFilterCount: Int {
        var count = 0
        if showVerifiedOnly { count += 1 }
        if showOnlineOnly { count += 1 }
        count += selectedPlatforms.count
        count += selectedGames.count
        count += selectedGenres.count
        if mustHaveGamesInCommon { count += 1 }
        count += selectedSkillLevels.count
        count += selectedPlayStyles.count
        count += selectedLookingForTypes.count
        count += selectedVoiceChatPreferences.count
        if preferredTimezone != nil { count += 1 }
        if scheduleMustOverlap { count += 1 }
        count += selectedRegions.count
        // User preference filters
        if minAge > 18 { count += 1 }
        if maxAge < 65 { count += 1 }
        count += selectedInterests.count
        count += educationLevels.count
        if minHeight != nil { count += 1 }
        if maxHeight != nil { count += 1 }
        count += religions.count
        count += relationshipGoals.count
        count += smokingPreferences.count
        count += drinkingPreferences.count
        count += petPreferences.count
        count += exercisePreferences.count
        count += dietPreferences.count
        return count
    }

    // MARK: - Filter Descriptions

    var filterSummary: String {
        var parts: [String] = []

        if !selectedPlatforms.isEmpty {
            parts.append("\(selectedPlatforms.count) platform\(selectedPlatforms.count == 1 ? "" : "s")")
        }
        if !selectedGames.isEmpty {
            parts.append("\(selectedGames.count) game\(selectedGames.count == 1 ? "" : "s")")
        }
        if !selectedSkillLevels.isEmpty {
            parts.append("\(selectedSkillLevels.count) skill level\(selectedSkillLevels.count == 1 ? "" : "s")")
        }
        if !selectedPlayStyles.isEmpty {
            parts.append("\(selectedPlayStyles.count) play style\(selectedPlayStyles.count == 1 ? "" : "s")")
        }
        if mustHaveGamesInCommon {
            parts.append("games in common")
        }
        if showOnlineOnly {
            parts.append("online only")
        }
        if showVerifiedOnly {
            parts.append("verified only")
        }

        if parts.isEmpty {
            return "No filters"
        }

        return parts.joined(separator: ", ")
    }
}
