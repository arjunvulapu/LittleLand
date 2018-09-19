//
//  DailyAttendanceCell.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class DailyAttendanceCell: UITableViewCell {

    @IBOutlet weak var view_Cell: UIView!
    
    @IBOutlet weak var imageview_Student: UIImageView!
    @IBOutlet weak var lbl_StudentName: UILabel!
    
    @IBOutlet weak var imageview_Switch_Background: UIImageView!
    
    @IBOutlet weak var lbl_Present_Green: UILabel!
    @IBOutlet weak var lbl_Absent_Red: UILabel!
    @IBOutlet weak var lbl_Present: UILabel!
    @IBOutlet weak var lbl_Absent: UILabel!
    
    @IBOutlet weak var btn_Present: UIButton!
    @IBOutlet weak var btn_Present_Action: UIButton!
    @IBOutlet weak var btn_Normal: UIButton!
    @IBOutlet weak var btn_Absent: UIButton!
    @IBOutlet weak var btn_Absent_Action: UIButton!
    
    @IBOutlet weak var imageview_Switch: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Student, cornurRadius: 20, isClipToBound: true, borderColor: "55AF58", borderWidth: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
