//
//  CursusTableViewCell.swift
//  42Events
//
//  Created by Samantha HILLEBRAND on 2019/10/13.
//  Copyright © 2019 Rush00Team. All rights reserved.
//

import UIKit

class CursusTableViewCell: UITableViewCell {

    @IBOutlet weak var cursusLabel: UILabel!
    @IBOutlet weak var cursusBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
