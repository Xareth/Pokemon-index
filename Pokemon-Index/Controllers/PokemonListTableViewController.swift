//
//  PokemonListTableViewController.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 06/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit

class PokemonListTableViewController: UITableViewController {

    var pokemonManager = PokemonManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }
    
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemonManager.pokemonArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonListViewCell", for: indexPath) as! PokemonListViewCell
        
        if let pokemon = pokemonManager.pokemonArray?[indexPath.row] {
            
            cell.pokemonNameLabel.text = pokemon.name ?? "No pokemons available"
            

            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Pokemon Loader
    // Download all pokemons to db
    func downloadPokemonDB() {
        var runTime = 1
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            print(runTime)
            DispatchQueue.main.async {
                self.pokemonManager.requestPokemon(pokemonName: String(runTime))
                self.pokemonManager.loadItems()
                self.tableView.reloadData()
            }
            
            runTime += 1
            
            if runTime == 10 {
                timer.invalidate()
            }
        }
    }


}

