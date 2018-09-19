//
//  ParentsAttendanceVC.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class ParentsAttendanceVC: PagerController, PagerDataSource, PagerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    
    
    //MARK:- Variable Declarations
    var tab_Width:CGFloat = UIScreen.main.bounds.size.width/3
    var formatter:DateFormatter = DateFormatter()
    public var selectedClassID:String = String()
    var weeklyAttendanceArray:NSMutableArray = NSMutableArray()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        self.customizeTab()
        
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Weekly_attendanced").uppercased()
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        
        self.getWeeklyAttendanceReports()
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
    
    
    //MARK:- All Method
    func getWeeklyAttendanceReports() {
        self.formatter.dateFormat = "yyyy-MM-dd"
        let type:String = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "teacher" : "parent")
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "class_id":selectedClassID, "action":"weekly_report", "type":type, "date":self.formatter.string(from: Date()), "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "attendance_report.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.weeklyAttendanceArray = success.mutableCopy() as! NSMutableArray
                    
                    if self.weeklyAttendanceArray.count < 3 {
                        self.tab_Width = UIScreen.main.bounds.size.width/CGFloat(self.weeklyAttendanceArray.count)
                        self.customizeTab()
                    }
                    
                    self.reloadData()
                    ApiUtillity.sharedInstance.dismissSVProgressHUD()
                    
                    if self.weeklyAttendanceArray.count <= 0 {
                        ApiUtillity.sharedInstance.dismissSVProgressHUDWithError(error: "No Student Found")
                        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
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
    
    
    //MARK:- PagerDataSource Method
    func customizeTab() {
        indicatorColor = UIColor.white
        tabsViewBackgroundColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "55AF58")
        contentViewBackgroundColor = UIColor.gray.withAlphaComponent(0.32)
        
        startFromSecondTab = false
        centerCurrentTab = true
        tabLocation = PagerTabLocation.top
        tabHeight = 60
        tabOffset = 36
        tabWidth = tab_Width
        indicatorHeight = 0
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = PagerAnimation.during
        selectedTabTextColor = .blue
        tabsTextFont = UIFont(name: "HelveticaNeue-Bold", size: 20)!
        tabTopOffset = 10
        //tabsTextColor = .purpleColor()
        if UIScreen.main.bounds.size.height == 812 {
            tabTopOffset = 44
        }
    }
    
    func numberOfTabs(_ pager: PagerController) -> Int {
        return weeklyAttendanceArray.count
    }
    
    func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tab_Width, height: 60))
        view.backgroundColor = UIColor.white
        
        let view_Top:UIView = UIView.init(frame: CGRect.init(x: 0, y: 7, width: tab_Width, height: 3))
        view_Top.backgroundColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "CBD9BF")
        view.addSubview(view_Top)
        
        let viewGreen:UIView = UIView.init(frame: CGRect.init(x: 0, y: 10, width: tab_Width, height: 50))
        viewGreen.backgroundColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "55AF58")
        view.addSubview(viewGreen)
        
        let imageview_Student:UIImageView = UIImageView.init(frame: CGRect.init(x: (tab_Width-45)/2, y: 0, width: 45, height: 45))
        imageview_Student.tag = 10
        imageview_Student.kf.indicatorType = .activity
        imageview_Student.kf.setImage(with: URL(string: ((weeklyAttendanceArray.object(at: index) as! NSDictionary).value(forKey: "profile_pic") as! String)))
        imageview_Student.contentMode = .scaleAspectFill
        imageview_Student.clipsToBounds = true
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Student, cornurRadius: 22.5, isClipToBound: true, borderColor: "55AF58", borderWidth: 2.0)
        view.addSubview(imageview_Student)
        
        let Student_Name = UILabel.init(frame: CGRect.init(x: 0, y: 45, width: tab_Width, height: 15))
        Student_Name.tag = 11
        Student_Name.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "\(((weeklyAttendanceArray.object(at: index) as! NSDictionary).value(forKey: "fname") as! String)) \(((weeklyAttendanceArray.object(at: index) as! NSDictionary).value(forKey: "lname") as! String))" : "\(((weeklyAttendanceArray.object(at: index) as! NSDictionary).value(forKey: "fname") as! String))")
        Student_Name.textColor = UIColor.white
        Student_Name.font = UIFont(name: "Lato-Black", size: 10)
        Student_Name.textAlignment = .center
        view.addSubview(Student_Name)
        
        return view
    }
    
    func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        let VC:ParentsAttendanceSubVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ParentsAttendanceSubVC") as! ParentsAttendanceSubVC
        VC.reportsArray = (((weeklyAttendanceArray.object(at: index) as! NSDictionary).value(forKey: "report") as! NSArray)).mutableCopy() as! NSMutableArray
        return VC
    }
    
    
    //MARK:- PagerDelegate Method
    func didChangeTabToIndex(_ pager: PagerController, index: Int, previousIndex: Int, swipe: Bool) {
        print(index)
    }
    
}
