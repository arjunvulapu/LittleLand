//
//  LeftMenuVC.swift
//  LittleLand
//
//  Created by Lead on 26/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class LeftMenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var imageview_User: UIImageView!
    @IBOutlet weak var tableview_SideMenu: UITableView!
    
    
    //MARK:- Variable Declarations
    var sideMenuArr:[String] = [""]
    var sideMenuImageArr:[String] = [""]
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_User, cornurRadius: 45, isClipToBound: true, borderColor: "FFFFFF", borderWidth: 3)
        
        self.MFSidemenuViewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(MFSidemenuViewDidLoad), name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK:- All Method
    func MFSidemenuViewDidLoad() {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            sideMenuArr = [ApiUtillity.sharedInstance.getLanguageData(key: "lbl_home").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_notifications").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_news").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_about_us").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "ibl_CONTACT_US").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_language").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_logout").uppercased()]
            sideMenuImageArr = ["ic_sidemenu_home","ic_sidemenu_notification","ic_sidemenu_events","ic_sidemenu_news","ic_sidemenu_about_us","ic_sidemenu_contact","ic_sidemenu_language","ic_sidemenu_logout"]
        }
        else {
            sideMenuArr = [ApiUtillity.sharedInstance.getLanguageData(key: "lbl_home").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_notifications").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_news").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_MY_KIDS").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_about_us").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "ibl_CONTACT_US").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_language").uppercased(),ApiUtillity.sharedInstance.getLanguageData(key: "lbl_logout").uppercased()]
            sideMenuImageArr = ["ic_sidemenu_home","ic_sidemenu_notification","ic_sidemenu_events","ic_sidemenu_news","ic_sidemenu_kids","ic_sidemenu_about_us","ic_sidemenu_contact","ic_sidemenu_language","ic_sidemenu_language","ic_sidemenu_logout"]
        }
        imageview_User.kf.indicatorType = .activity
        imageview_User.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getUserData(key: "profile_pic")))
        tableview_SideMenu.reloadData()
    }
    
    func uploadTeachersORParentsResources(resourceName:String, image:Any, video:String) {
        let url = NSURL(string: ApiUtillity.sharedInstance.API(Join: "save_pic.php"))
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = (resourceName == "image" ? UIImagePNGRepresentation(image as! UIImage) : try! Data(contentsOf: URL(string: video)!))
        if(image_data == nil) {
            return
        }
        
        let body = NSMutableData()
        
        let name = (resourceName == "image" ? "IMAGE_\(arc4random_uniform(10000)).png" : "VIDEO_\(arc4random_uniform(10000)).mp4")
        let mimetype = (resourceName == "image" ? "image/png" : "video/mp4")
        
        //define the parameter
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\("uid")\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(ApiUtillity.sharedInstance.getUserData(key: "uid"))\r\n".data(using: String.Encoding.utf8)!)
        
        //define the Image data
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(name)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(request as URLRequest).responseJSON { (response) in
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithSuccess(success: (dict.value(forKey: "success") as! String))
                    // For Set UserData
                    ApiUtillity.sharedInstance.setUserData(data: (dict.value(forKey: "user") as! NSDictionary).mutableCopy() as! NSMutableDictionary)
                    NotificationCenter.default.post(name: Notification.Name("RELOAD_PROFILE_HOME"), object: nil)
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
    
    
    //MARK:- ImagePickerController Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.uploadTeachersORParentsResources(resourceName: "image", image: selectedImage, video: "")
        
        dismiss(animated: true) { 
            ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_AddUserImage(_ sender: Any) {
        let alert = UIAlertController(title: "Photo Library", message: "Upload photos for new post", preferredStyle: .actionSheet)
        alert.view.tintColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "DD6855")
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (UIAlertAction) in
            if ApiUtillity.sharedInstance.checkPermission(name: "camera", vc: self) {
                let picker:UIImagePickerController = UIImagePickerController()
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.view.tintColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "DD6855")
                    picker.delegate = self
                    picker.allowsEditing = true
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(picker, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (UIAlertAction) in
            if ApiUtillity.sharedInstance.checkPermission(name: "photo", vc: self) {
                let picker:UIImagePickerController = UIImagePickerController()
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    picker.view.tintColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "DD6855")
                    picker.delegate = self
                    picker.allowsEditing = true
                    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.present(picker, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = sender as! UIButton
                popoverController.sourceRect = (sender as! UIButton).bounds
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideMenuArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableview_SideMenu.dequeueReusableCell(withIdentifier: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "cell"))!
        
        let imageview_Icon:UIImageView = cell.viewWithTag(1) as! UIImageView
        imageview_Icon.image = UIImage(named: sideMenuImageArr[indexPath.row])
        
        let lbl_Name:UILabel = cell.viewWithTag(2) as! UILabel
        lbl_Name.text = sideMenuArr[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //["HOME","NOTIFICATIONS","EVENTS","NEWS","MY KIDS","ABOUT US","CONTACT US","LOGOUT"]
        
        if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_home").uppercased() {
            let vc:TeacherPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherPostVC") as! TeacherPostVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_notifications").uppercased() {
            let vc:NotificationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            vc.isOpenSideMenu = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_events").uppercased() {
            let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
            vc.isOpenSideMenu = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_news").uppercased() {
            let vc:ViewPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
            vc.isOpenSideMenu = true
            vc.isNews = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_MY_KIDS").uppercased() {
            let vc:MyKidsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MyKidsVC") as! MyKidsVC
            vc.isOpenSideMenu = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_about_us").uppercased() {
            let vc:AboutUsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "ibl_CONTACT_US").uppercased() {
            let vc:ContactUsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_language").uppercased() {
            if ApiUtillity.sharedInstance.checkCurrentlanguageEnglishOrNot() {
                UserDefaults.standard.setValue("ar", forKey: "CURRENT_LANGUAGE")
            }
            else{
                UserDefaults.standard.setValue("en", forKey: "CURRENT_LANGUAGE")
            }
            let vc:TeacherPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherPostVC") as! TeacherPostVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if sideMenuArr[indexPath.row] == ApiUtillity.sharedInstance.getLanguageData(key: "lbl_logout").uppercased() {
            UserDefaults.standard.removeObject(forKey: "USER_DATA")
            let vc:HomeVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
