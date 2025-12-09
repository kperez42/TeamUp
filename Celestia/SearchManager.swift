//
//  SearchManager.swift
//  Celestia
//
//  Manages user search and filtering functionality
//  Filter types are defined in FilterModels.swift
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftUI

// MARK: - Search Manager

@MainActor
class SearchManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SearchManager()

    // MARK: - Published Properties

    @Published var isSearching: Bool = false
    @Published var searchResults: [User] = []
    @Published var currentFilter: SearchFilter = SearchFilter()
    @Published var totalResultsCount: Int = 0
    @Published var errorMessage: String?
    @Published var hasMoreResults: Bool = false
    @Published var isLoadingMore: Bool = false

    // MARK: - Properties

    private let firestore = Firestore.firestore()
    private var searchTask: Task<Void, Never>?
    private var lastDocument: DocumentSnapshot?
    private let pageSize: Int = 20 // PERFORMANCE: Load only what UI shows

    // MARK: - Initialization

    private init() {
        Logger.shared.info("SearchManager initialized", category: .general)
    }

    // MARK: - Search Methods

    /// Perform search with current filter
    func search() async {
        await search(with: currentFilter)
    }

    /// Perform search with specific filter
    func search(with filter: SearchFilter) async {
        // Cancel any ongoing search
        searchTask?.cancel()

        searchTask = Task {
            guard !Task.isCancelled else { return }

            isSearching = true
            currentFilter = filter
            errorMessage = nil
            lastDocument = nil // Reset pagination

            do {
                let results = try await performSearch(filter: filter, startAfter: nil)

                guard !Task.isCancelled else { return }

                searchResults = results
                totalResultsCount = results.count
                hasMoreResults = results.count >= pageSize

                // Track analytics
                AnalyticsManager.shared.logEvent(.featureUsed, parameters: [
                    "feature": "search",
                    "results_count": results.count,
                    "active_filters": filter.activeFilterCount
                ])

                Logger.shared.info("Search completed: \(results.count) results", category: .general)
            } catch {
                guard !Task.isCancelled else { return }

                errorMessage = error.localizedDescription
                Logger.shared.error("Search failed", category: .general, error: error)
            }

            isSearching = false
        }
    }

    /// Load more results (pagination)
    func loadMore() async {
        guard !isLoadingMore, hasMoreResults, let lastDoc = lastDocument else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let results = try await performSearch(filter: currentFilter, startAfter: lastDoc)

            guard !Task.isCancelled else { return }

            searchResults.append(contentsOf: results)
            totalResultsCount = searchResults.count
            hasMoreResults = results.count >= pageSize

            Logger.shared.debug("Loaded \(results.count) more results. Total: \(searchResults.count)", category: .general)
        } catch {
            errorMessage = error.localizedDescription
            Logger.shared.error("Load more failed", category: .general, error: error)
        }
    }

    /// Reset filter to defaults
    func resetFilter() {
        currentFilter = SearchFilter()
    }

    /// Clear search results
    func clearResults() {
        searchResults = []
        totalResultsCount = 0
    }

    // MARK: - Private Methods

    private func performSearch(filter: SearchFilter, startAfter: DocumentSnapshot?) async throws -> [User] {
        // PERFORMANCE FIX: Changed from 100 to 20 (5x less data transferred)
        var query = firestore.collection("users")
            .limit(to: pageSize)

        // Apply verified filter
        if filter.verifiedOnly {
            query = query.whereField("isVerified", isEqualTo: true)
        }

        // Apply region filter
        if filter.region != .any {
            query = query.whereField("region", isEqualTo: filter.region.rawValue)
        }

        // PERFORMANCE: Add pagination support
        if let startAfter = startAfter {
            query = query.start(afterDocument: startAfter)
        }

        // Execute query
        let snapshot = try await query.getDocuments()

        // PERFORMANCE: Store last document for pagination
        lastDocument = snapshot.documents.last

        // Convert to User objects
        var users: [User] = []
        for document in snapshot.documents {
            if let user = try? document.data(as: User.self) {
                // Apply additional client-side filters
                if matchesFilter(user: user, filter: filter) {
                    users.append(user)
                }
            }
        }

        return users
    }

    private func matchesFilter(user: User, filter: SearchFilter) -> Bool {
        // Platforms filter
        if !filter.platforms.isEmpty {
            let userPlatforms = Set(user.platforms.map { $0.lowercased() })
            let filterPlatforms = Set(filter.platforms.map { $0.rawValue.lowercased() })
            if userPlatforms.isDisjoint(with: filterPlatforms) {
                return false
            }
        }

        // Skill level filter
        if !filter.skillLevels.isEmpty {
            let hasMatchingSkill = filter.skillLevels.contains { skillFilter in
                user.skillLevel.lowercased() == skillFilter.rawValue.lowercased()
            }
            if !hasMatchingSkill {
                return false
            }
        }

        // Play style filter
        if !filter.playStyles.isEmpty {
            let hasMatchingStyle = filter.playStyles.contains { styleFilter in
                user.playStyle.lowercased() == styleFilter.rawValue.lowercased()
            }
            if !hasMatchingStyle {
                return false
            }
        }

        // Voice chat filter
        if filter.voiceChat != .any {
            let userVoiceChat = user.voiceChatPreference.lowercased()
            switch filter.voiceChat {
            case .required:
                if userVoiceChat != VoiceChatPreference.always.rawValue.lowercased() {
                    return false
                }
            case .preferred:
                if userVoiceChat == VoiceChatPreference.textOnly.rawValue.lowercased() {
                    return false
                }
            case .noVoice:
                if userVoiceChat != VoiceChatPreference.textOnly.rawValue.lowercased() {
                    return false
                }
            default:
                break
            }
        }

        // Games filter
        if !filter.games.isEmpty {
            let userGames = Set(user.favoriteGames.map { $0.title.lowercased() })
            let filterGames = Set(filter.games.map { $0.lowercased() })
            if userGames.isDisjoint(with: filterGames) {
                return false
            }
        }

        // Photos filter
        if filter.withPhotosOnly && user.photos.isEmpty && user.profileImageURL.isEmpty {
            return false
        }

        return true
    }
}

// Note: FilterPresetManager is defined in FilterPresetManager.swift
// Note: SearchHistoryEntry is defined in FilterModels.swift
// Note: FilterPresetsView is defined in FilterPresetsView.swift
