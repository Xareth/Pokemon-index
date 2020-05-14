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
    var movesArray: [Moves]?
    var pokemonChosen: Pokemon?
    
    var baseString = "https://pokeapi.co/api/v2/"
    
    var delegate: PokemonRequestDelegate?
    
    
    // MARK: - Pokemon downloader
    // Get API info about Pokemon
    func requestPokemon(pokemonName: String) {
        let urlString = String("\(baseString)/pokemon/\(pokemonName)/")
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "There was unknown error in requestPokemon\task")
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
            pokemon.id = String(decodedData.order)
            pokemon.name = decodedData.name.capitalized
            pokemon.image_url = decodedData.sprites.front_default
            pokemon.image_front = getPokemonImage(url: decodedData.sprites.front_default)
            
            let pokemonStats = adjustPokemonStats(data: decodedData)
            pokemon.attack = pokemonStats["attack"]
            pokemon.defense = pokemonStats["defense"]
            pokemon.hp = pokemonStats["hp"]
            pokemon.speed = pokemonStats["speed"]
            pokemon.special_attack = pokemonStats["special-attack"]
            pokemon.special_defense = pokemonStats["special-defense"]
            
            pokemon.type1 = decodedData.types[0].type.name
            if decodedData.types.count == 2 {
                pokemon.type2 = decodedData.types[1].type.name
            }
            
            for ability in decodedData.abilities {
                let move = loadMove(name: ability.ability.name)
                pokemon.moves?.adding(move)
                print("Ability name \(ability.ability.name)")
            }
            
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
    
    // Adjust Stats for pokemons
    func adjustPokemonStats(data: PokemonData) -> [String : String] {
        var pokemonStats = [String : String]()
        for number in 0...data.stats.count - 1 {
            pokemonStats[data.stats[number].stat.name] = String(data.stats[number].base_stat)
        }
        
        return pokemonStats
    }
    
    // MARK: - Moves downloader
    func requestMove(move: String) {
        let urlString = String("https://pokeapi.co/api/v2/move/\(move)")
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "There was unknown error in requestPokemon\task")
                } else {
                    if let safeData = data {
                        let result = self.parseMovesJSON(newData: safeData)
                        self.saveItems()
                    }
                }
            }
            task.resume()
        }
    }

    
    func parseMovesJSON(newData: Data) -> Moves? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(MovesData.self, from: newData)
            let move = Moves(context: self.context)
            move.id = String(decodedData.id)
            move.name = decodedData.name
            move.effect = decodedData.effect_entries[0].effect
            return move
        } catch {
            print("There was error in parseMovesJSON: \(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Core Data methods
    // Save All items to Core Data
    func saveItems() {
        do {
            try self.context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Load Pokemons to pokemonArray
    mutating func loadPokemons(with request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()) {
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
    
    // Load Moves to moveArray
    mutating func loadMoves(with request: NSFetchRequest<Moves> = Moves.fetchRequest()) {
        do {
            movesArray = try context.fetch(request)
        } catch {
            print("Error while fetching Item data: \(error.localizedDescription)")
        }
    }
    
    // Load Move
    func loadMove(name: String) -> Moves? {
        let request: NSFetchRequest<Moves> = Moves.fetchRequest()
        let predicate = NSPredicate(format: "name MATCHES[cd] %@", name)
        request.predicate = predicate
        
        do {
            let move = try context.fetch(request)
            return move[0]
        } catch {
            print("Error while fetching Item data: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Delete Moves
    func deleteMoves(move: NSManagedObject) {
        context.delete(move)
        do {
            try context.save()
            print("Move deleted")
        } catch {
            print(error.localizedDescription)
        }
    }
    
}


