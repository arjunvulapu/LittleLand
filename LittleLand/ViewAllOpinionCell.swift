//
//  ViewAllOpinionCell.swift
//  LittleLand
//
//  Created by Lead on 26/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ViewAllOpinionCell: UITableViewCell {
    
    @IBOutlet weak var imageview_Child: UIImageView!
    @IBOutlet weak var lbl_ParentsName: UILabel!
    @IBOutlet weak var lbl_ChildName: UILabel!
    @IBOutlet weak var lbl_Remark: UILabel!
    @IBOutlet weak var lbl_DateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Child, cornurRadius: 25, isClipToBound: true, borderColor: "E3E3E3", borderWidth: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
