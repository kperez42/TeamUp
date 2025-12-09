//
//  GameDatabase.swift
//  TeamUp
//
//  Comprehensive database of popular games organized by category
//  Used for game selection, filtering, and matching
//

import Foundation
import SwiftUI

// MARK: - Game Model

struct Game: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let category: GameCategory
    let platforms: [String]
    let hasRankedMode: Bool
    let maxTeamSize: Int?
    let releaseYear: Int?
    let isPopular: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        category: GameCategory,
        platforms: [String],
        hasRankedMode: Bool = false,
        maxTeamSize: Int? = nil,
        releaseYear: Int? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.platforms = platforms
        self.hasRankedMode = hasRankedMode
        self.maxTeamSize = maxTeamSize
        self.releaseYear = releaseYear
        self.isPopular = isPopular
    }
}

// MARK: - Game Category

enum GameCategory: String, Codable, CaseIterable, Identifiable {
    case fps = "FPS"
    case moba = "MOBA"
    case battleRoyale = "Battle Royale"
    case mmo = "MMO"
    case sports = "Sports"
    case survival = "Survival"
    case boardCard = "Board/Card"
    case tabletop = "Tabletop RPG"
    case racing = "Racing"
    case fighting = "Fighting"
    case rpg = "RPG"
    case sandbox = "Sandbox"
    case horror = "Horror"
    case coOp = "Co-op"
    case party = "Party"
    case strategy = "Strategy"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .fps: return "scope"
        case .moba: return "map"
        case .battleRoyale: return "person.3"
        case .mmo: return "globe"
        case .sports: return "sportscourt"
        case .survival: return "tent"
        case .boardCard: return "rectangle.stack"
        case .tabletop: return "dice"
        case .racing: return "car"
        case .fighting: return "figure.boxing"
        case .rpg: return "wand.and.stars"
        case .sandbox: return "cube"
        case .horror: return "moon.stars"
        case .coOp: return "person.2"
        case .party: return "party.popper"
        case .strategy: return "brain"
        }
    }

    var color: Color {
        switch self {
        case .fps: return .red
        case .moba: return .blue
        case .battleRoyale: return .orange
        case .mmo: return .teal
        case .sports: return .green
        case .survival: return .brown
        case .boardCard: return .indigo
        case .tabletop: return .indigo
        case .racing: return .yellow
        case .fighting: return .red
        case .rpg: return .cyan
        case .sandbox: return .mint
        case .horror: return .gray
        case .coOp: return .teal
        case .party: return .cyan
        case .strategy: return .blue
        }
    }
}

// MARK: - Game Database

class GameDatabase {
    static let shared = GameDatabase()

    private init() {}

    // MARK: - All Games

    lazy var allGames: [Game] = {
        var games: [Game] = []
        games.append(contentsOf: fpsGames)
        games.append(contentsOf: mobaGames)
        games.append(contentsOf: battleRoyaleGames)
        games.append(contentsOf: mmoGames)
        games.append(contentsOf: sportsGames)
        games.append(contentsOf: survivalGames)
        games.append(contentsOf: boardCardGames)
        games.append(contentsOf: tabletopGames)
        games.append(contentsOf: racingGames)
        games.append(contentsOf: fightingGames)
        games.append(contentsOf: rpgGames)
        games.append(contentsOf: sandboxGames)
        games.append(contentsOf: horrorGames)
        games.append(contentsOf: coOpGames)
        games.append(contentsOf: partyGames)
        games.append(contentsOf: strategyGames)
        return games
    }()

    // MARK: - FPS Games

