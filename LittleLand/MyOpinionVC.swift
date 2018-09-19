//
//  MyOpinionVC.swift
//  LittleLand
//
//  Created by Lead on 26/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class MyOpinionVC: UIViewController, UITextViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var view_OpinionTab: UIView!
    @IBOutlet weak var view_SelectedTab: UIView!
    @IBOutlet weak var btn_Agree: UIButton!
    @IBOutlet weak var btn_Disagree: UIButton!
    @IBOutlet weak var view_Description: UIView!
    @IBOutlet weak var txt_Description: UITextView!
    @IBOutlet weak var btn_Submit: UIButton!
    
    
    //MARK:- Variable Declarations
    var postID:String = String()
    var selectedOpinion:Int = 1
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_OpinionTab, cornurRadius: 15, isClipToBound: true, borderColor: "A282BC", borderWidth: 1.5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_SelectedTab, cornurRadius: 15, isClipToBound: true, borderColor: "", borderWidth: 1.5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Description, cornurRadius: 15, isClipToBound: true, borderColor: "A282BC", borderWidth: 1.5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: btn_Submit, cornurRadius: 17.5, isClipToBound: true, borderColor: "", borderWidth: 1.5)
        
        btn_Agree.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_agree").lowercased())), for: .normal)
        btn_Disagree.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_disagree").lowercased())), for: .normal)
        txt_Description.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_hint_remark").lowercased()))
        btn_Submit.setTitle((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_submit").uppercased()), for: .normal)
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_my_opinion")).uppercased()
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        
        self.getAllOpinionData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Handler_Agree(_ sender: Any) {
        selectedOpinion = 1
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.view_SelectedTab.frame = (sender as! UIButton).frame
            self.btn_Agree.setTitleColor(UIColor.white, for: .normal)
            self.btn_Disagree.setTitleColor(UIColor.lightGray, for: .normal)
        }, completion: nil)
    }
    
    @IBAction func btn_Handler_Disagree(_ sender: Any) {
        selectedOpinion = 0
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
            self.view_SelectedTab.frame = (sender as! UIButton).frame
            self.btn_Agree.setTitleColor(UIColor.lightGray, for: .normal)
            self.btn_Disagree.setTitleColor(UIColor.white, for: .normal)
        }, completion: nil)
    }
    
    @IBAction func btn_Handler_SubMit(_ sender: Any) {
        self.view.endEditing(true)
        
        if txt_Description.text == (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_hint_remark").lowercased())) || (txt_Description.text?.isEmpty)! {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_PLEASE_ENTER_REMARK").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "post_id":postID, "action":"send", "opinion":"\(selectedOpinion)", "remark":txt_Description.text, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "opinion_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithSuccess(success: (dict.value(forKey: "success") as! String))
                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
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
    func getAllOpinionData() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "post_id":postID, "action":"get", "type":ApiUtillity.sharedInstance.getLoginType(), "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "opinion_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    if ((dict.value(forKey: "success") as! NSDictionary).value(forKey: "opinion") as! String) == "1" {
                        self.btn_Handler_Agree(self.btn_Agree)
                        self.txt_Description.text = ((dict.value(forKey: "success") as! NSDictionary).value(forKey: "remark") as! String)
                        self.txt_Description.textColor = UIColor.black
                    }
                    else if ((dict.value(forKey: "success") as! NSDictionary).value(forKey: "opinion") as! String) == "0" {
                        self.btn_Handler_Disagree(self.btn_Disagree)
                        self.txt_Description.text = ((dict.value(forKey: "success") as! NSDictionary).value(forKey: "remark") as! String)
                        self.txt_Description.textColor = UIColor.black
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
    
    
    //MARK:- TextView Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_hint_remark").lowercased())) {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result:String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if result.isEmpty {
            textView.text = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_hint_remark").lowercased()))
            textView.textColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            textView.resignFirstResponder()
        }
        
        return true
    }
}
