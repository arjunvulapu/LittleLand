//
//  MonthlyAttendanceSubVC.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class MonthlyAttendanceSubVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_TopView: UILabel!
    @IBOutlet weak var tableview_Student: UITableView!
    
    
    //MARK:- Variable Declarations
    var reportsArray:NSMutableArray = NSMutableArray()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_TopView.backgroundColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "CBD9BF")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reportsArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableView.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_No_Reports_Found")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
        }
        else{
            tableView.backgroundView = nil
        }
        return reportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MonthlyAttendanceCell = self.tableview_Student.dequeueReusableCell(withIdentifier: "MonthlyAttendanceCell") as! MonthlyAttendanceCell
        cell.contentView.backgroundColor = (indexPath.row % 2 == 0 ? ApiUtillity.sharedInstance.getColorIntoHex(Hex: "F2F2F2") : ApiUtillity.sharedInstance.getColorIntoHex(Hex: "F9F9F9"))
        
        cell.lbl_Date.text = ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "year") as! String)
        cell.lbl_Day.text = ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "month") as! String).uppercased()
        cell.lbl_PresentDays.text = "\(((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "present") as! String)) \(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_days"))"
        cell.lbl_ApsentDays.text = "\(((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "absent") as! String)) \(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_days"))"
        
        return cell
    }
    
}
