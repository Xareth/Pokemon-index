//
//  PokemonData.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import Foundation

struct PokemonData: Codable {
    var name: String
    var sprites: Sprite
    var order: Int
    var stats: [Stats]
    var types: [Types]
}

struct Sprite: Codable {
    var front_default: String
}

struct Stats: Codable {
    var base_stat: Int
    var stat: Stat
}

struct Stat: Codable {
    var name: String
}

struct Types: Codable {
    var type: Type
}

struct Type: Codable {
    var name: String
}
