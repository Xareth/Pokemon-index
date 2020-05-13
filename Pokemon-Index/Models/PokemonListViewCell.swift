//
//  PokemonListViewCell.swift
//  Pokemon-Index
//
//  Created by Mikołaj Szadkowski on 11/05/2020.
//  Copyright © 2020 Mikołaj Szadkowski. All rights reserved.
//

import UIKit

class PokemonListViewCell: UITableViewCell {

    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    @IBOutlet weak var type1Image: UIImageView!
    @IBOutlet weak var type2Image: UIImageView!
    
    override func prepareForReuse() {
        pokemonName.text = ""
        pokemonImage.image = nil
        type1Image.image = nil
        type2Image.image = nil
    }
    
}
