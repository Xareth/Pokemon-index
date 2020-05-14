//
//  PokemonListTableViewController.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit
import CoreData

class PokemonListTableViewController: UITableViewController {

    var pokemonManager = PokemonManager()
    var pokemonRequestResult = true
    var reloadData = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonManager.delegate = self
        
        tableView.rowHeight = 90
        
        pokemonManager.loadPokemons()
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonManager.pokemonArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PokemonListViewCell
        
        if let pokemon = pokemonManager.pokemonArray?[indexPath.row], let pokemonImage = pokemon.image_front {
            cell.pokemonName.text = pokemon.name
            cell.pokemonImage.image = UIImage(data: pokemonImage)
            if let type1 = pokemon.type1 {
                cell.type2Image.image = UIImage(imageLiteralResourceName: type1)
            }
            if let type2 = pokemon.type2 {
                cell.type1Image.image = UIImage(imageLiteralResourceName: type2)
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let pokemon = pokemonManager.pokemonArray?[indexPath.row] {
            pokemonManager.pokemonChosen = pokemon
            performSegue(withIdentifier: "goToPokemonDetails", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PokemonDetailsViewController
        destinationVC.pokemon = pokemonManager.pokemonChosen ?? nil
    }
    
    
    // MARK: - Update Pokemon List
    func updateModel() {
        DispatchQueue.main.async {
            self.pokemonManager.loadPokemons()
            if self.reloadData {
                self.tableView.reloadData()
            }
            print("updated")
        }
    }
    
    
    // MARK: - Pokemon loader
    func prepareMoves() {
        // Delete all moves
        print("Preparation for move download started")
        pokemonManager.loadMoves()
        if let movesArray = pokemonManager.movesArray {
            for move in movesArray {
                print("\(move.name) deleted")
                pokemonManager.deleteMoves(move: move)
            }
        }
        pokemonManager.saveItems()
        
        // Load new moves
        var runTime = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.61, repeats: true) { timer in
            runTime += 1
            if runTime <= 729 {
                self.pokemonManager.requestMove(move: String(runTime))
                print("Move updated \(runTime)")
            } else {
                timer.invalidate()
                print("Move database updated")
            }
        }
    }
    
    func preparePokemonList() {
        // Delete all pokemons
        print("Preparation started")
        pokemonManager.loadPokemons()
        if let pokemonArray = pokemonManager.pokemonArray {
            for pokemon in pokemonArray {
                pokemonManager.deletePokemon(pokemon: pokemon)
            }
        }
        pokemonManager.saveItems()
        
        
        // Download all pokemons
        var runTime = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 0.61, repeats: true) { timer in
            runTime += 1
            if self.pokemonRequestResult {
                print("Pokemon updated \(runTime)")
                self.pokemonManager.requestPokemon(pokemonName: String(runTime))
            } else {
                timer.invalidate()
            }
        }
        print("Preparation completed")
    }
    
    @IBAction func refreshPokemonsButton(_ sender: UIBarButtonItem) {
//        prepareMoves()
        preparePokemonList()
    }
}


// MARK: - Pokemon Manager Delegate
extension PokemonListTableViewController: PokemonRequestDelegate {
    
    
    func pokemonRequestDidFinish() {
        updateModel()
    }
    
    func pokemonRequestDidFinishWithError() {
        print(Error.self)
        pokemonRequestResult = false
    }
}


// MARK: - SearchBar Delegate
extension PokemonListTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("search started")
        // Create request and filter
        let request: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        
        if searchBar.text?.count != 0 {
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
            
            // Add filter (predicate) to request
            request.predicate = predicate
        }
        
        // Create sorting method
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        // Add sorting method to request
        request.sortDescriptors = [sortDescriptor]
        
        // Load items to pokemon Array
        pokemonManager.loadPokemons(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarSearchButtonClicked(searchBar)
        reloadData = false
    }
    
}


