//
//  ConversationVC.swift
//  LittleLand
//
//  Created by Lead on 24/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class ConversationVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var tableview_Conversation: UITableView!
    
    
    //MARK:- Variable Declarations
    var pickerPopUp:PickerPopUpVC = PickerPopUpVC()
    var formatter:DateFormatter = DateFormatter()
    var isClassNChildsOpen:Bool = false
    var selectedIndexOfClassNChild:Int = 0
    var selectedIDOfClassNChild:String = ""
    var selectedNameOfClassNChild:String = ""
    var ClassNChildsArray:NSMutableArray = NSMutableArray()
    var TeachersNParentsArray:NSMutableArray = NSMutableArray()
    var conversationArray:NSMutableArray = NSMutableArray()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Messages").uppercased()
        
        ClassNChildsArray = (ApiUtillity.sharedInstance.getDataIntoUserData(key: (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "class" : "childs")).mutableCopy() as! NSMutableArray)
        if ClassNChildsArray.count > 0{
            if isClassNChildsOpen == true {
                if ClassNChildsArray.count == 1 {
                    selectedIDOfClassNChild = ((ClassNChildsArray.object(at: 0) as! NSDictionary).value(forKey: "id") as! String)
                    selectedNameOfClassNChild = ((ClassNChildsArray.object(at: 0) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
                    
                    self.getTeachersORParents()
                }
                else {
                    self.openPickerPopUp()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getConversationList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Handler_SelectClass(_ sender: Any) {
        if ClassNChildsArray.count == 1 {
            selectedIDOfClassNChild = ((ClassNChildsArray.object(at: 0) as! NSDictionary).value(forKey: "id") as! String)
            selectedNameOfClassNChild = ((ClassNChildsArray.object(at: 0) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
            
            self.getTeachersORParents()
        }
        else {
            self.openPickerPopUp()
        }
    }
    
    
    //MARK:- All Method
    func getConversationList() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "action":"conversation_list", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        if self.conversationArray.count <= 0 {
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        }
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "message_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.conversationArray = success.mutableCopy() as! NSMutableArray
                    self.tableview_Conversation.reloadData()
                    
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
    
    func getTeachersORParents() {
        let action:String = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "get_parents_by_class_id" : "get_teachers_by_class_id")
        let params = ["class_id":selectedIDOfClassNChild, "action":action, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "get_data.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.TeachersNParentsArray = success.mutableCopy() as! NSMutableArray
                    
                    let vc:FindTeacherORParentsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "FindTeacherORParentsVC") as! FindTeacherORParentsVC
                    vc.TeachersNParentsArray = self.TeachersNParentsArray.mutableCopy() as! NSMutableArray
                    vc.selectedNameOfClassNChild = self.selectedNameOfClassNChild
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
        pickerPopUp.view_Picker_Heder.backgroundColor = UIColor(red: 222.0/255.0, green: 104.0/255.0, blue: 85.0/255.0, alpha: 1.0)
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
        pickerPopUp.closeAnimation()
        
        selectedIDOfClassNChild = ((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: "id") as! String)
        selectedNameOfClassNChild = ((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
        
        self.getTeachersORParents()
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conversationArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_Conversation.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_conversation_found")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_Conversation.backgroundView = noDataLabel
        }
        else {
            tableview_Conversation.backgroundView = nil
        }
        return conversationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ConversationCell = tableview_Conversation.dequeueReusableCell(withIdentifier: "ConversationCell") as! ConversationCell
        
        cell.imageview_User.kf.setImage(with: URL(string: ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String)))
        cell.lbl_UserName.text = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String)
        cell.lbl_Description.text = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "message") as! String)
        
        self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let tempDate:Date = self.formatter.date(from: ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
        self.formatter.dateFormat = "hh:mm a"
        cell.lbl_Time.text = self.formatter.string(from: tempDate)
        
        if Int(((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "unread_count") as! String))! > 0 {
            cell.lbl_UnReadMessageCount.isHidden = false
            cell.lbl_UnReadMessageCount.text = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "unread_count") as! String)
        }
        else {
            cell.lbl_UnReadMessageCount.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:ChatVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.to_ID = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "to_uid") as! String)
        vc.selectedNameOfTeachersNParents = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String)
        vc.selectedProfileOfTeachersNParents = ((conversationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK:- UIPickerView Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ClassNChildsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ((ClassNChildsArray.object(at: row) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndexOfClassNChild = row
    }
    
}
