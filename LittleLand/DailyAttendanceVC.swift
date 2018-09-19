//
//  DailyAttendanceVC.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class DailyAttendanceVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var tableview_DailyAttendance: UITableView!
    
    
    //MARK:- Variable Declarations
    public var selectedClassID:String = String()
    var attendanceArr:NSMutableDictionary = NSMutableDictionary()
    var childsArray:NSMutableArray = NSMutableArray()
    
    let customeFormatter:DateFormatter = DateFormatter()
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_daily_attendence").uppercased()
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        self.getAttendanceData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        
    }
    
    @IBAction func btn_Handler_Normal(_ sender: UIButton) {
        let tag:Int = sender.tag
        
        let uid:String = (childsArray.object(at: tag) as! NSDictionary).value(forKey: "uid") as! String
        attendanceArr.setValue("-1", forKey: uid)
        
        let cell:DailyAttendanceCell = self.tableview_DailyAttendance.cellForRow(at: IndexPath(row: tag, section: 0)) as! DailyAttendanceCell
        UIView.animate(withDuration: 0.3, animations: { 
            cell.lbl_Absent.isHidden = false
            cell.lbl_Present.isHidden = false
            cell.lbl_Present_Green.isHidden = true
            cell.lbl_Absent_Red.isHidden = true
            
            cell.imageview_Switch.frame = cell.btn_Normal.frame
            cell.imageview_Switch_Background.image = UIImage(named: "ic_switch_background")
        }, completion: { (true) in
            
        })
    }
    
    @IBAction func btn_Handler_Present(_ sender: UIButton) {
        let tag:Int = sender.tag
        
        let uid:String = (childsArray.object(at: tag) as! NSDictionary).value(forKey: "uid") as! String
        attendanceArr.setValue("1", forKey: uid)
        self.setAttendanceData(student_uid: uid, attendance: "present")
        
        let cell:DailyAttendanceCell = self.tableview_DailyAttendance.cellForRow(at: IndexPath(row: tag, section: 0)) as! DailyAttendanceCell
        UIView.animate(withDuration: 0.3, animations: {
            cell.lbl_Absent.isHidden = true
            cell.lbl_Present.isHidden = true
            cell.lbl_Present_Green.isHidden = false
            cell.lbl_Absent_Red.isHidden = true
            
            cell.imageview_Switch.frame = cell.btn_Present.frame
            cell.imageview_Switch_Background.image = UIImage(named: "ic_switch_background_green")
        }, completion: { (true) in
            
        })
    }
    
    @IBAction func btn_Handler_Absent(_ sender: UIButton) {
        let tag:Int = sender.tag
        
        let uid:String = (childsArray.object(at: tag) as! NSDictionary).value(forKey: "uid") as! String
        attendanceArr.setValue("0", forKey: uid)
        self.setAttendanceData(student_uid: uid, attendance: "absent")
        
        let cell:DailyAttendanceCell = self.tableview_DailyAttendance.cellForRow(at: IndexPath(row: tag, section: 0)) as! DailyAttendanceCell
        UIView.animate(withDuration: 0.3, animations: {
            cell.lbl_Absent.isHidden = true
            cell.lbl_Present.isHidden = true
            cell.lbl_Present_Green.isHidden = true
            cell.lbl_Absent_Red.isHidden = false
            
            cell.imageview_Switch.frame = cell.btn_Absent.frame
            cell.imageview_Switch_Background.image = UIImage(named: "ic_switch_background_red")
        }, completion: { (true) in
            
        })
    }
    
    
    //MARK:- All Method
    func getAttendanceData() {
        customeFormatter.dateFormat = "yyyy-MM-dd"
        
        let params = ["action":"get", "uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "type":ApiUtillity.sharedInstance.getLoginType(), "date":customeFormatter.string(from: Date()), "class_id":selectedClassID, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "attendance_daily.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.childsArray = success
                    for (i,item) in self.childsArray.enumerated() {
                        print(i)
                        self.attendanceArr.setValue((item as! NSDictionary).value(forKey: "present") as! String, forKey: (item as! NSDictionary).value(forKey: "uid") as! String)
                    }
                    self.tableview_DailyAttendance.reloadData()
                    
                    ApiUtillity.sharedInstance.dismissSVProgressHUD()
                }
                else {
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithError(error: (dict.value(forKey: "error") as! String))
                }
            }
            else {
                ApiUtillity.sharedInstance.dismissSVProgressHUDWithAPIError(error: response.error! as NSError)
            }
        }
    }
    
    func setAttendanceData(student_uid:String, attendance:String) {
        customeFormatter.dateFormat = "yyyy-MM-dd"
        
        let params = ["action":"add_attendance", "uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "student_uid":student_uid, "type":ApiUtillity.sharedInstance.getLoginType(), "date":customeFormatter.string(from: Date()), "class_id":selectedClassID, "attendance":attendance, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "attendance_daily.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:String = dict.value(forKey: "success") as! String
                    print(success)
                    
                    ApiUtillity.sharedInstance.dismissSVProgressHUD()
                }
                else {
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithError(error: (dict.value(forKey: "error") as! String))
                }
            }
            else {
                ApiUtillity.sharedInstance.dismissSVProgressHUDWithAPIError(error: response.error! as NSError)
            }
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                let tag:Int = (gesture.view?.tag)!
                let cell:DailyAttendanceCell = self.tableview_DailyAttendance.cellForRow(at: IndexPath(row: tag, section: 0)) as! DailyAttendanceCell
                self.btn_Handler_Absent(cell.btn_Absent)
            case UISwipeGestureRecognizerDirection.left:
                let tag:Int = (gesture.view?.tag)!
                let cell:DailyAttendanceCell = self.tableview_DailyAttendance.cellForRow(at: IndexPath(row: tag, section: 0)) as! DailyAttendanceCell
                self.btn_Handler_Present(cell.btn_Present)
            default:
                break
            }
        }
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if attendanceArr.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_DailyAttendance.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_student_here")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_DailyAttendance.backgroundView = noDataLabel
        }
        else {
            tableview_DailyAttendance.backgroundView = nil
        }
        return attendanceArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DailyAttendanceCell = self.tableview_DailyAttendance.dequeueReusableCell(withIdentifier: "DailyAttendanceCell") as! DailyAttendanceCell
        
        cell.imageview_Student.kf.setImage(with: URL(string: (childsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String))
        cell.lbl_StudentName.text = "\((childsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "fname") as! String) \((childsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "lname") as! String)"
        
        //cell.btn_Normal.addTarget(self, action: #selector(btn_Handler_Normal(_:)), for: .touchUpInside)
        //cell.btn_Normal.tag = indexPath.row
        cell.btn_Present_Action.addTarget(self, action: #selector(btn_Handler_Present(_:)), for: .touchUpInside)
        cell.btn_Present_Action.tag = indexPath.row
        cell.btn_Absent_Action.addTarget(self, action: #selector(btn_Handler_Absent(_:)), for: .touchUpInside)
        cell.btn_Absent_Action.tag = indexPath.row
        
        cell.imageview_Switch_Background.isUserInteractionEnabled = true
        cell.imageview_Switch_Background.tag = indexPath.row
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        cell.imageview_Switch_Background.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.imageview_Switch_Background.addGestureRecognizer(swipeLeft)
        
        cell.view_Cell.backgroundColor = (indexPath.row % 2 == 0 ? ApiUtillity.sharedInstance.getColorIntoHex(Hex: "F2F2F2") : ApiUtillity.sharedInstance.getColorIntoHex(Hex: "F9F9F9"))
        
        let uid:String = (childsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String
        if attendanceArr.value(forKey: uid) as! String == "-1" {
            cell.lbl_Absent.isHidden = false
            cell.lbl_Present.isHidden = false
            cell.lbl_Present_Green.isHidden = true
            cell.lbl_Absent_Red.isHidden = true
            
            cell.imageview_Switch.frame = cell.btn_Normal.frame
            cell.imageview_Switch_Background.image = (ApiUtillity.sharedInstance.checkCurrentlanguageEnglishOrNot() == true ? UIImage(named: "ic_switch_background") : UIImage(named: "ic_switch_background_ar"))
        }
        else if attendanceArr.value(forKey: uid) as! String == "1" {
            cell.lbl_Absent.isHidden = true
            cell.lbl_Present.isHidden = true
            cell.lbl_Present_Green.isHidden = false
            cell.lbl_Absent_Red.isHidden = true
            
            cell.imageview_Switch.frame = cell.btn_Present.frame
            cell.imageview_Switch_Background.image = UIImage(named: "ic_switch_background_green")
        }
        else if attendanceArr.value(forKey: uid) as! String == "0" {
            cell.lbl_Absent.isHidden = true
            cell.lbl_Present.isHidden = true
            cell.lbl_Present_Green.isHidden = true
            cell.lbl_Absent_Red.isHidden = false
            
            cell.imageview_Switch.frame = cell.btn_Absent.frame
            cell.imageview_Switch_Background.image = UIImage(named: "ic_switch_background_red")
        }
        
        return cell
    }
    
}
