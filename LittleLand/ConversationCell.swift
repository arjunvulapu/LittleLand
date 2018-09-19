//
//  ConversationCell.swift
//  LittleLand
//
//  Created by Lead on 24/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var imageview_User: UIImageView!
    @IBOutlet weak var lbl_UserName: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_UnReadMessageCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_User, cornurRadius: 25, isClipToBound: true, borderColor: "E3E3E3", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: lbl_UnReadMessageCount, cornurRadius: 6.5, isClipToBound: true, borderColor: "", borderWidth: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
