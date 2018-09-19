//
//  ParentsAttendanceCell.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ParentsAttendanceCell: UITableViewCell {

    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_Day: UILabel!
    
    @IBOutlet weak var view_Heder: UIView!
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var imageview_Check: UIImageView!
    @IBOutlet weak var btn_Check: UIButton!
    
    @IBOutlet weak var view_Description: UIView!
    @IBOutlet weak var lbl_Description: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
