//
//  MonthlyCalendarVC.swift
//  LittleLand
//
//  Created by Lead on 21/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

class MonthlyCalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    
    @IBOutlet weak var collectionview_Month: UICollectionView!
    @IBOutlet weak var scrollview_Month: UIScrollView!
    @IBOutlet weak var Calendar_Monthly: FSCalendar!
    
    @IBOutlet weak var tableview_Events: UITableView!
    @IBOutlet var view_Loading: UIView!
    @IBOutlet weak var lbl_Loading: UILabel!
    
    
    //MARK:- Variable Declarations
    var daysArray:NSMutableArray = NSMutableArray()
    var eventsArray:NSMutableArray = NSMutableArray()
    
    var monthNameArray:NSMutableArray = NSMutableArray()
    let PathArray:NSMutableArray = NSMutableArray()
    
    let customeFormatter:DateFormatter = DateFormatter()
    var selectedMonth:Int = 0
    var isCallApi:Bool = false
    
    var selectedDate = ApiUtillity.selectedDate()
    var isOpenSideMenu:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_MONTHLY_CALENDER"))
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        lbl_Loading.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loading").lowercased()))
        
        if !self.selectedDate.Date.isEmpty {
            self.customeFormatter.dateFormat = "yyyy-MM-dd"
            self.Calendar_Monthly.select(self.customeFormatter.date(from: self.selectedDate.Date), scrollToDate: true)
        }
        self.SetupFSCalendar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        if isOpenSideMenu == true {
            present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        
    }
    
    @IBAction func btn_Handler_CollectionMonth(_ sender: Any) {
        let btn_Month:UIButton = sender as! UIButton
        selectedMonth = btn_Month.tag
        
        for item in collectionview_Month.visibleCells {
            let cell:MonthlyCalendarMonthCell = item as! MonthlyCalendarMonthCell
            if cell.btn_MonthName.tag == selectedMonth {
                cell.btn_MonthName.backgroundColor = UIColor.white
                cell.btn_MonthName.setTitleColor(ApiUtillity.sharedInstance.getColorIntoHex(Hex: "54AF57"), for: .normal)
            }
            else {
                cell.btn_MonthName.backgroundColor = UIColor.clear
                cell.btn_MonthName.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
        customeFormatter.dateFormat = "dd/MM/yyyy"
        Calendar_Monthly.setCurrentPage(customeFormatter.date(from: ((monthNameArray.object(at: selectedMonth) as! NSDictionary).value(forKey: "date") as! String))!, animated: true)
    }
    
    @IBAction func btn_Handler_Month(_ sender: Any) {
        let btn_Month:UIButton = sender as! UIButton
        
        for item in self.scrollview_Month.subviews {
            if item is UIButton {
                let btn:UIButton = item as! UIButton
                btn.backgroundColor = UIColor.clear
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
        btn_Month.backgroundColor = UIColor.white
        btn_Month.setTitleColor(ApiUtillity.sharedInstance.getColorIntoHex(Hex: "54AF57"), for: .normal)
        ApiUtillity.sharedInstance.setCornurRadius(obj: btn_Month, cornurRadius: 5, isClipToBound: true, borderColor: "00959E", borderWidth: 0)
    }
    
    
    //MARK:- All Method
    func SetupFSCalendar() {
        Calendar_Monthly.placeholderType = .none
        //Calendar_Monthly.headerHeight = 0
        
        let formatter = DateFormatter()
        let monthComponents = formatter.shortMonthSymbols
        for (i,item) in monthComponents!.enumerated() {
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let tempDate:String = "\(1)/\(i+1)/\(year)"
            let dic:NSDictionary = NSDictionary(objects: [tempDate as Any,item], forKeys: ["date" as NSCopying,"name" as NSCopying])
            monthNameArray.add(dic)
        }
        self.calendarCurrentPageDidChange(Calendar_Monthly)
        
        
        let Width:CGFloat = UIScreen.main.bounds.size.width/6
        let Space:CGFloat = Width/4
        // For Collectionview Layout
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: Width, height: 35)
        layout.minimumLineSpacing = Space
        layout.minimumInteritemSpacing = Space
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        collectionview_Month.collectionViewLayout = layout
    }
    
    func getCalendarEvents(date:Date) {
        customeFormatter.dateFormat = "MM"
        let month:String = customeFormatter.string(from: date)
        customeFormatter.dateFormat = "yyyy"
        let year:String = customeFormatter.string(from: date)
        
        isCallApi = true
        self.daysArray = NSMutableArray()
        self.eventsArray = NSMutableArray()
        self.Calendar_Monthly.reloadData()
        self.tableview_Events.reloadData()
        
        let params = ["action":"get", "uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "type":ApiUtillity.sharedInstance.getLoginType(), "month":month, "year":year, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        print(params)
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "event_action.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            self.isCallApi = false
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    self.daysArray = (success.value(forKey: "days") as! NSArray).mutableCopy() as! NSMutableArray
                    self.eventsArray = (success.value(forKey: "events") as! NSArray).mutableCopy() as! NSMutableArray
                    self.Calendar_Monthly.reloadData()
                    self.tableview_Events.reloadData()
                    
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
    
    func setDataInScrollview() {
        var X:CGFloat = 0
        let Width:CGFloat = UIScreen.main.bounds.size.width/6
        let Space:CGFloat = Width/4
        for (i,item) in monthNameArray.enumerated() {
            let btn:UIButton = UIButton.init(frame: CGRect.init(x: X, y: 9, width: Width, height: 17))
            btn.tag = i
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitle(((item as! NSDictionary).value(forKey: "name") as! String).uppercased(), for: .normal)
            btn.titleLabel?.font = UIFont.init(name: "Lato-Black", size: 8.0)
            btn.addTarget(self, action: #selector(btn_Handler_Month(_:)), for: .touchUpInside)
            scrollview_Month.addSubview(btn)
            
            if i < 5 {
                PathArray.add(btn.frame)
            }
            X = X + Width
            X = X + Space
        }
        scrollview_Month.contentSize = CGSize.init(width: X, height: 45)
    }
    
    
    //MARK:- FSCalendarDelegate Method
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(calendar.selectedDate!)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.getCalendarEvents(date: calendar.currentPage)
        
        customeFormatter.dateFormat = "MMM"
        print(calendar.currentPage)
        
        for item in self.scrollview_Month.subviews {
            if item is UIButton {
                let btn:UIButton = item as! UIButton
                if btn.titleLabel?.text == customeFormatter.string(from: calendar.currentPage) {
                    print(scrollview_Month.frame.size.width/2 ,btn.center.x)
                    scrollview_Month.scrollRectToVisible(btn.frame, animated: true)
                    self.btn_Handler_Month(btn)
                }
            }
        }
        
        for (i,item) in monthNameArray.enumerated() {
            if ((item as! NSDictionary).value(forKey: "name") as! String) == customeFormatter.string(from: calendar.currentPage) {
                if collectionview_Month != nil {
                    selectedMonth = i
                    let indexpath:IndexPath = IndexPath(row: i, section: 0)
                    collectionview_Month.scrollToItem(at: indexpath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
                }
            }
        }
        
        for item in collectionview_Month.visibleCells {
            let cell:MonthlyCalendarMonthCell = item as! MonthlyCalendarMonthCell
            if cell.btn_MonthName.tag == selectedMonth {
                cell.btn_MonthName.backgroundColor = UIColor.white
                cell.btn_MonthName.setTitleColor(ApiUtillity.sharedInstance.getColorIntoHex(Hex: "54AF57"), for: .normal)
            }
            else {
                cell.btn_MonthName.backgroundColor = UIColor.clear
                cell.btn_MonthName.setTitleColor(UIColor.white, for: .normal)
            }
        }
        
        //For Change Year
        customeFormatter.dateFormat = "dd/MM/yyyy"
        let tempYear:Date = customeFormatter.date(from: (monthNameArray.object(at: 0) as! NSDictionary).value(forKey: "date") as! String)!
        customeFormatter.dateFormat = "yyyy"
        let calendatYear:String = customeFormatter.string(from: calendar.currentPage)
        if customeFormatter.string(from: tempYear) != calendatYear {
            monthNameArray = NSMutableArray()
            let formatter = DateFormatter()
            let monthComponents = formatter.shortMonthSymbols
            for (i,item) in monthComponents!.enumerated() {
                let date = calendar.currentPage
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let tempDate:String = "\(1)/\(i+1)/\(year)"
                let dic:NSDictionary = NSDictionary(objects: [tempDate as Any,item], forKeys: ["date" as NSCopying,"name" as NSCopying])
                monthNameArray.add(dic)
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if eventsArray.count > 0 {
            for (i,item) in eventsArray.enumerated() {
                var date_String:String = ((item as! NSDictionary).value(forKey: "datetime") as! String)
                customeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date_API:Date = customeFormatter.date(from: date_String)!
                customeFormatter.dateFormat = "yyyy-MM-dd"
                date_String = customeFormatter.string(from: date_API)
                if date_String == customeFormatter.string(from: date) {
                    return ApiUtillity.sharedInstance.getColorIntoHex(Hex: ((eventsArray.object(at: i) as! NSDictionary).value(forKey: "color") as! String))
                }
            }
        }
        return UIColor.white
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        if eventsArray.count > 0 {
            for (i,item) in eventsArray.enumerated() {
                var date_String:String = ((item as! NSDictionary).value(forKey: "datetime") as! String)
                customeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date_API:Date = customeFormatter.date(from: date_String)!
                customeFormatter.dateFormat = "yyyy-MM-dd"
                date_String = customeFormatter.string(from: date_API)
                if date_String == customeFormatter.string(from: date) {
                    return ApiUtillity.sharedInstance.getColorIntoHex(Hex: ((eventsArray.object(at: i) as! NSDictionary).value(forKey: "color") as! String))
                }
            }
        }
        return UIColor.lightGray
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if eventsArray.count > 0 {
            for item in eventsArray {
                var date_String:String = ((item as! NSDictionary).value(forKey: "datetime") as! String)
                customeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date_API:Date = customeFormatter.date(from: date_String)!
                customeFormatter.dateFormat = "yyyy-MM-dd"
                date_String = customeFormatter.string(from: date_API)
                if date_String == customeFormatter.string(from: date) {
                    return UIColor.white
                }
            }
        }
        return UIColor.lightGray
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCallApi == true {
            view_Loading.frame = tableview_Events.frame
            tableview_Events.backgroundView = view_Loading
        }
        else {
            if eventsArray.count <= 0 {
                let noDataLabel:UILabel = UILabel(frame: tableview_Events.frame)
                noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_events")
                noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
                noDataLabel.textColor = UIColor.black
                noDataLabel.textAlignment = .center
                tableView.backgroundView = noDataLabel
            }
            else {
                tableview_Events.backgroundView = nil
            }
        }
        return eventsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MonthlyCalendarEventCell = self.tableview_Events.dequeueReusableCell(withIdentifier: "MonthlyCalendarEventCell") as! MonthlyCalendarEventCell
        
        var Note:String = String()
        Note = Note.appending(((eventsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "note")) as! String))
        let date_String:String = ((eventsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "datetime") as! String)
        customeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date:Date = customeFormatter.date(from: date_String)!
        customeFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        Note = Note.appending(" \(customeFormatter.string(from: date))")
        cell.lbl_Notes.text = Note
        
        customeFormatter.dateFormat = "dd"
        cell.lbl_Total.text = (customeFormatter.string(from: date))
        
        cell.view_Event.backgroundColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: ((eventsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "color") as! String))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    //MARK:- CollectionView Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:MonthlyCalendarMonthCell = collectionview_Month.dequeueReusableCell(withReuseIdentifier: "MonthlyCalendarMonthCell", for: indexPath) as! MonthlyCalendarMonthCell
        
        cell.btn_MonthName.addTarget(self, action: #selector(btn_Handler_CollectionMonth(_:)), for: .touchUpInside)
        
        cell.btn_MonthName.setTitle(((monthNameArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String), for: .normal)
        cell.btn_MonthName.tag = indexPath.row
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: cell.btn_MonthName, cornurRadius: 5, isClipToBound: true, borderColor: "00959E", borderWidth: 0)
        if selectedMonth == indexPath.row {
            cell.btn_MonthName.backgroundColor = UIColor.white
            cell.btn_MonthName.setTitleColor(ApiUtillity.sharedInstance.getColorIntoHex(Hex: "54AF57"), for: .normal)
        }
        else {
            cell.btn_MonthName.backgroundColor = UIColor.clear
            cell.btn_MonthName.setTitleColor(UIColor.white, for: .normal)
        }
        
        return cell
    }
    
}
