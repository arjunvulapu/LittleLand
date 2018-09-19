//
//  TeacherPostVC.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

class TeacherPostVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK:- Outlets
    @IBOutlet weak var btn_ClassName: UIButton!
    @IBOutlet weak var view_ClassName: UIView!
    
    @IBOutlet weak var view_DaysDisplay: UIView!
    @IBOutlet weak var lbl_SelectedDay: UILabel!
    @IBOutlet weak var lbl_SelectedMonth: UILabel!
    @IBOutlet weak var calendar_TeacherPost: FSCalendar!
    
    @IBOutlet weak var view_Teacher_Post: UIView!
    @IBOutlet weak var imageview_Teacher: UIImageView!
    @IBOutlet weak var lbl_Teacher_Name: UILabel!
    @IBOutlet weak var lbl_Teacher_Degree: UILabel!
    
    @IBOutlet weak var tableview_Teacher: UITableView!
    
    
    //MARK:- Variable Declarations
    var customeFormatter:DateFormatter = DateFormatter()
    var teacherPostArray:NSMutableArray = NSMutableArray()
    var daysArray:NSMutableArray = NSMutableArray()
    var classNchildArray:NSMutableArray = NSMutableArray()
    
    var classNchildSelectedIndex:Int = 0
    var selectedClassID:String = String()
    
    var isOpenHeder:Int = 0
    var selectedDate = ApiUtillity.selectedDate()
    
    var pickerPopUp:PickerPopUpVC = PickerPopUpVC()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        ApiUtillity.sharedInstance.openSideMenu()
        
        self.setDesign()
        self.SetupFSCalendar()
        self.getHomeData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { 
            self.calendar_TeacherPost.select(Date())
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfile), name: NSNotification.Name(rawValue: "RELOAD_PROFILE_HOME"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        let vc:NotificationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Handler_ClassName(_ sender: Any) {
        self.openPickerPopUp()
    }
    @IBAction func btn_Handler_SelectDate(_ sender: Any) {
        let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
        vc.selectedDate = selectedDate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Handler_TableViewHeder(_ sender: UIButton) {
        isOpenHeder = sender.tag
        tableview_Teacher.reloadData()
    }
    
    
    //MARK:- All Method
    func setDesign() {
        self.view.layoutIfNeeded()
        
        self.imageview_Teacher.kf.indicatorType = .activity
        self.imageview_Teacher.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getUserData(key: "profile_pic")))
        self.lbl_Teacher_Name.text = "\(ApiUtillity.sharedInstance.getUserData(key: "fname")) \(ApiUtillity.sharedInstance.getUserData(key: "lname"))"
        self.lbl_Teacher_Degree.text = ApiUtillity.sharedInstance.getUserData(key: "qualification")
        
        customeFormatter.dateFormat = "dd"
        lbl_SelectedDay.text = customeFormatter.string(from: Date())
        customeFormatter.dateFormat = "MMM"
        lbl_SelectedMonth.text = customeFormatter.string(from: Date()).uppercased()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_ClassName, cornurRadius: 12.5, isClipToBound: true, borderColor: "D94F29", borderWidth: 1.5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_DaysDisplay, cornurRadius: 40, isClipToBound: true, borderColor: "FFFFFF", borderWidth: 2)
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Teacher, cornurRadius: 30, isClipToBound: true, borderColor: "FFFFFF", borderWidth: 2)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            ApiUtillity.sharedInstance.setShadow(obj: self.view_Teacher_Post, cornurRadius: 15, ClipToBound: true, masksToBounds: false, shadowColor: "AAAAAA", shadowOpacity: 0.5, shadowOffset: .zero, shadowRadius: 3.0, shouldRasterize: false, shadowPath: self.view_Teacher_Post.bounds)
        }
        
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            
        }
        else {
            
        }
    }
    
    func reloadProfile() {
        imageview_Teacher.kf.indicatorType = .activity
        imageview_Teacher.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getUserData(key: "profile_pic")))
    }
    
    func SetupFSCalendar() {
        calendar_TeacherPost.placeholderType = .none
        calendar_TeacherPost.headerHeight = 0
    }
    
    func getHomeData() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "dev_token":ApiUtillity.sharedInstance.getIphoneData(key: "PUSH_TOKEN"), "dev_type":"1", "code":ApiUtillity.sharedInstance.getIphoneData(key: "UDID"), "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "get_initial.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    ApiUtillity.sharedInstance.setUserData(data: (success.value(forKey: "user") as! NSDictionary).mutableCopy() as! NSMutableDictionary)
                    
                    self.imageview_Teacher.kf.indicatorType = .activity
                    self.imageview_Teacher.kf.setImage(with: URL(string: ((success.value(forKey: "user") as! NSDictionary).value(forKey: "profile_pic") as! String)))
                    self.lbl_Teacher_Name.text = "\(((success.value(forKey: "user") as! NSDictionary).value(forKey: "fname") as! String)) \(((success.value(forKey: "user") as! NSDictionary).value(forKey: "lname") as! String))"
                    self.lbl_Teacher_Degree.text = ((success.value(forKey: "user") as! NSDictionary).value(forKey: "qualification") as! String)
                    
                    self.daysArray = (success.value(forKey: "days") as! NSArray).mutableCopy() as! NSMutableArray
                    self.calendar_TeacherPost.reloadData()
                    
                    if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
                        self.classNchildArray = ((success.value(forKey: "user") as! NSDictionary).value(forKey: "class") as! NSArray).mutableCopy() as! NSMutableArray
                        
                        // Auto Select Class
                        self.selectedClassID = ((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: "id") as! String)
                        self.btn_ClassName.setTitle(((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), for: .normal)
                        ApiUtillity.sharedInstance.setClass(Name: ((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), ID: self.selectedClassID)
                    }
                    else {
                        self.classNchildArray = ((success.value(forKey: "user") as! NSDictionary).value(forKey: "childs") as! NSArray).mutableCopy() as! NSMutableArray
                        
                        // Auto Select Child
                        self.selectedClassID = ((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: "id") as! String)
                        self.btn_ClassName.setTitle("\(((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: "fname") as! String)) \(((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: "lname") as! String))", for: .normal)
                        ApiUtillity.sharedInstance.setClass(Name: ((self.classNchildArray.object(at: self.classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), ID: self.selectedClassID)
                    }
                    
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
    
    func openPickerPopUp() {
        pickerPopUp = Bundle.main.loadNibNamed("PickerPopUpVC", owner: self, options: nil)?[0] as! PickerPopUpVC
        pickerPopUp.frame = self.view.frame
        pickerPopUp.btn_Cancel.addTarget(self, action: #selector(cancelPickerPopUp), for: .touchUpInside)
        pickerPopUp.btn_Done.addTarget(self, action: #selector(donePickerPopUp), for: .touchUpInside)
        
        pickerPopUp.picker.delegate = self
        pickerPopUp.picker.dataSource = self
        
        self.view.addSubview(pickerPopUp)
    }
    
    func cancelPickerPopUp() {
        pickerPopUp.closeAnimation()
    }
    
    func donePickerPopUp() {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            selectedClassID = ((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: "id") as! String)
            btn_ClassName.setTitle(((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), for: .normal)
            ApiUtillity.sharedInstance.setClass(Name: ((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), ID: selectedClassID)
        }
        else {
            selectedClassID = ((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: "class_id") as! String)
            btn_ClassName.setTitle("\(((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: "fname") as! String)) \(((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: "lname") as! String))", for: .normal)
            ApiUtillity.sharedInstance.setClass(Name: ((classNchildArray.object(at: classNchildSelectedIndex) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), ID: selectedClassID)
        }
        classNchildSelectedIndex = 0
        pickerPopUp.closeAnimation()
    }
    
    
    //MARK:- FSCalendarDelegate Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(calendar.selectedDate!)
        
        customeFormatter.dateFormat = "dd"
        lbl_SelectedDay.text = customeFormatter.string(from: date)
        customeFormatter.dateFormat = "MMM"
        lbl_SelectedMonth.text = customeFormatter.string(from: date).uppercased()
        
        customeFormatter.dateFormat = "dd"
        selectedDate.Day = Int(customeFormatter.string(from: date))!
        customeFormatter.dateFormat = "MM"
        selectedDate.Month = Int(customeFormatter.string(from: date))!
        customeFormatter.dateFormat = "yyyy"
        selectedDate.Year = Int(customeFormatter.string(from: date))!
        customeFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate.Date = (customeFormatter.string(from: date))
        
        let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
        vc.selectedDate = selectedDate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if daysArray.count > 0 {
            for item in daysArray {
                var date_String:String = item as! String
                customeFormatter.dateFormat = "yyyy-MM-dd"
                let date_API:Date = customeFormatter.date(from: date_String)!
                date_String = customeFormatter.string(from: date)
                let date_calendar:Date = customeFormatter.date(from: date_String)!
                if date_API == date_calendar {
                    return 1
                }
            }
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        if daysArray.count > 0 {
            for item in daysArray {
                var date_String:String = item as! String
                customeFormatter.dateFormat = "yyyy-MM-dd"
                let date_API:Date = customeFormatter.date(from: date_String)!
                date_String = customeFormatter.string(from: date)
                let date_calendar:Date = customeFormatter.date(from: date_String)!
                if date_API == date_calendar {
                    return CGPoint(x: 6, y: -15)
                }
            }
        }
        return .zero
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print(calendar.currentPage)
        
        customeFormatter.dateFormat = "dd"
        lbl_SelectedDay.text = customeFormatter.string(from: calendar.currentPage)
        customeFormatter.dateFormat = "MMM"
        lbl_SelectedMonth.text = customeFormatter.string(from: calendar.currentPage).uppercased()
        
        customeFormatter.dateFormat = "dd"
        selectedDate.Day = Int(customeFormatter.string(from: calendar.currentPage))!
        customeFormatter.dateFormat = "MM"
        selectedDate.Month = Int(customeFormatter.string(from: calendar.currentPage))!
        customeFormatter.dateFormat = "yyyy"
        selectedDate.Year = Int(customeFormatter.string(from: calendar.currentPage))!
        customeFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate.Date = (customeFormatter.string(from: calendar.currentPage))
    }
    
    
    //MARK:- Tableview Method
    func numberOfSections(in tableView: UITableView) -> Int {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            return 3
        }
        else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell:TeacherPostHederCell = self.tableview_Teacher.dequeueReusableCell(withIdentifier: "TeacherPostHederCell") as! TeacherPostHederCell
        cell.btn_Heder.tag = section
        cell.btn_Heder.addTarget(self, action: #selector(btn_Handler_TableViewHeder(_:)), for: .touchUpInside)
        
        cell.view_Bottom.isHidden = (section == isOpenHeder ? true : false)
        cell.view_Bottom.isHidden = (section == 0 ? true : false)
        cell.view_Bottom_Bottom.isHidden = (section == isOpenHeder ? false : true)
        
        if section == 0 {
            cell.imageview_Post.image = UIImage(named: "ic_manage_post")
            cell.imageview_DropDown.image = (section == isOpenHeder ? UIImage(named: "ic_dropdown_red_down") : UIImage(named: "ic_dropdown_red_up"))
            cell.lbl_PostName.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_manage_post").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_posts").uppercased())
            cell.lbl_PostDesc.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_manage_post_you_can_send_post_to_direct_parents").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_post_you_can_view_post_of_childs").uppercased())
            cell.lbl_PostDesc.textColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "D4583F")
        }
        else if section == 1 {
            cell.imageview_Post.image = UIImage(named: "ic_manage_attendance")
            cell.imageview_DropDown.image = (section == isOpenHeder ? UIImage(named: "ic_dropdown_purple_down") : UIImage(named: "ic_dropdown_purple_up"))
            cell.lbl_PostName.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_attendance").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_attendance").uppercased())
            cell.lbl_PostDesc.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_attendance_student_attendence_report").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_attendance_student_attendence_report").uppercased())
            cell.lbl_PostDesc.textColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "98759B")
        }
        else if section == 2 {
            cell.imageview_Post.image = UIImage(named: "ic_manage_calander")
            cell.imageview_DropDown.image = (section == isOpenHeder ? UIImage(named: "ic_dropdown_green_down") : UIImage(named: "ic_dropdown_green_up"))
            cell.lbl_PostName.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events").uppercased())
            cell.lbl_PostDesc.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events_check_event_for_littleland").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events_check_event_for_littleland").uppercased())
            cell.lbl_PostDesc.textColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "44AD48")
        }
        else if section == 3 {
            cell.imageview_Post.image = UIImage(named: "ic_direct_message")
            cell.imageview_DropDown.image = (section == isOpenHeder ? UIImage(named: "ic_dropdown_purple_down") : UIImage(named: "ic_dropdown_purple_up"))
            cell.lbl_PostName.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_direct").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_direct").uppercased())
            cell.lbl_PostDesc.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? ApiUtillity.sharedInstance.getLanguageData(key: "lbl_direct_send_direct_message").uppercased() : ApiUtillity.sharedInstance.getLanguageData(key: "lbl_direct_send_direct_message").uppercased())
            cell.lbl_PostDesc.textColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "98759B")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            if isOpenHeder == section {
                if section == 0 {
                    return 2
                }
                else if section == 1 {
                    return 3
                }
                else if section == 2 {
                    return 1
                }
                else {
                    return 2
                }
            }
            else {
                return 0
            }
        }
        else {
            if isOpenHeder == section {
                if section == 0 {
                    return 1
                }
                else if section == 1 {
                    return 2
                }
                else if section == 2 {
                    return 1
                }
                else {
                    return 2
                }
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TeacherPostCell = self.tableview_Teacher.dequeueReusableCell(withIdentifier: "TeacherPostCell") as! TeacherPostCell
        
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_create_post")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_new_post").uppercased()
                }
                else {
                    cell.imageview_Category.image = UIImage(named: "ic_view_post")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_post").uppercased()
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_take_attendance")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_take_attendence").uppercased()
                }
                else if indexPath.row == 1 {
                    cell.imageview_Category.image = UIImage(named: "ic_attendance_report")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_monthly_report").uppercased()
                }
                else {
                    cell.imageview_Category.image = UIImage(named: "ic_attendance_report")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_weekly_report").uppercased()
                }
            }
            else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_view_calendar")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_calender").uppercased()
                }
            }
            else if indexPath.section == 3 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_send_direct_message")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_send_message").uppercased()
                }
                else {
                    cell.imageview_Category.image = UIImage(named: "ic_conversation")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_conversions").uppercased()
                }
            }
        }
        else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_view_post")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_post").uppercased()
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_attendance_report")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_monthly_report").uppercased()
                }
                else {
                    cell.imageview_Category.image = UIImage(named: "ic_attendance_report")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_weekly_report").uppercased()
                }
                
            }
            else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_view_calendar")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_calender").uppercased()
                }
            }
            else if indexPath.section == 3 {
                if indexPath.row == 0 {
                    cell.imageview_Category.image = UIImage(named: "ic_send_direct_message")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_send_message").uppercased()
                }
                else {
                    cell.imageview_Category.image = UIImage(named: "ic_conversation")
                    cell.lbl_CategoryName.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_conversions").uppercased()
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    //"NEW POST"
                    let vc:NewPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "NewPostVC") as! NewPostVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    //"VIEW POST"
                    let vc:ViewPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    //"TAKE ATTENDANCE"
                    let vc:DailyAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "DailyAttendanceVC") as! DailyAttendanceVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 1 {
                    //"VIEW MONTHLY REPORT"
                    let vc:MonthlyAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyAttendanceVC") as! MonthlyAttendanceVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    //"VIEW WEEKLY REPORT"
                    let vc:ParentsAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ParentsAttendanceVC") as! ParentsAttendanceVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    //"VIEW CALENDAR"
                    let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
                    vc.selectedDate = selectedDate
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.section == 3 {
                if indexPath.row == 0 {
                    //"SEND MESSAGE"
                    let vc:ConversationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
                    vc.isClassNChildsOpen = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    //"CONVERSATIONS"
                    let vc:ConversationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        else {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    //"VIEW POST"
                    let vc:ViewPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.section == 1 {
                if indexPath.row == 0 {
                    //"VIEW MONTHLY REPORT"
                    let vc:MonthlyAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyAttendanceVC") as! MonthlyAttendanceVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    //"VIEW WEEKLY REPORT"
                    let vc:ParentsAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ParentsAttendanceVC") as! ParentsAttendanceVC
                    vc.selectedClassID = selectedClassID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    //"VIEW CALENDAR"
                    let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
                    vc.selectedDate = selectedDate
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if indexPath.section == 3 {
                if indexPath.row == 0 {
                    //"SEND MESSAGE"
                    let vc:ConversationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
                    vc.isClassNChildsOpen = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    //"CONVERSATIONS"
                    let vc:ConversationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ConversationVC") as! ConversationVC
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    
    //MARK:- UIPickerView Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return classNchildArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            return ((classNchildArray.object(at: row) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
        }
        else {
            return "\(((classNchildArray.object(at: row) as! NSDictionary).value(forKey: "fname") as! String)) \(((classNchildArray.object(at: row) as! NSDictionary).value(forKey: "lname") as! String))"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        classNchildSelectedIndex = row
    }
    
}
