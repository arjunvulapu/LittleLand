//
//  MonthlyCalendarEventCell.swift
//  LittleLand
//
//  Created by Lead on 21/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class MonthlyCalendarEventCell: UITableViewCell {

    @IBOutlet weak var view_Event: UIView!
    @IBOutlet weak var lbl_Total: UILabel!
    @IBOutlet weak var lbl_Notes: UILabel!
    @IBOutlet weak var imageview_Alarm: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Event, cornurRadius: 15.0, isClipToBound: true, borderColor: "FFFFFF", borderWidth: 0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: lbl_Total, cornurRadius: 11, isClipToBound: true, borderColor: "FFFFFF", borderWidth: 1.0)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
