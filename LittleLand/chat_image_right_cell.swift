//
//  chat_image_right_cell.swift
//  LittleLand
//
//  Created by Lead on 21/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class chat_image_right_cell: UITableViewCell {
    
    @IBOutlet weak var imageview_User: UIImageView!
    @IBOutlet weak var view_Chat_Image: UIView!
    @IBOutlet weak var imageview_Chat_Image: UIImageView!
    @IBOutlet weak var lbl_Chat_Date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: self.imageview_User, cornurRadius: 15, isClipToBound: true, borderColor: "E1DFDF", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: self.view_Chat_Image, cornurRadius: 13, isClipToBound: true, borderColor: "", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: self.imageview_Chat_Image, cornurRadius: 13, isClipToBound: true, borderColor: "", borderWidth: 1.0)
        imageview_Chat_Image.image = UIImage(named: "ic_cuteteacher")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
