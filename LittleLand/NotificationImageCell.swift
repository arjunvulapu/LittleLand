//
//  NotificationImageCell.swift
//  LittleLand
//
//  Created by Lead on 28/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class NotificationImageCell: UITableViewCell {
    
    @IBOutlet weak var imageview_Notification: UIImageView!
    @IBOutlet weak var lbl_NotificationName: UILabel!
    @IBOutlet weak var lbl_NotificationDescription: UILabel!
    @IBOutlet weak var lbl_NotificationDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Notification, cornurRadius: 25, isClipToBound: true, borderColor: "E3E3E3", borderWidth: 1.0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
