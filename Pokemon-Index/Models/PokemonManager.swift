//
//  PokemonManager.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import Foundation


struct PokemonManager {
    
    var baseString = "https://pokeapi.co/api/v2/"
    
    // Get API info about Pokemon
    func requestPokemon(pokemonName: String) {
        let urlString = String("\(baseString)/pokemon/\(pokemonName)/")
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    if let safeData = data {
                        let pokemonData = self.parseJSON(newData: safeData)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(newData: Data) -> PokemonModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PokemonData.self, from: newData)
            let name = decodedData.name
            let pokemon = PokemonModel(name: name)
            return pokemon
        } catch {
            print(error)
            return nil
        }
        
    }
    
}


