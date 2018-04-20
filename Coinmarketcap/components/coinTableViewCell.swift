//
//  coinTableViewCell.swift
//  Coinmarketcap
//
//  Created by Nikodem Strawa on 16/04/2018.
//  Copyright © 2018 Nikodem Strawa. All rights reserved.
//

import UIKit

class coinTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var coinPrice: UILabel!
    @IBOutlet weak var coinRank: UILabel!
    @IBOutlet weak var coinChange: UILabel!
    @IBOutlet weak var coinImage: UIImageView!
    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var sparklines: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(0, 0, 2, 0))
    }

    
}
