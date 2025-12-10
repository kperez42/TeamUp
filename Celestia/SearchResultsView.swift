//
//  SearchResultsView.swift
//  TeamUp
//
//  Search results display with profile cards
//

import SwiftUI

struct SearchResultsView: View {

    @StateObject private var searchManager = SearchManager.shared
    @State private var showingFilters = false

    var body: some View {
        NavigationView {
            ZStack {
                if searchManager.isSearching {
                    loadingView
                } else if searchManager.searchResults.isEmpty {
                    emptyStateView
                } else {
                    resultsListView
                }
            }
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters = true }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.title3)

                            if searchManager.currentFilter.activeFilterCount > 0 {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                SearchFilterView(filter: searchManager.currentFilter)
            }
        }
        .onAppear {
            if searchManager.searchResults.isEmpty {
                Task {
                    await searchManager.search()
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Searching for gamers...")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()

                // Show skeleton grid of search results
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<6, id: \.self) { _ in
                        MatchCardSkeleton()
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            VStack(spacing: 12) {
                Text("No gamers found")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Try adjusting your filters to see more results")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { showingFilters = true }) {
                Text("Adjust Filters")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Results List

    private var resultsListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Results count
                resultsHeader

                // Profile cards
                ForEach(searchManager.searchResults) { user in
                    SearchProfileCard(user: user)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                }
            }
        }
    }

    private var resultsHeader: some View {
        HStack {
            Text("\(searchManager.totalResultsCount) gamers found")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            if searchManager.currentFilter.activeFilterCount > 0 {
                Button(action: {
                    searchManager.resetFilter()
                    Task {
                        await searchManager.search()
                    }
                }) {
                    Text("Clear Filters")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Search Profile Card

struct SearchProfileCard: View {

    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            profileImage

            // Info
            VStack(alignment: .leading, spacing: 8) {
                // Name and skill level
                HStack {
                    HStack(spacing: 4) {
                        Text(user.gamerTag.isEmpty ? user.fullName : user.gamerTag)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(user.skillLevel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }

                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                    }

                    Spacer()
                }

                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(user.location), \(user.country)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Bio
                Text(user.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Tags
                tags
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var profileImage: some View {
        ZStack {
            if !user.profileImageURL.isEmpty, let url = URL(string: user.profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderImage
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(height: 300)
        .clipped()
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .teal.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Text(user.gamerTag.isEmpty ? user.fullName.prefix(1).uppercased() : user.gamerTag.prefix(1).uppercased())
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            )
    }

    private var tags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Platforms
                ForEach(user.platforms.prefix(2), id: \.self) { platform in
                    SearchTagView(text: platform, icon: "gamecontroller")
                }

                // Play style
                SearchTagView(text: user.playStyle, icon: "flame")

                // Voice chat preference
                if !user.voiceChatPreference.isEmpty && user.voiceChatPreference != VoiceChatPreference.noPreference.rawValue {
                    SearchTagView(text: user.voiceChatPreference, icon: "mic")
                }
            }
        }
    }
}

// MARK: - Tag View

struct SearchTagView: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)

            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// Corner radius extension is defined in Extensions.swift

// MARK: - Preview

struct SearchResultsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultsView()
    }
}
