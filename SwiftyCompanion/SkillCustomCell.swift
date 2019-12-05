//
//  SkillCustomCell.swift
//  SwiftyCompanion
//
//  Created by Ryan de Kwaadsteniet on 12/5/19.
//  Copyright © 2019 Ryan de Kwaadsteniet. All rights reserved.
//

import UIKit

class SkillCustomCell: UITableViewCell {

    @IBOutlet weak var skillLevel: UILabel!
    @IBOutlet weak var skillName: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var skill: Skill? {
        didSet {
            if skill != nil {
                skillName.text = skill!.name
                skillLevel.text = "\(skill!.score)"
                progressBar.setProgress(skill!.score.truncatingRemainder(dividingBy: 1.0), animated: true)
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

