//
//  ProjectCustomCell.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/5/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import UIKit

class ProjectCustomCell: UITableViewCell {
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectScore: UILabel!

    var project: Project? {
        didSet {
            if project != nil {
                projectName.text = project!.name
                projectScore.text = project!.scoreString
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

