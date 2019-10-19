//
//  FeedCell.swift
//  FlickerAPP
//
//  Created by Onur AKÇAY on 15.09.2019.
//  Copyright © 2019 Onur AKÇAY. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

   
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var flickrImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
