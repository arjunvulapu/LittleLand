//
//  ParentsAttendanceSubVC.swift
//  LittleLand
//
//  Created by Lead on 25/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ParentsAttendanceSubVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_TopView: UILabel!
    @IBOutlet weak var view_line_Report: UIView!
    @IBOutlet weak var tableview_Student: UITableView!
    
    
    //MARK:- Variable Declarations
    var reportsArray:NSMutableArray = NSMutableArray()
    var formatter:DateFormatter = DateFormatter()
    
    
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
            view_line_Report.isHidden = true
        }
        else{
            tableView.backgroundView = nil
            view_line_Report.isHidden = false
        }
        return reportsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "status") as! String).lowercased() == "present" {
            let cell:ParentsAttendanceCell = self.tableview_Student.dequeueReusableCell(withIdentifier: "ParentsAttendanceCell_Green") as! ParentsAttendanceCell
            
            cell.lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_present").uppercased()
            cell.lbl_Description.text = (!((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "remark") as! String).isEmpty ? ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "remark") as! String) : "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_remarks")))")
            
            formatter.dateFormat = "yyyy-MM-dd"
            let date:Date = formatter.date(from: ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "date") as! String))!
            formatter.dateFormat = "dd-MM"
            cell.lbl_Date.text = formatter.string(from: date)
            formatter.dateFormat = "EEEE"
            cell.lbl_Day.text = formatter.string(from: date).uppercased()
            
            return cell
        }
        else {
            let cell:ParentsAttendanceCell = self.tableview_Student.dequeueReusableCell(withIdentifier: "ParentsAttendanceCell_Red") as! ParentsAttendanceCell
            
            cell.lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_absent").uppercased()
            cell.lbl_Description.text = (!((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "remark") as! String).isEmpty ? ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "remark") as! String) : "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_remarks")))")
            
            formatter.dateFormat = "yyyy-MM-dd"
            let date:Date = formatter.date(from: ((reportsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "date") as! String))!
            formatter.dateFormat = "dd-MM"
            cell.lbl_Date.text = formatter.string(from: date)
            formatter.dateFormat = "EEEE"
            cell.lbl_Day.text = formatter.string(from: date).uppercased()
            
            return cell
        }
    }
    
}
