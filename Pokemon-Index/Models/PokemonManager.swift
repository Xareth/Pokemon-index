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
    
    var pokemonArray: [Pokemon]?
    var pokemonImageDict: Dictionary = [String : UIImage]()
    
    
    
    // MARK: - Pokemon Data Api Import
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
                        self.saveItems()
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
            pokemon.image_url = decodedData.sprites.front_default
            return pokemon
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // Delete db of pokemons
    func deletePokemons() {
        // Delete pokemons from Core
        do {
            for object in pokemonArray! {
                context.delete(object)
            }
        }
        saveItems()
    }

    
    // Save Pokemon to Core Data
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Load Pokemons to pokemonArray
    mutating func loadItems(with request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()) {
        do {
            pokemonArray = try context.fetch(request)
            if let savePokemonArray = pokemonArray {
                for pokemon in savePokemonArray {
                    print(pokemon.name)
                }
            }
        } catch {
            print("Error while fetching Item data: \(error.localizedDescription)")
        }
    }

    // Get image from url request
    mutating func getImage(from string: String) {
        if let url = URL(string: string) {
            do {
                let imageData = try Data(contentsOf: url, options: [])
                let image = UIImage(data: imageData)
                print("image \(image)")
                pokemonImageDict[string] = image
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
}


