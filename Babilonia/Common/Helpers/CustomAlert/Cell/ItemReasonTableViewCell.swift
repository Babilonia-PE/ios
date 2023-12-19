//
//  ItemReasonTableViewCell.swift
//  Babilonia
//
//  Created by Rafael Miranda Salas on 13/12/23.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import UIKit

class ItemReasonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    var selectedIndex: Int?
    var indexPath: IndexPath?
    
    static let identifier = "ItemReasonTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ItemReasonTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        radioButton.isSelected = selected
        if selected {
            radioButton.setImage(UIImage(named: "rbOnF"), for: .normal)
        } else {
            radioButton.setImage(UIImage(named: "rbOffO"), for: .normal)
        }
        
    }
    
}
