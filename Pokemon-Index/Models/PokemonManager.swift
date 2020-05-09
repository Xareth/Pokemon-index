//
//  PokemonManager.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit
import CoreData


struct PokemonManager {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
                        let pokemonData = self.parsePokemonJSON(newData: safeData)
                        print(pokemonData?.name)
                    }
                }
            }
            task.resume()
        }
    }
    
    // Decode JSON file into Pokemon Object
    func parsePokemonJSON(newData: Data) -> Pokemon? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(PokemonData.self, from: newData)
            let pokemon = Pokemon(context: self.context)
            pokemon.name = decodedData.name
            return pokemon
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}


