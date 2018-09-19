//
//  ViewAllOpinionVC.swift
//  LittleLand
//
//  Created by Lead on 26/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class ViewAllOpinionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var lbl_Agree: UILabel!
    @IBOutlet weak var view_Tab_Agree: UIView!
    @IBOutlet weak var lbl_Disagree: UILabel!
    @IBOutlet weak var view_Tab_Disagree: UIView!
    @IBOutlet weak var lbl_Pending: UILabel!
    @IBOutlet weak var view_Tab_Pending: UIView!
    
    @IBOutlet weak var tableview_Opinion: UITableView!
    
    
    //MARK:- Variable Declarations
    var postID:String = String()
    var opinionArray:NSMutableArray = NSMutableArray()
    var opinionDic:NSMutableDictionary = NSMutableDictionary()
    var isOpenSideMenu:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Agree.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_agree").uppercased())
        lbl_Disagree.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_disagree").uppercased())
        lbl_Pending.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_pending").uppercased())
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_viewall_opinion")).uppercased()
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
        self.setTabbar(index: 1)
        self.getAllOpinionData()
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
    
    @IBAction func btn_Handler_Agree(_ sender: Any) {
        self.setTabbar(index: 1)
    }
    
    @IBAction func btn_Handler_Disagree(_ sender: Any) {
        self.setTabbar(index: 2)
    }
    
    @IBAction func btn_Handler_Pending(_ sender: Any) {
        self.setTabbar(index: 3)
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
                    self.opinionDic = ((dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary)
                    self.setTabbar(index: 1)
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
    
    func setTabbar(index:Int) {
        switch index {
        case 1:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_Agree.frame = CGRect(x: self.view_Tab_Agree.frame.origin.x, y: self.view_Tab_Agree.frame.origin.y, width: self.view_Tab_Agree.frame.size.width, height: 35)
            })
            self.view_Tab_Disagree.frame = CGRect(x: self.view_Tab_Disagree.frame.origin.x, y: self.view_Tab_Disagree.frame.origin.y, width: self.view_Tab_Disagree.frame.size.width, height: 26.5)
            self.view_Tab_Pending.frame = CGRect(x: self.view_Tab_Pending.frame.origin.x, y: self.view_Tab_Pending.frame.origin.y, width: self.view_Tab_Pending.frame.size.width, height: 26.5)
            
            if (self.opinionDic.value(forKey: "agree") != nil) {
                self.opinionArray = (self.opinionDic.value(forKey: "agree") as! NSArray).mutableCopy() as! NSMutableArray
            }
            else {
                self.opinionArray = NSMutableArray()
            }
            tableview_Opinion.reloadData()
            break
            
        case 2:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_Disagree.frame = CGRect(x: self.view_Tab_Disagree.frame.origin.x, y: self.view_Tab_Disagree.frame.origin.y, width: self.view_Tab_Disagree.frame.size.width, height: 35)
            })
            self.view_Tab_Agree.frame = CGRect(x: self.view_Tab_Agree.frame.origin.x, y: self.view_Tab_Agree.frame.origin.y, width: self.view_Tab_Agree.frame.size.width, height: 26.5)
            self.view_Tab_Pending.frame = CGRect(x: self.view_Tab_Pending.frame.origin.x, y: self.view_Tab_Pending.frame.origin.y, width: self.view_Tab_Pending.frame.size.width, height: 26.5)
            
            if (self.opinionDic.value(forKey: "disagree") != nil) {
                self.opinionArray = (self.opinionDic.value(forKey: "disagree") as! NSArray).mutableCopy() as! NSMutableArray
            }
            else {
                self.opinionArray = NSMutableArray()
            }
            tableview_Opinion.reloadData()
            break
            
        case 3:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_Pending.frame = CGRect(x: self.view_Tab_Pending.frame.origin.x, y: self.view_Tab_Pending.frame.origin.y, width: self.view_Tab_Pending.frame.size.width, height: 35)
            })
            self.view_Tab_Agree.frame = CGRect(x: self.view_Tab_Agree.frame.origin.x, y: self.view_Tab_Agree.frame.origin.y, width: self.view_Tab_Agree.frame.size.width, height: 26.5)
            self.view_Tab_Disagree.frame = CGRect(x: self.view_Tab_Disagree.frame.origin.x, y: self.view_Tab_Disagree.frame.origin.y, width: self.view_Tab_Disagree.frame.size.width, height: 26.5)
            
            if (self.opinionDic.value(forKey: "pending") != nil) {
                self.opinionArray = (self.opinionDic.value(forKey: "pending") as! NSArray).mutableCopy() as! NSMutableArray
            }
            else {
                self.opinionArray = NSMutableArray()
            }
            tableview_Opinion.reloadData()
            break
            
        default: break
        }
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if opinionArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_Opinion.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_opinion_found")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_Opinion.backgroundView = noDataLabel
        }
        else {
            tableview_Opinion.backgroundView = nil
        }
        return opinionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ViewAllOpinionCell = self.tableview_Opinion.dequeueReusableCell(withIdentifier: "ViewAllOpinionCell") as! ViewAllOpinionCell
        cell.imageview_Child.kf.setImage(with: URL(string: ((opinionArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String)))
        cell.lbl_ParentsName.text = ((opinionArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String)
        cell.lbl_ChildName.text = ((opinionArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "child_name") as! String)
        cell.lbl_Remark.text = ((opinionArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "remark") as! String)
        cell.lbl_DateTime.text = ((opinionArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
