//
//  ViewPostVC.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class ViewPostVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var lbl_Weekly: UILabel!
    @IBOutlet weak var view_Tab_Weekly: UIView!
    @IBOutlet weak var lbl_ToDay: UILabel!
    @IBOutlet weak var view_Tab_ToDay: UIView!
    @IBOutlet weak var lbl_Monthly: UILabel!
    @IBOutlet weak var view_Tab_Monthly: UIView!
    
    @IBOutlet weak var tableview_Post: UITableView!
    
    
    //MARK:- Variable Declarations
    var selectedClassID:String = String()
    var viewPostArray:NSMutableArray = NSMutableArray()
    var isOpenSideMenu:Bool = false
    var isNews:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Weekly.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_weekly").uppercased())
        lbl_ToDay.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_today").uppercased())
        lbl_Monthly.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_monthly").uppercased())
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_post").uppercased())
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
        if isNews == true {
            lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_news").uppercased())
        }
        self.setTabbar(index: 2)
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
    
    @IBAction func btn_Handler_Weekly(_ sender: Any) {
        self.setTabbar(index: 1)
    }
    
    @IBAction func btn_Handler_ToDay(_ sender: Any) {
        self.setTabbar(index: 2)
    }
    
    @IBAction func btn_Handler_Monthly(_ sender: Any) {
        self.setTabbar(index: 3)
    }
    
    
    //MARK:- All Method
    func setTabbar(index:Int) {
        switch index {
        case 1:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_Weekly.frame = CGRect(x: self.view_Tab_Weekly.frame.origin.x, y: self.view_Tab_Weekly.frame.origin.y, width: self.view_Tab_Weekly.frame.size.width, height: 35)
            })
            self.view_Tab_ToDay.frame = CGRect(x: self.view_Tab_ToDay.frame.origin.x, y: self.view_Tab_ToDay.frame.origin.y, width: self.view_Tab_ToDay.frame.size.width, height: 26.5)
            self.view_Tab_Monthly.frame = CGRect(x: self.view_Tab_Monthly.frame.origin.x, y: self.view_Tab_Monthly.frame.origin.y, width: self.view_Tab_Monthly.frame.size.width, height: 26.5)
            
            self.getPostByTimeWise(time_period: "week")
            break
        
        case 2:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_ToDay.frame = CGRect(x: self.view_Tab_ToDay.frame.origin.x, y: self.view_Tab_ToDay.frame.origin.y, width: self.view_Tab_ToDay.frame.size.width, height: 35)
            })
            self.view_Tab_Weekly.frame = CGRect(x: self.view_Tab_Weekly.frame.origin.x, y: self.view_Tab_Weekly.frame.origin.y, width: self.view_Tab_Weekly.frame.size.width, height: 26.5)
            self.view_Tab_Monthly.frame = CGRect(x: self.view_Tab_Monthly.frame.origin.x, y: self.view_Tab_Monthly.frame.origin.y, width: self.view_Tab_Monthly.frame.size.width, height: 26.5)
            
            self.getPostByTimeWise(time_period: "today")
            break
            
        case 3:
            UIView.animate(withDuration: 0.7, animations: {
                self.view_Tab_Monthly.frame = CGRect(x: self.view_Tab_Monthly.frame.origin.x, y: self.view_Tab_Monthly.frame.origin.y, width: self.view_Tab_Monthly.frame.size.width, height: 35)
            })
            self.view_Tab_Weekly.frame = CGRect(x: self.view_Tab_Weekly.frame.origin.x, y: self.view_Tab_Weekly.frame.origin.y, width: self.view_Tab_Weekly.frame.size.width, height: 26.5)
            self.view_Tab_ToDay.frame = CGRect(x: self.view_Tab_ToDay.frame.origin.x, y: self.view_Tab_ToDay.frame.origin.y, width: self.view_Tab_ToDay.frame.size.width, height: 26.5)
            
            self.getPostByTimeWise(time_period: "month")
            break
            
        default: break
        }
    }
    
    func getPostByTimeWise(time_period:String) {
        var params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "class_id":selectedClassID, "action":"get_list", "time_period":time_period, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        if isOpenSideMenu == true {
            params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "action":"get_news", "time_period":time_period, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        }
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "post_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.viewPostArray = success.mutableCopy() as! NSMutableArray
                    self.tableview_Post.reloadData()
                    
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
        if viewPostArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_Post.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_No_Post_Available")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_Post.backgroundView = noDataLabel
        }
        else {
            tableview_Post.backgroundView = nil
        }
        return viewPostArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ViewPostCell = self.tableview_Post.dequeueReusableCell(withIdentifier: "ViewPostCell") as! ViewPostCell
        cell.lbl_DescName.text = ((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "title") as! String)
        cell.lbl_Time.text = ((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String)
        cell.imageview_Post.kf.indicatorType = .activity
        print(((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "type") as! String))
        //cell.imageview_Post.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
        if(((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "type") as! String) == "video"){
            cell.imageview_Post.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));

        }else{
            cell.imageview_Post.transform = CGAffineTransform(rotationAngle:0);

        }
        cell.imageview_Post.kf.setImage(with: URL(string: ((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "image") as! String)))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:ViewPostDetailsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostDetailsVC") as! ViewPostDetailsVC
        vc.postID = ((viewPostArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "id") as! String)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
