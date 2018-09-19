//
//  TeacherPostHederCell.swift
//  LittleLand
//
//  Created by Lead on 27/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class TeacherPostHederCell: UITableViewCell {

    @IBOutlet weak var btn_Heder: UIButton!
    
    @IBOutlet weak var imageview_Post: UIImageView!
    @IBOutlet weak var lbl_PostName: UILabel!
    @IBOutlet weak var lbl_PostDesc: UILabel!
    @IBOutlet weak var imageview_DropDown: UIImageView!
    @IBOutlet weak var view_Bottom: UIView!
    @IBOutlet weak var view_Bottom_Bottom: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
