//
//  NotificationVC.swift
//  LittleLand
//
//  Created by Lead on 26/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class NotificationVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var imageview_SideMenu: UIImageView!
    @IBOutlet weak var tableview_Notification: UITableView!
    
    @IBOutlet var popUp_Remark: UIView!
    @IBOutlet weak var popUp_Remark_Reason: UIView!
    @IBOutlet weak var view_Desc_PopUp_Remark: UIView!
    @IBOutlet weak var textview_PopUp_Remark: UITextView!
    
    
    //MARK:- Variable Declarations
    var notificationArray:NSMutableArray = NSMutableArray()
    var ref_ID:String = String()
    var isOpenSideMenu:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_notifications").uppercased()
        
        if isOpenSideMenu == true {
            imageview_SideMenu.image = UIImage(named: "ic_menu")
        }
        ApiUtillity.sharedInstance.setCornurRadius(obj: popUp_Remark_Reason, cornurRadius: 1, isClipToBound: true, borderColor: "", borderWidth: 1)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Desc_PopUp_Remark, cornurRadius: 5, isClipToBound: true, borderColor: "E6E6E6", borderWidth: 1)
        self.getNotificationData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        if isOpenSideMenu == true {
            present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_Handler_Cancel_PopUp_Remark(_ sender: Any) {
        popUp_Remark.removeFromSuperview()
    }
    
    @IBAction func btn_Handler_Submit_PopUp_Remark(_ sender: Any) {
        self.view.endEditing(true)
        if textview_PopUp_Remark.text == "Reason for absent" || textview_PopUp_Remark.text.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_please_enter_reason_absent").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "attendance_id":ref_ID, "remark":textview_PopUp_Remark.text!, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "attendance_reason.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    self.popUp_Remark.removeFromSuperview()
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithSuccess(success: (dict.value(forKey: "success") as! String))
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
    
    
    //MARK:- All Method
    func getNotificationData() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "offset":"0", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "notifications.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.notificationArray = success.mutableCopy() as! NSMutableArray
                    self.tableview_Notification.reloadData()
                    
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

    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notificationArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_Notification.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_notifications")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_Notification.backgroundView = noDataLabel
        }
        else {
            tableview_Notification.backgroundView = nil
        }
        return notificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String).isEmpty {
            let cell:NotificationCell = tableview_Notification.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
            cell.lbl_NotificationName.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "title") as! String)
            cell.lbl_NotificationDescription.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
            cell.lbl_NotificationDate.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String)
            
            return cell
        }
        else {
            let cell:NotificationImageCell = tableview_Notification.dequeueReusableCell(withIdentifier: "NotificationImageCell") as! NotificationImageCell
            cell.imageview_Notification.kf.setImage(with: URL(string: ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String)))
            cell.lbl_NotificationName.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "title") as! String)
            cell.lbl_NotificationDescription.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
            cell.lbl_NotificationDate.text = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String).isEmpty {
            let constraintRect = CGSize(width: UIScreen.main.bounds.size.width-76, height: .greatestFiniteMagnitude)
            let boundingBox = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 11)!], context: nil)
            let height:CGFloat = ceil(boundingBox.height)
            return height + 40
        }
        else {
            let constraintRect = CGSize(width: UIScreen.main.bounds.size.width-76, height: .greatestFiniteMagnitude)
            let boundingBox = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 11)!], context: nil)
            let height:CGFloat = ceil(boundingBox.height)
            return height + 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ref_ID = ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "ref_id") as! String)
        if ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "type") as! String) == "attendance" {
            self.textview_PopUp_Remark.text = "Reason for absent"
            self.textview_PopUp_Remark.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            self.popUp_Remark.frame = self.view.frame
            self.view.addSubview(self.popUp_Remark)
        }
        else if ((notificationArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "type") as! String) == "post" {
            let vc:ViewPostDetailsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostDetailsVC") as! ViewPostDetailsVC
            vc.postID = ref_ID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK:- TextView Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Reason for absent" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result:String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if result.isEmpty {
            textView.text = "Reason for absent"
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            textView.resignFirstResponder()
        }
        
        return true
    }
    
}
