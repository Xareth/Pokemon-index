//
//  PokemonManager.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit
import CoreData


protocol PokemonRequestDelegate {
    func pokemonRequestDidFinish()
    func pokemonRequestDidFinishWithError()
}


struct PokemonManager {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var pokemonArray: [Pokemon]?
    
    var baseString = "https://pokeapi.co/api/v2/"
    
    var delegate: PokemonRequestDelegate?
    
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
                        if pokemonData == nil {
                            self.delegate?.pokemonRequestDidFinishWithError()
                        } else {
                            self.delegate?.pokemonRequestDidFinish()
                        }
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
            pokemon.name = decodedData.name.capitalized
            pokemon.image_url = decodedData.sprites.front_default
            pokemon.image_front = getPokemonImage(url: decodedData.sprites.front_default)
            print("New pokemon added \(pokemon.name)")
            return pokemon
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    // Download image sprite for pokemon
    func getPokemonImage(url: String) -> Data? {
        if let url = URL(string: url) {
            do {
                let imageData = try Data(contentsOf: url, options: [])
                let image = UIImage(data: imageData)
                return image?.jpegData(compressionQuality: 1.0)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
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
        } catch {
            print("Error while fetching Item data: \(error.localizedDescription)")
        }
    }
    
    // Delete Pokemon
    func deletePokemon(pokemon: NSManagedObject) {
        context.delete(pokemon)
        do {
            try context.save()
            print("Pokemon deleted")
        } catch {
            print(error.localizedDescription)
        }
        
    }
}


