//
//  PokemonDetailsViewController.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 12/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit

class PokemonDetailsViewController: UIViewController {
    
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonMainImage: UIImageView!
    @IBOutlet weak var pokemonId: UILabel!
    @IBOutlet weak var type1image: UIImageView!
    @IBOutlet weak var type2image: UIImageView!
    
    var pokemon: Pokemon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pokemonNameLabel.text = pokemon?.name
        pokemonMainImage.image = UIImage(data: (pokemon?.image_front)!)
        pokemonId.text = pokemon?.id
        if let type1 = pokemon?.type1 {
            type1image.image = UIImage(named: type1)
        }
        if let type2 = pokemon?.type2 {
            type2image.image = UIImage(named: type2)
        }
    }
}

// TableView DataSource and Delegate methods
extension PokemonDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.restorationIdentifier == "StatsTableView" {
            return 6
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.restorationIdentifier == "StatsTableView" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PokemonDetailsViewCell
            switch indexPath.row {
            case 0:
                cell.AttributeNameLabel.text = "Attack"
                cell.attributeValueLabel.text = pokemon?.attack
            case 1:
                cell.AttributeNameLabel.text = "Defense"
                cell.attributeValueLabel.text = pokemon?.defense
            case 2:
                cell.AttributeNameLabel.text = "Speed"
                cell.attributeValueLabel.text = pokemon?.speed
            case 3:
                cell.AttributeNameLabel.text = "HP"
                cell.attributeValueLabel.text = pokemon?.hp
            case 4:
                cell.AttributeNameLabel.text = "Special Attack"
                cell.attributeValueLabel.text = pokemon?.special_attack
            case 5:
                cell.AttributeNameLabel.text = "Special Defense"
                cell.attributeValueLabel.text = pokemon?.special_defense
            default:
                print("case out of range")
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
}
