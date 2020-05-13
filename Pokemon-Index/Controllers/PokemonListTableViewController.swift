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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonManager.delegate = self
        
        tableView.rowHeight = 90
        pokemonManager.loadItems()
        tableView.reloadData()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonManager.pokemonArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PokemonListViewCell
        
        if let pokemon = pokemonManager.pokemonArray?[indexPath.row], let pokemonImage = pokemon.image_front {
            cell.pokemonName.text = pokemon.name
            cell.pokemonImage.image = UIImage(data: pokemonImage)
            
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
            self.pokemonManager.loadItems()
            self.tableView.reloadData()
            print("updated")
        }
    }
    
    
    // MARK: - Pokemon loader
    func preparePokemonList() {
        // Delete all pokemons
        print("Preparation started")
        pokemonManager.loadItems()
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
                self.pokemonManager.requestPokemon(pokemonName: String(runTime))
            } else {
                timer.invalidate()
            }
        }
        print("Preparation completed")
    }
    @IBAction func refreshPokemonsButton(_ sender: UIBarButtonItem) {
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
        pokemonManager.loadItems(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarSearchButtonClicked(searchBar)
    }
    
}


