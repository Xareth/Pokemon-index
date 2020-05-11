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
}

struct Sprite: Codable {
    var front_default: String
}
