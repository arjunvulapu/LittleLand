//
//  chat_text_left_cell.swift
//  LittleLand
//
//  Created by Lead on 21/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class chat_text_left_cell: UITableViewCell {

    @IBOutlet weak var imageview_User: UIImageView!
    @IBOutlet weak var view_Chat_Message: UIView!
    @IBOutlet weak var lbl_Chat_Message: UILabel!
    @IBOutlet weak var lbl_Chat_Date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: self.imageview_User, cornurRadius: 15, isClipToBound: true, borderColor: "E1DFDF", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: self.view_Chat_Message, cornurRadius: 10, isClipToBound: true, borderColor: "", borderWidth: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
