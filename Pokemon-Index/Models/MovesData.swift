//
//  MovesData.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 14/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import Foundation


struct MovesData: Codable {
    var id: Int
    var name: String
    var effect_entries: [effect]
}

struct effect: Codable {
    var effect: String
}