    let fpsGames: [Game] = [
        Game(title: "Valorant", category: .fps, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2020, isPopular: true),
        Game(title: "Counter-Strike 2", category: .fps, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2023, isPopular: true),
        Game(title: "Overwatch 2", category: .fps, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2022, isPopular: true),
        Game(title: "Call of Duty: Modern Warfare III", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 6, releaseYear: 2023, isPopular: true),
        Game(title: "Apex Legends", category: .fps, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2019, isPopular: true),
        Game(title: "Rainbow Six Siege", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2015, isPopular: true),
        Game(title: "Halo Infinite", category: .fps, platforms: ["PC", "Xbox"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2021, isPopular: true),
        Game(title: "Destiny 2", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 6, releaseYear: 2017, isPopular: true),
        Game(title: "Team Fortress 2", category: .fps, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 12, releaseYear: 2007),
        Game(title: "Escape from Tarkov", category: .fps, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 5, releaseYear: 2017, isPopular: true),
        Game(title: "Hunt: Showdown", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2019),
        Game(title: "DOOM Eternal", category: .fps, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 2, releaseYear: 2020),
        Game(title: "Battlefield 2042", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "XDefiant", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 6, releaseYear: 2024),
        Game(title: "The Finals", category: .fps, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2023),
    ]

    // MARK: - MOBA Games

    let mobaGames: [Game] = [
        Game(title: "League of Legends", category: .moba, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2009, isPopular: true),
        Game(title: "Dota 2", category: .moba, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2013, isPopular: true),
        Game(title: "Smite", category: .moba, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2014),
        Game(title: "Wild Rift", category: .moba, platforms: ["Mobile"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2020, isPopular: true),
        Game(title: "Heroes of the Storm", category: .moba, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2015),
        Game(title: "Mobile Legends: Bang Bang", category: .moba, platforms: ["Mobile"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2016),
        Game(title: "Pokemon Unite", category: .moba, platforms: ["Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2021),
        Game(title: "Arena of Valor", category: .moba, platforms: ["Mobile", "Nintendo"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2016),
    ]

    // MARK: - Battle Royale Games

    let battleRoyaleGames: [Game] = [
        Game(title: "Fortnite", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2017, isPopular: true),
        Game(title: "PUBG: Battlegrounds", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox", "Mobile"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2017, isPopular: true),
        Game(title: "Call of Duty: Warzone", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2020, isPopular: true),
        Game(title: "Apex Legends", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2019, isPopular: true),
        Game(title: "Fall Guys", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2020),
        Game(title: "Super People", category: .battleRoyale, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2022),
        Game(title: "Naraka: Bladepoint", category: .battleRoyale, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2021),
    ]

    // MARK: - MMO Games

    let mmoGames: [Game] = [
        Game(title: "World of Warcraft", category: .mmo, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 40, releaseYear: 2004, isPopular: true),
        Game(title: "Final Fantasy XIV", category: .mmo, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2010, isPopular: true),
        Game(title: "Elder Scrolls Online", category: .mmo, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 12, releaseYear: 2014, isPopular: true),
        Game(title: "Guild Wars 2", category: .mmo, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2012),
        Game(title: "New World", category: .mmo, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 5, releaseYear: 2021),
        Game(title: "Lost Ark", category: .mmo, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2022, isPopular: true),
        Game(title: "Black Desert Online", category: .mmo, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 5, releaseYear: 2014),
        Game(title: "RuneScape", category: .mmo, platforms: ["PC", "Mobile"], hasRankedMode: false, maxTeamSize: 5, releaseYear: 2001),
        Game(title: "Old School RuneScape", category: .mmo, platforms: ["PC", "Mobile"], hasRankedMode: false, maxTeamSize: 5, releaseYear: 2013),
        Game(title: "Star Wars: The Old Republic", category: .mmo, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2011),
    ]

    // MARK: - Sports Games

    let sportsGames: [Game] = [
        Game(title: "EA FC 24", category: .sports, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 11, releaseYear: 2023, isPopular: true),
        Game(title: "NBA 2K24", category: .sports, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2023, isPopular: true),
        Game(title: "Rocket League", category: .sports, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 3, releaseYear: 2015, isPopular: true),
        Game(title: "Madden NFL 24", category: .sports, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 11, releaseYear: 2023),
        Game(title: "MLB The Show 24", category: .sports, platforms: ["PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2024),
        Game(title: "NHL 24", category: .sports, platforms: ["PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 6, releaseYear: 2023),
        Game(title: "Golf With Your Friends", category: .sports, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 12, releaseYear: 2020),
        Game(title: "WWE 2K24", category: .sports, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2024),
    ]

    // MARK: - Survival Games

    let survivalGames: [Game] = [
        Game(title: "Minecraft", category: .survival, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2011, isPopular: true),
        Game(title: "Rust", category: .survival, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2018, isPopular: true),
        Game(title: "ARK: Survival Evolved", category: .survival, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2017),
        Game(title: "ARK: Survival Ascended", category: .survival, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2023),
        Game(title: "DayZ", category: .survival, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2018),
        Game(title: "Valheim", category: .survival, platforms: ["PC", "Xbox"], hasRankedMode: false, maxTeamSize: 10, releaseYear: 2021, isPopular: true),
        Game(title: "7 Days to Die", category: .survival, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2013),
        Game(title: "The Forest", category: .survival, platforms: ["PC", "PlayStation"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2018),
        Game(title: "Sons of the Forest", category: .survival, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2023),
        Game(title: "Palworld", category: .survival, platforms: ["PC", "Xbox"], hasRankedMode: false, maxTeamSize: 32, releaseYear: 2024, isPopular: true),
        Game(title: "Enshrouded", category: .survival, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 16, releaseYear: 2024),
        Game(title: "Grounded", category: .survival, platforms: ["PC", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2022),
    ]

    // MARK: - Board/Card Games

    let boardCardGames: [Game] = [
        Game(title: "Chess.com", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2007, isPopular: true),
        Game(title: "Lichess", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2010),
        Game(title: "Poker (PokerStars)", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 10, releaseYear: 2001),
        Game(title: "Hearthstone", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2014, isPopular: true),
        Game(title: "Magic: The Gathering Arena", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2018),
        Game(title: "Yu-Gi-Oh! Master Duel", category: .boardCard, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2022),
        Game(title: "Tabletop Simulator", category: .boardCard, platforms: ["PC", "VR"], hasRankedMode: false, maxTeamSize: 10, releaseYear: 2015, isPopular: true),
        Game(title: "Board Game Arena", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 10, releaseYear: 2010),
        Game(title: "Legends of Runeterra", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2020),
        Game(title: "Marvel Snap", category: .boardCard, platforms: ["PC", "Mobile"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2022),
        Game(title: "Balatro", category: .boardCard, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: 1, releaseYear: 2024, isPopular: true),
    ]

    // MARK: - Tabletop RPG Games

    let tabletopGames: [Game] = [
        Game(title: "Dungeons & Dragons", category: .tabletop, platforms: ["Tabletop", "PC"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 1974, isPopular: true),
        Game(title: "Pathfinder", category: .tabletop, platforms: ["Tabletop", "PC"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 2009),
        Game(title: "Call of Cthulhu", category: .tabletop, platforms: ["Tabletop"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 1981),
        Game(title: "Warhammer 40K", category: .tabletop, platforms: ["Tabletop"], hasRankedMode: false, maxTeamSize: 2, releaseYear: 1987),
        Game(title: "Vampire: The Masquerade", category: .tabletop, platforms: ["Tabletop"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 1991),
        Game(title: "Shadowrun", category: .tabletop, platforms: ["Tabletop"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 1989),
        Game(title: "Starfinder", category: .tabletop, platforms: ["Tabletop"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 2017),
        Game(title: "Roll20", category: .tabletop, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 10, releaseYear: 2012, isPopular: true),
        Game(title: "Foundry VTT", category: .tabletop, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 10, releaseYear: 2020),
        Game(title: "D&D Beyond", category: .tabletop, platforms: ["PC", "Mobile"], hasRankedMode: false, maxTeamSize: 10, releaseYear: 2017),
    ]

    // MARK: - Racing Games

    let racingGames: [Game] = [
        Game(title: "Forza Horizon 5", category: .racing, platforms: ["PC", "Xbox"], hasRankedMode: true, maxTeamSize: 12, releaseYear: 2021, isPopular: true),
        Game(title: "Gran Turismo 7", category: .racing, platforms: ["PlayStation"], hasRankedMode: true, maxTeamSize: 20, releaseYear: 2022),
        Game(title: "Mario Kart 8 Deluxe", category: .racing, platforms: ["Nintendo"], hasRankedMode: true, maxTeamSize: 12, releaseYear: 2017, isPopular: true),
        Game(title: "F1 24", category: .racing, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 22, releaseYear: 2024),
        Game(title: "Assetto Corsa Competizione", category: .racing, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 30, releaseYear: 2019),
        Game(title: "iRacing", category: .racing, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 60, releaseYear: 2008),
        Game(title: "Need for Speed Unbound", category: .racing, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 16, releaseYear: 2022),
        Game(title: "Wreckfest", category: .racing, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 24, releaseYear: 2018),
    ]

    // MARK: - Fighting Games

    let fightingGames: [Game] = [
        Game(title: "Street Fighter 6", category: .fighting, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2023, isPopular: true),
        Game(title: "Tekken 8", category: .fighting, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2024, isPopular: true),
        Game(title: "Mortal Kombat 1", category: .fighting, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2023),
        Game(title: "Super Smash Bros. Ultimate", category: .fighting, platforms: ["Nintendo"], hasRankedMode: true, maxTeamSize: 8, releaseYear: 2018, isPopular: true),
        Game(title: "Guilty Gear Strive", category: .fighting, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2021),
        Game(title: "Dragon Ball FighterZ", category: .fighting, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 2, releaseYear: 2018),
        Game(title: "MultiVersus", category: .fighting, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2024),
        Game(title: "Brawlhalla", category: .fighting, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2017),
    ]

    // MARK: - RPG Games

    let rpgGames: [Game] = [
        Game(title: "Baldur's Gate 3", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2023, isPopular: true),
        Game(title: "Elden Ring", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2022, isPopular: true),
        Game(title: "Diablo IV", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2023, isPopular: true),
        Game(title: "Path of Exile", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 2013),
        Game(title: "Genshin Impact", category: .rpg, platforms: ["PC", "PlayStation", "Mobile"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2020, isPopular: true),
        Game(title: "Honkai: Star Rail", category: .rpg, platforms: ["PC", "PlayStation", "Mobile"], hasRankedMode: false, maxTeamSize: 1, releaseYear: 2023),
        Game(title: "Monster Hunter Rise", category: .rpg, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "Monster Hunter World", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2018),
        Game(title: "Divinity: Original Sin 2", category: .rpg, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2017),
        Game(title: "Cyberpunk 2077", category: .rpg, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 1, releaseYear: 2020),
    ]

    // MARK: - Sandbox Games

    let sandboxGames: [Game] = [
        Game(title: "Minecraft", category: .sandbox, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2011, isPopular: true),
        Game(title: "Roblox", category: .sandbox, platforms: ["PC", "PlayStation", "Xbox", "Mobile"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2006, isPopular: true),
        Game(title: "Terraria", category: .sandbox, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: 16, releaseYear: 2011),
        Game(title: "No Man's Sky", category: .sandbox, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 32, releaseYear: 2016),
        Game(title: "Garry's Mod", category: .sandbox, platforms: ["PC"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2006),
        Game(title: "Space Engineers", category: .sandbox, platforms: ["PC", "Xbox"], hasRankedMode: false, maxTeamSize: 16, releaseYear: 2019),
        Game(title: "Satisfactory", category: .sandbox, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2024),
        Game(title: "Factorio", category: .sandbox, platforms: ["PC", "Nintendo"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2020),
    ]

    // MARK: - Horror Games

    let horrorGames: [Game] = [
        Game(title: "Phasmophobia", category: .horror, platforms: ["PC", "VR"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2020, isPopular: true),
        Game(title: "Dead by Daylight", category: .horror, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: true, maxTeamSize: 5, releaseYear: 2016, isPopular: true),
        Game(title: "Lethal Company", category: .horror, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2023, isPopular: true),
        Game(title: "Devour", category: .horror, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "The Texas Chain Saw Massacre", category: .horror, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 7, releaseYear: 2023),
        Game(title: "Forewarned", category: .horror, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "Demonologist", category: .horror, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2023),
        Game(title: "Content Warning", category: .horror, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2024),
    ]

    // MARK: - Co-op Games

    let coOpGames: [Game] = [
        Game(title: "It Takes Two", category: .coOp, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 2, releaseYear: 2021, isPopular: true),
        Game(title: "A Way Out", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 2, releaseYear: 2018),
        Game(title: "Deep Rock Galactic", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2020, isPopular: true),
        Game(title: "Helldivers 2", category: .coOp, platforms: ["PC", "PlayStation"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2024, isPopular: true),
        Game(title: "Left 4 Dead 2", category: .coOp, platforms: ["PC", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2009),
        Game(title: "Back 4 Blood", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "Payday 3", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2023),
        Game(title: "Portal 2", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 2, releaseYear: 2011),
        Game(title: "Overcooked! 2", category: .coOp, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2018),
        Game(title: "Sea of Thieves", category: .coOp, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2018, isPopular: true),
        Game(title: "Don't Starve Together", category: .coOp, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 6, releaseYear: 2016),
    ]

    // MARK: - Party Games

    let partyGames: [Game] = [
        Game(title: "Among Us", category: .party, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: 15, releaseYear: 2018, isPopular: true),
        Game(title: "Jackbox Party Packs", category: .party, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2014, isPopular: true),
        Game(title: "Fall Guys", category: .party, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2020),
        Game(title: "Pummel Party", category: .party, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2018),
        Game(title: "Mario Party Superstars", category: .party, platforms: ["Nintendo"], hasRankedMode: false, maxTeamSize: 4, releaseYear: 2021),
        Game(title: "Gartic Phone", category: .party, platforms: ["PC"], hasRankedMode: false, maxTeamSize: 30, releaseYear: 2020),
        Game(title: "Stumble Guys", category: .party, platforms: ["PC", "Mobile"], hasRankedMode: false, maxTeamSize: 32, releaseYear: 2021),
        Game(title: "Gang Beasts", category: .party, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2017),
        Game(title: "Human Fall Flat", category: .party, platforms: ["PC", "PlayStation", "Xbox", "Nintendo", "Mobile"], hasRankedMode: false, maxTeamSize: 8, releaseYear: 2016),
    ]

    // MARK: - Strategy Games

    let strategyGames: [Game] = [
        Game(title: "Civilization VI", category: .strategy, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: true, maxTeamSize: 12, releaseYear: 2016),
        Game(title: "Age of Empires IV", category: .strategy, platforms: ["PC", "Xbox"], hasRankedMode: true, maxTeamSize: 8, releaseYear: 2021),
        Game(title: "StarCraft II", category: .strategy, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 4, releaseYear: 2010),
        Game(title: "Total War: Warhammer III", category: .strategy, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 8, releaseYear: 2022),
        Game(title: "Company of Heroes 3", category: .strategy, platforms: ["PC"], hasRankedMode: true, maxTeamSize: 8, releaseYear: 2023),
        Game(title: "Europa Universalis IV", category: .strategy, platforms: ["PC"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2013),
        Game(title: "Crusader Kings III", category: .strategy, platforms: ["PC", "PlayStation", "Xbox"], hasRankedMode: false, maxTeamSize: nil, releaseYear: 2020),
        Game(title: "XCOM 2", category: .strategy, platforms: ["PC", "PlayStation", "Xbox", "Nintendo"], hasRankedMode: false, maxTeamSize: 1, releaseYear: 2016),
    ]

    // MARK: - Helper Methods

    func games(for category: GameCategory) -> [Game] {
        return allGames.filter { $0.category == category }
    }

    func popularGames() -> [Game] {
        return allGames.filter { $0.isPopular }
    }

    func games(for platform: String) -> [Game] {
        return allGames.filter { $0.platforms.contains(platform) }
    }

    func searchGames(query: String) -> [Game] {
        let lowercasedQuery = query.lowercased()
        return allGames.filter { $0.title.lowercased().contains(lowercasedQuery) }
    }

    func rankedGames() -> [Game] {
        return allGames.filter { $0.hasRankedMode }
    }

    func gameTitles() -> [String] {
        return allGames.map { $0.title }.sorted()
    }

    func game(withTitle title: String) -> Game? {
        return allGames.first { $0.title.lowercased() == title.lowercased() }
    }
}

// MARK: - Quick Access Extension

extension GameDatabase {
    /// Get popular game titles as a simple string array
    var popularGameTitles: [String] {
        popularGames().map { $0.title }
    }

    /// Categories with game counts
    var categoriesWithCounts: [(category: GameCategory, count: Int)] {
        GameCategory.allCases.map { category in
            (category: category, count: games(for: category).count)
        }
    }
}
