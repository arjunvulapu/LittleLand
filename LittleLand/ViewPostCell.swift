//
//  ViewPostCell.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ViewPostCell: UITableViewCell {

    @IBOutlet weak var view_Main: UIView!
    
    @IBOutlet weak var imageview_Post: UIImageView!
    
    @IBOutlet weak var view_Desc: UIView!
    @IBOutlet weak var lbl_DescName: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Main, cornurRadius: 10, isClipToBound: true, borderColor: "A282BC", borderWidth: 5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Desc, cornurRadius: 10, isClipToBound: true, borderColor: "A282BC", borderWidth: 3)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
