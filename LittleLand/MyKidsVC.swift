//
//  MyKidsVC.swift
//  LittleLand
//
//  Created by Lead on 29/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class MyKidsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var imageview_SideMenu: UIImageView!
    @IBOutlet weak var tableview_Kids: UITableView!
    
    
    //MARK:- Variable Declarations
    var kidsArray:NSMutableArray = NSMutableArray()
    var ref_ID:String = String()
    var isOpenSideMenu:Bool = false
    var selectedChildID:String = String()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_MY_KIDS").uppercased()
        
        if isOpenSideMenu == true {
            imageview_SideMenu.image = UIImage(named: "ic_menu")
        }
        self.getKidsData()
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
    
    @IBAction func btn_Handler_ChangeProfileChild(_ sender: UIButton) {
        selectedChildID = (self.kidsArray.object(at: sender.tag) as! NSDictionary).value(forKey: "uid") as! String
        
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
    
    
    //MARK:- All Method
    func getKidsData() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "action":"get_kids", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "get_data.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.kidsArray = success.mutableCopy() as! NSMutableArray
                    self.tableview_Kids.reloadData()
                    
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
        body.append("\(selectedChildID)\r\n".data(using: String.Encoding.utf8)!)
        
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
                    self.getKidsData()
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
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if kidsArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_Kids.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_kids_found")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_Kids.backgroundView = noDataLabel
        }
        else {
            tableview_Kids.backgroundView = nil
        }
        return kidsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MyKidsCell = tableview_Kids.dequeueReusableCell(withIdentifier: "MyKidsCell") as! MyKidsCell
        cell.imageview_Child.kf.indicatorType = .activity
        cell.imageview_Child.kf.setImage(with: URL(string: ((kidsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String)))
        cell.btn_ChildImage.tag = indexPath.row
        cell.btn_ChildImage.addTarget(self, action: #selector(btn_Handler_ChangeProfileChild(_:)), for: .touchUpInside)
        cell.lbl_ChildName.text = ((kidsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "name") as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
