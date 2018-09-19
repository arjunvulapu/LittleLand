//
//  TeacherPostCell.swift
//  LittleLand
//
//  Created by Lead on 27/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class TeacherPostCell: UITableViewCell {
    
    @IBOutlet weak var imageview_Category: UIImageView!
    @IBOutlet weak var lbl_CategoryName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
