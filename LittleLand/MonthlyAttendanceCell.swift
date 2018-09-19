//
//  MonthlyAttendanceCell.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class MonthlyAttendanceCell: UITableViewCell {

    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var lbl_Day: UILabel!
    @IBOutlet weak var lbl_PresentDays: UILabel!
    @IBOutlet weak var lbl_ApsentDays: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
