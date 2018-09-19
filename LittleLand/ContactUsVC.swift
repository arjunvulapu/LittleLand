//
//  ContactUsVC.swift
//  LittleLand
//
//  Created by Lead on 26/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class ContactUsVC: UIViewController, UITextViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var view_Subject: UIView!
    @IBOutlet weak var txt_Subject: UITextField!
    @IBOutlet weak var view_Descrption: UIView!
    @IBOutlet weak var textview_Description: UITextView!
    @IBOutlet weak var btn_Send: UIButton!
    
    
    //MARK:- Variable Declarations
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "ibl_CONTACT_US").uppercased())
        txt_Subject.placeholder = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_subject").lowercased()))
        textview_Description.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_description").lowercased()))
        btn_Send.setTitle((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_send").uppercased()), for: .normal)
        
        let contactUsArray:[Any] = [view_Subject, view_Descrption]
        ApiUtillity.sharedInstance.setCornurRadiusToAllControls(allObj: contactUsArray, cornurRadius: 17.5, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: btn_Send, cornurRadius: 17.5, isClipToBound: true, borderColor: "", borderWidth: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
    }
    
    @IBAction func btn_Handler_Send(_ sender: Any) {
        self.view.endEditing(true)
        
        if (txt_Subject.text?.isEmpty)! {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Subject").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        if textview_Description.text == (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_description").lowercased())) || textview_Description.text.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Description").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "subject":txt_Subject.text!, "body":textview_Description.text!, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "contact_us.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    self.txt_Subject.text = ""
                    self.textview_Description.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_description").lowercased()))
                    self.textview_Description.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
                    
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
    
    
    //MARK:- TextView Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_description").lowercased())) {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result:String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if result.isEmpty {
            textView.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_description").lowercased()))
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            textView.resignFirstResponder()
        }
        
        return true
    }
    
}
