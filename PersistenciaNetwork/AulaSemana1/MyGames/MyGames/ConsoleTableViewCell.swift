//
//  ConsoleTableViewCell.swift
//  MyGames
//
//  Created by Thiago Matheus on 28/05/20.
//  Copyright © 2020 Douglas Frari. All rights reserved.
//

import UIKit

class ConsoleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tvConsoleName: UILabel!
    @IBOutlet weak var ivConsolelOGO: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with console: Console) {
        
        tvConsoleName.text = console.name ?? ""
        if let image = console.cover as? UIImage {
            ivConsolelOGO.image = image
        } else {
            ivConsolelOGO.image = UIImage(named: "noCover")
        }
    }

}
