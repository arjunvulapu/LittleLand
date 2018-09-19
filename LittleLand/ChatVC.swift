//
//  ChatVC.swift
//  LittleLand
//
//  Created by Lead on 21/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

class ChatVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_UserName: UILabel!
    @IBOutlet weak var lbl_User_Type: UILabel!
    @IBOutlet weak var imageview_User: UIImageView!
    @IBOutlet weak var imageview_Back: UIImageView!
    
    @IBOutlet weak var view_Space_Chat: UIView!
    @IBOutlet weak var tableview_Chat: UITableView!
    
    @IBOutlet weak var view_Chat: UIView!
    @IBOutlet weak var view_SendMessage: UIView!
    @IBOutlet weak var txt_SendMessage: UITextField!
    @IBOutlet weak var imageview_AttachFile: UIImageView!
    @IBOutlet weak var activityIndicator_AttachFile: UIActivityIndicatorView!
    @IBOutlet weak var btn_AttachFile: UIButton!
    @IBOutlet weak var view_SelectedAttachFile: UIView!
    
    @IBOutlet weak var imageview_SendMessage: UIImageView!
    @IBOutlet weak var btn_SendMessage: UIButton!
    
    
    //MARK:- Variable Declarations
    var to_ID:String = String()
    var selectedNameOfTeachersNParents:String = ""
    var selectedProfileOfTeachersNParents:String = ""
    var selectedFileType:String = ""
    var selectedFileName:String = ""
    var selectedFilePath:String = ""
    var formatter:DateFormatter = DateFormatter()
    var chatMessageArray:NSMutableArray = NSMutableArray()
    var isOpenSideMenu:Bool = false
    var isChatOpenFirstTime:Bool = true
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        txt_SendMessage.placeholder = (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_write_message").lowercased()))
        
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_User, cornurRadius: 15, isClipToBound: true, borderColor: "E1DFDF", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_SendMessage, cornurRadius: 15, isClipToBound: true, borderColor: "", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_SelectedAttachFile, cornurRadius: 11.5, isClipToBound: true, borderColor: "", borderWidth: 1.0)
        
        self.lbl_UserName.text = selectedNameOfTeachersNParents
        self.lbl_User_Type.text = (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "Parents" : "Teacher")
        self.imageview_User.kf.indicatorType = .activity
        self.imageview_User.kf.setImage(with: URL(string: selectedProfileOfTeachersNParents))
        
        //txt_SendMessage.inputAccessoryView = UIView.init()
        
        self.getChatHistory()
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
    
    @IBAction func btn_Handler_AttachFile(_ sender: Any) {
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
        alert.addAction(UIAlertAction(title: "Videos", style: .default, handler: { (UIAlertAction) in
            if ApiUtillity.sharedInstance.checkPermission(name: "photo", vc: self) {
                let picker:UIImagePickerController = UIImagePickerController()
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    picker.view.tintColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "DD6855")
                    picker.delegate = self
                    picker.allowsEditing = true
                    picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    picker.mediaTypes = [kUTTypeMovie as String]
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
    
    @IBAction func btn_Handler_RemoveAttachedFile(_ sender: Any) {
        self.selectedFileName = ""
        self.selectedFileType = ""
        view_SelectedAttachFile.isHidden = true
    }
    
    @IBAction func btn_Handler_SendMessage(_ sender: Any) {
        var isCallAPI:Bool = false
        if !(txt_SendMessage.text?.isEmpty)! {
            isCallAPI = true
        }
        if !selectedFileName.isEmpty {
            isCallAPI = true
        }
        if isCallAPI == false {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_message_or_select_attachment").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "action":"send_message", "to_uid":to_ID, "body":txt_SendMessage.text!, "file_name":selectedFileName, "file_type":selectedFileType, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        
        self.defaultManageChat(param: params as NSDictionary)
        self.txt_SendMessage.text = ""
        self.selectedFileName = ""
        self.selectedFileType = ""
        self.view_SelectedAttachFile.isHidden = true
        
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "message_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    print(dict.value(forKey: "success") as! String)
                    
                    // For Get Chat history
                    self.getChatHistory()
                    
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
    
    
    //MARK:- All Method
    func getChatHistory() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "action":"chat_history", "to_uid":to_ID, "offset":"0", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "message_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let to_user:NSMutableDictionary = (dict.value(forKey: "to_user") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    if to_user.count > 0 {
                        self.lbl_UserName.text = (to_user.value(forKey: "to_name") as! String)
                        self.lbl_User_Type.text = (to_user.value(forKey: "tagline") as! String)
                        self.imageview_User.kf.indicatorType = .activity
                        self.imageview_User.kf.setImage(with: URL(string: (to_user.value(forKey: "to_profile_pic") as! String)))
                    }
                    
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    self.chatMessageArray = success.mutableCopy() as! NSMutableArray
                    self.view_Space_Chat.frame = ((self.tableview_Chat.contentSize.height - self.view_Space_Chat.frame.size.height) < (UIScreen.main.bounds.size.height - 120) ? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: ((UIScreen.main.bounds.size.height - 120) - (self.tableview_Chat.contentSize.height))) : CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0))
                    self.tableview_Chat.reloadData()
                    if self.chatMessageArray.count > 0 {
                        self.tableview_Chat.scrollToRow(at: IndexPath(row: self.chatMessageArray.count-1, section: 0), at: .bottom, animated: true)
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
    
    func uploadTeachersORParentsResources(resourceName:String, image:Any, video:String) {
        let url = NSURL(string: ApiUtillity.sharedInstance.API(Join: "upload_file.php"))
        
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
        
        //define the data post parameter
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(name)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(image_data!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody = body as Data
        
        imageview_AttachFile.isHidden = true;
        activityIndicator_AttachFile.startAnimating()
        Alamofire.request(request as URLRequest).responseJSON { (response) in
            self.activityIndicator_AttachFile.stopAnimating()
            self.imageview_AttachFile.isHidden = false;
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    self.selectedFileName = success.value(forKey: "name") as! String
                    self.selectedFilePath = success.value(forKey: "full_path") as! String
                    self.selectedFileType = resourceName
                    self.view_SelectedAttachFile.isHidden = false
                    
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
    
    func defaultManageChat(param:NSDictionary) {
        if !(param.value(forKey: "body") as! String).isEmpty && !(param.value(forKey: "file_name") as! String).isEmpty {
            // Send Text Message With Image Or Video
            self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let Dic_Attachment:NSDictionary = NSDictionary(objects: [(param.value(forKey: "file_type") as! String), selectedFilePath], forKeys: ["media_type" as NSCopying, "path" as NSCopying])
            let Dic:NSDictionary = NSDictionary(objects: [Dic_Attachment, (param.value(forKey: "body") as! String), "\(ApiUtillity.sharedInstance.getUserData(key: "fname")) \(ApiUtillity.sharedInstance.getUserData(key: "lname"))", ApiUtillity.sharedInstance.getUserData(key: "profile_pic"), ApiUtillity.sharedInstance.getUserData(key: "uid"), "", "1", "\(self.formatter.string(from: Date.init()))", "", "", ""], forKeys: ["attachment" as NSCopying, "body" as NSCopying, "from_name" as NSCopying, "from_profile_pic" as NSCopying, "from_uid" as NSCopying, "id" as NSCopying, "is_sent" as NSCopying, "stamp" as NSCopying, "to_name" as NSCopying, "to_profile_pic" as NSCopying, "to_uid" as NSCopying])
            print(Dic)
            self.chatMessageArray.add(Dic)
        }
        else if !(param.value(forKey: "body") as! String).isEmpty {
            // Only Send Text Message
            self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let Dic:NSDictionary = NSDictionary(objects: [false, (param.value(forKey: "body") as! String), "\(ApiUtillity.sharedInstance.getUserData(key: "fname")) \(ApiUtillity.sharedInstance.getUserData(key: "lname"))", ApiUtillity.sharedInstance.getUserData(key: "profile_pic"), ApiUtillity.sharedInstance.getUserData(key: "uid"), "", "1", "\(self.formatter.string(from: Date.init()))", "", "", ""], forKeys: ["attachment" as NSCopying, "body" as NSCopying, "from_name" as NSCopying, "from_profile_pic" as NSCopying, "from_uid" as NSCopying, "id" as NSCopying, "is_sent" as NSCopying, "stamp" as NSCopying, "to_name" as NSCopying, "to_profile_pic" as NSCopying, "to_uid" as NSCopying])
            print(Dic)
            self.chatMessageArray.add(Dic)
        }
        else if !(param.value(forKey: "file_name") as! String).isEmpty {
            // Send Image Or Video
            self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let Dic_Attachment:NSDictionary = NSDictionary(objects: [(param.value(forKey: "file_type") as! String), selectedFilePath], forKeys: ["media_type" as NSCopying, "path" as NSCopying])
            let Dic:NSDictionary = NSDictionary(objects: [Dic_Attachment, "", "\(ApiUtillity.sharedInstance.getUserData(key: "fname")) \(ApiUtillity.sharedInstance.getUserData(key: "lname"))", ApiUtillity.sharedInstance.getUserData(key: "profile_pic"), ApiUtillity.sharedInstance.getUserData(key: "uid"), "", "1", "\(self.formatter.string(from: Date.init()))", "", "", ""], forKeys: ["attachment" as NSCopying, "body" as NSCopying, "from_name" as NSCopying, "from_profile_pic" as NSCopying, "from_uid" as NSCopying, "id" as NSCopying, "is_sent" as NSCopying, "stamp" as NSCopying, "to_name" as NSCopying, "to_profile_pic" as NSCopying, "to_uid" as NSCopying])
            print(Dic)
            self.chatMessageArray.add(Dic)
        }
        
        self.tableview_Chat.reloadData()
        if self.chatMessageArray.count > 0 {
            self.tableview_Chat.scrollToRow(at: IndexPath(row: self.chatMessageArray.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    
    //MARK:- ImagePickerController Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type:String = info[UIImagePickerControllerMediaType] as! String
        if type == (kUTTypeMovie as String) {
            selectedFileType = "video"
            let path:String = "\(info[UIImagePickerControllerMediaURL] as! NSURL)"
            self.uploadTeachersORParentsResources(resourceName: "video", image: "", video: path)
        }
        else {
            selectedFileType = "image"
            let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            self.uploadTeachersORParentsResources(resourceName: "image", image: selectedImage, video: "")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "is_sent") as! String) == "1" {
            if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment")) is Bool {
                let cell:chat_text_right_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_text_right_cell") as! chat_text_right_cell
                cell.imageview_User.kf.indicatorType = .activity
                cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "from_profile_pic") as! String)))
                cell.lbl_Chat_Message.text = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
                self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                self.formatter.dateFormat = "dd MMM, yyyy"
                cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                
                return cell
            }
            else {
                if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).isEmpty {
                    let cell:chat_image_right_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_image_right_cell") as! chat_image_right_cell
                    cell.imageview_User.kf.indicatorType = .activity
                    cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "from_profile_pic") as! String)))
                    if (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
                        cell.imageview_Chat_Image.image = UIImage(named: "ic_play_video")
                    }
                    else {
                        cell.imageview_Chat_Image.kf.indicatorType = .activity
                        cell.imageview_Chat_Image.kf.setImage(with: URL(string: (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String)))
                    }
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                    self.formatter.dateFormat = "dd MMM, yyyy"
                    cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                    
                    return cell
                }
                else {
                    let cell:chat_image_text_right_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_image_text_right_cell") as! chat_image_text_right_cell
                    cell.imageview_User.kf.indicatorType = .activity
                    cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "from_profile_pic") as! String)))
                    if (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
                        cell.imageview_Chat_Image.image = UIImage(named: "ic_play_video")
                    }
                    else {
                        cell.imageview_Chat_Image.kf.indicatorType = .activity
                        cell.imageview_Chat_Image.kf.setImage(with: URL(string: (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String)))
                    }
                    cell.lbl_Chat_Message.text = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                    self.formatter.dateFormat = "dd MMM, yyyy"
                    cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                    
                    return cell
                }

            }
        }
        else {
            if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment")) is Bool {
                let cell:chat_text_left_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_text_left_cell") as! chat_text_left_cell
                cell.imageview_User.kf.indicatorType = .activity
                cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "to_profile_pic") as! String)))
                cell.lbl_Chat_Message.text = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
                self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                self.formatter.dateFormat = "dd MMM, yyyy"
                cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                
                return cell
            }
            else {
                if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).isEmpty {
                    let cell:chat_image_left_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_image_left_cell") as! chat_image_left_cell
                    cell.imageview_User.kf.indicatorType = .activity
                    cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "to_profile_pic") as! String)))
                    if (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
                        cell.imageview_Chat_Image.image = UIImage(named: "ic_play_video")
                    }
                    else {
                        cell.imageview_Chat_Image.kf.indicatorType = .activity
                        cell.imageview_Chat_Image.kf.setImage(with: URL(string: (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String)))
                    }
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                    self.formatter.dateFormat = "dd MMM, yyyy"
                    cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                    
                    return cell
                }
                else {
                    let cell:chat_image_text_left_cell = self.tableview_Chat.dequeueReusableCell(withIdentifier: "chat_image_text_left_cell") as! chat_image_text_left_cell
                    cell.imageview_User.kf.indicatorType = .activity
                    cell.imageview_User.kf.setImage(with: URL(string: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "to_profile_pic") as! String)))
                    if (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
                        cell.imageview_Chat_Image.image = UIImage(named: "ic_play_video")
                    }
                    else {
                        cell.imageview_Chat_Image.kf.indicatorType = .activity
                        cell.imageview_Chat_Image.kf.setImage(with: URL(string: (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String)))
                    }
                    cell.lbl_Chat_Message.text = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String)
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tempDate:Date = self.formatter.date(from: ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "stamp") as! String))!
                    self.formatter.dateFormat = "dd MMM, yyyy"
                    cell.lbl_Chat_Date.text = self.formatter.string(from: tempDate)
                    
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment")) is Bool {
            let constraintRect = CGSize(width: UIScreen.main.bounds.size.width-76, height: .greatestFiniteMagnitude)
            let boundingBox = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 11)!], context: nil)
            let height:CGFloat = ceil(boundingBox.height)
            if height < 50 {
                return 50
            }
            return height + 30
        }
        else {
            if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).isEmpty {
                return 137
            }
            else {
                let constraintRect = CGSize(width: 129.0, height: .greatestFiniteMagnitude)
                let boundingBox = ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "body") as! String).boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 11)!], context: nil)
                let height:CGFloat = ceil(boundingBox.height)
                return 167+height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment")) is Bool {
            
        }
        else if (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
            let vc:PlayResourcesVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "PlayResourcesVC") as! PlayResourcesVC
            vc.resource_Name = "video"
            vc.video_Url = (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "big_image") as! String)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            var images = [SKPhoto]()
            var currentIndex:Int = 0
            var i:Int = 0
            for item in chatMessageArray {
                if ((item as! NSDictionary).value(forKey: "attachment")) is Bool {
                    
                }
                else {
                    if (((item as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "media_type") as! String) != "video" {
                        if (((item as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String) == (((chatMessageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "path") as! String) {
                            currentIndex = i
                        }
                        let photo = SKPhoto.photoWithImageURL((((item as! NSDictionary).value(forKey: "attachment") as! NSDictionary).value(forKey: "big_image") as! String))
                        photo.shouldCachePhotoURLImage = true
                        images.append(photo)
                        i += 1
                    }
                }
            }
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(currentIndex)
            present(browser, animated: true, completion: {})
        }
    }
    
}
