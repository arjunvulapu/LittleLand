//
//  NewPostVC.swift
//  LittleLand
//
//  Created by Lead on 22/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import MobileCoreServices

class NewPostVC: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SelectedTeachersORParentsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    @IBOutlet weak var view_PostMessage: UIView!
    @IBOutlet weak var view_SelectClass: UIView!
    @IBOutlet weak var btn_SelectClass: UIButton!
    @IBOutlet weak var view_SelectParents: UIView!
    @IBOutlet weak var btn_SelectParents: UIButton!
    @IBOutlet weak var view_MessageTitle: UIView!
    @IBOutlet weak var txt_MessageTitle: UITextField!
    @IBOutlet weak var view_MessageDescription: UIView!
    @IBOutlet weak var textview_MessageDescription: UITextView!
    @IBOutlet weak var view_Upload: UIView!
    @IBOutlet weak var collectionview_ImageSelection: UICollectionView!
    @IBOutlet weak var lbl_AskForOpinion: UILabel!
    @IBOutlet weak var imageview_AskForOpinion: UIImageView!
    @IBOutlet weak var btn_Submit: UIButton!
    
    
    //MARK:- Variable Declarations
    var pickerPopUp:PickerPopUpVC = PickerPopUpVC()
    var selectedIndexOfClassNChild:Int = 0
    var selectedIDOfClassNChild:String = ""
    var selectedNameOfClassNChild:String = ""
    var ClassNChildsArray:NSMutableArray = NSMutableArray()
    var selectedIDOfTeachersNParents:String = ""
    var TeachersNParentsArray:NSMutableArray = NSMutableArray()
    var selectedFileNameOfClassNChild:String = ""
    var selectedFileTypeOfClassNChild:String = ""
    var isUploadImage:Bool = false
    var selectedImagesArrayOfTeachersNParents:NSMutableArray = NSMutableArray()
    var isSelectAskForOpinion:Int = 0
    var isOpenSideMenu:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setDesign()
        
        ClassNChildsArray = (ApiUtillity.sharedInstance.getDataIntoUserData(key: (ApiUtillity.sharedInstance.getLoginType() == "teacher" ? "class" : "childs")).mutableCopy()  as! NSMutableArray)
        print(ClassNChildsArray)
        // Auto Select Class
        if ClassNChildsArray.count > 0 {
            selectedIDOfClassNChild = ((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: "id") as! String)
            selectedNameOfClassNChild = ((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String)
            btn_SelectClass.setTitle(((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), for: .normal)
            
            self.getTeachersORParents()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionview_ImageSelection.reloadData()
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
    
    @IBAction func btn_Handler_SelectClass(_ sender: Any) {
        self.openPickerPopUp()
    }
    
    @IBAction func btn_Handler_SelectParents(_ sender: Any) {
        if selectedIDOfClassNChild.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_select_class").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        let vc:SelectTeacherORParentsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "SelectTeacherORParentsVC") as! SelectTeacherORParentsVC
        vc.delegate = self
        vc.TeachersNParentsArray = TeachersNParentsArray.mutableCopy() as! NSMutableArray
        vc.selectedNameOfClassNChild = selectedNameOfClassNChild
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Handler_Upload(_ sender: Any) {
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
        alert.addAction(UIAlertAction(title: "Capture Video", style: .default, handler: { (UIAlertAction) in
            if ApiUtillity.sharedInstance.checkPermission(name: "camera", vc: self) {
                let picker:UIImagePickerController = UIImagePickerController()
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    picker.view.tintColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "DD6855")
                    picker.delegate = self
                    picker.allowsEditing = true
                    picker.sourceType = UIImagePickerControllerSourceType.camera
                    picker.mediaTypes = [kUTTypeMovie as String]
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
    
    @IBAction func btn_Handler_DeleteSelectedImage(_ sender: UIButton) {
        selectedImagesArrayOfTeachersNParents.removeObject(at: sender.tag)
        collectionview_ImageSelection.reloadData()
    }
    
    @IBAction func btn_Handler_AskForOpinion(_ sender: Any) {
        if isSelectAskForOpinion == 0 {
           isSelectAskForOpinion = 1
            imageview_AskForOpinion.image = UIImage(named: "ic_checkbox_check")
        }
        else {
            isSelectAskForOpinion = 0
            imageview_AskForOpinion.image = UIImage(named: "ic_checkbox_uncheck")
        }
    }
    
    @IBAction func btn_Handler_Submit(_ sender: Any) {
        self.view.endEditing(true)
        
        if selectedIDOfClassNChild.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_select_class").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        if (txt_MessageTitle.text?.isEmpty)! {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Title").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        if textview_MessageDescription.text == ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_message").lowercased()) || (textview_MessageDescription.text?.isEmpty)! {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Description").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        
        var file_name:String = ""
        var file_type:String = ""
        if selectedImagesArrayOfTeachersNParents.count > 0 {
            for item in selectedImagesArrayOfTeachersNParents {
                file_name = file_name.appending("\((item as! NSDictionary).value(forKey: "name") as! String),")
                file_type = file_type.appending("\((item as! NSDictionary).value(forKey: "media_type") as! String),")
            }
        }
        if !file_name.isEmpty {
            file_name = (file_name as NSString).substring(to: (file_name as NSString).length-1)
            file_type = (file_type as NSString).substring(to: (file_type as NSString).length-1)
        }
        
        let params = ["action":"new_post", "uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "class_id":selectedIDOfClassNChild, "selected_uids":selectedIDOfTeachersNParents, "title":txt_MessageTitle.text!, "description":textview_MessageDescription.text!, "file_name":file_name, "file_type":file_type, "is_opinion":"\(isSelectAskForOpinion)", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "post_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    ApiUtillity.sharedInstance.dismissSVProgressHUDWithSuccess(success: dict.value(forKey: "success") as! String)
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
    func setDesign() {
        lbl_Heder.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_new_post")
        btn_SelectClass.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_select_class").lowercased())), for: .normal)
        btn_SelectParents.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Select_Parents").lowercased())), for: .normal)
        txt_MessageTitle.placeholder = ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_message_title").lowercased())
        textview_MessageDescription.text = ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_message").lowercased())
        lbl_AskForOpinion.text = ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_ask_for_opinion").lowercased())
        btn_Submit.setTitle(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_submit").uppercased(), for: .normal)
        
        
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            ApiUtillity.sharedInstance.setShadow(obj: self.view_PostMessage, cornurRadius: 15, ClipToBound: true, masksToBounds: false, shadowColor: "AAAAAA", shadowOpacity: 0.5, shadowOffset: .zero, shadowRadius: 3.0, shouldRasterize: false, shadowPath: self.view_PostMessage.bounds)
        }
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_SelectClass, cornurRadius: 15, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_SelectParents, cornurRadius: 15, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_MessageTitle, cornurRadius: 15, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_MessageDescription, cornurRadius: 15, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: view_Upload, cornurRadius: 15, isClipToBound: true, borderColor: "F0F0F0", borderWidth: 1.0)
        ApiUtillity.sharedInstance.setCornurRadius(obj: btn_Submit, cornurRadius: 15, isClipToBound: true, borderColor: "E28A80", borderWidth: 1.0)
        
        ApiUtillity.sharedInstance.setPlaceHolderColorToTextField(obj: txt_MessageTitle, color: "555555")
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
    
    func compressVideo(sourceURL:String, completionBlock:@escaping (String) -> Void) {
        let assest = AVURLAsset(url: URL(string: sourceURL)!)
        guard let exportSession = AVAssetExportSession(asset: assest, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        do {
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentDirectory.appendingPathComponent("image.mp4")
            if fileManager.fileExists(atPath: fileURL.relativePath) {
                try fileManager.removeItem(at: fileURL)
            }
            exportSession.outputURL = fileURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously {
                completionBlock(fileURL.absoluteString)
            }
        } catch let error {
            print(error)
        }
    }
    
    func uploadTeachersORParentsResources(resourceName:String, image:Any, video:String) {
        let url = NSURL(string: ApiUtillity.sharedInstance.API(Join: "upload_file.php"))
        
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let image_data = (resourceName == "image" ? UIImageJPEGRepresentation(image as! UIImage, 0.5) : try! Data(contentsOf: URL(string: video)!))
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
        
        DispatchQueue.main.async {
            self.isUploadImage = true
            self.btn_Submit.isUserInteractionEnabled = false
            self.collectionview_ImageSelection.reloadData()
        }
        Alamofire.request(request as URLRequest).responseJSON { (response) in
            self.isUploadImage = false
            self.btn_Submit.isUserInteractionEnabled = true
            self.collectionview_ImageSelection.reloadData()
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    self.selectedFileNameOfClassNChild = success.value(forKey: "name") as! String
                    self.selectedImagesArrayOfTeachersNParents.add(["name":success.value(forKey: "name") as! String, "full_path":success.value(forKey: "full_path") as! String, "media_type":resourceName])
                    self.collectionview_ImageSelection.reloadData()
                    
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
    
    func getSelectedTeachersORParentsIDandName(ID: String, NAME: String) {
        print(ID, NAME)
        
        if !ID.isEmpty {
            selectedIDOfTeachersNParents = ID
            btn_SelectParents.setTitle(NAME, for: .normal)
        }
        else {
            selectedIDOfTeachersNParents = ""
            btn_SelectParents.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Select_Parents").lowercased())), for: .normal)
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
        btn_SelectClass.setTitle(((ClassNChildsArray.object(at: selectedIndexOfClassNChild) as! NSDictionary).value(forKey: ApiUtillity.sharedInstance.getCurrentLanguageString(key: "class_name")) as! String), for: .normal)
        
        selectedIndexOfClassNChild = 0
        selectedIDOfTeachersNParents = ""
        btn_SelectParents.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Select_Parents").lowercased())), for: .normal)
        
        self.getTeachersORParents()
    }
    
    
    //MARK:- TextView Method
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_message").lowercased()) {
            textView.text = ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result:String = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if result.isEmpty {
            textView.text = ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_message").lowercased())
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    
    //MARK:- ImagePickerController Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type:String = info[UIImagePickerControllerMediaType] as! String
        if type == (kUTTypeMovie as String) {
            selectedFileTypeOfClassNChild = "video"
            let path:String = "\(info[UIImagePickerControllerMediaURL] as! NSURL)"
            self.compressVideo(sourceURL: path, completionBlock: { (compressedPath) in
                self.uploadTeachersORParentsResources(resourceName: "video", image: "", video: compressedPath)
            })
        }
        else {
            selectedFileTypeOfClassNChild = "image"
            let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            self.uploadTeachersORParentsResources(resourceName: "image", image: selectedImage, video: "")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- CollectionView Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImagesArrayOfTeachersNParents.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == selectedImagesArrayOfTeachersNParents.count {
            let cell:NewPostImageSelectionCell = collectionview_ImageSelection.dequeueReusableCell(withReuseIdentifier: "NewPostImageSelectionCell", for: indexPath) as! NewPostImageSelectionCell
            cell.btn_SelectImage.addTarget(self, action: #selector(btn_Handler_Upload(_:)), for: .touchUpInside)
            if isUploadImage {
                cell.activityIndicatorImageSelection.startAnimating()
                cell.btn_SelectImage.isUserInteractionEnabled = false
            }
            else {
                cell.activityIndicatorImageSelection.stopAnimating()
                cell.btn_SelectImage.isUserInteractionEnabled = true
            }
            return cell
        }
        else {
            let cell:NewPostImageCell = collectionview_ImageSelection.dequeueReusableCell(withReuseIdentifier: "NewPostImageCell", for: indexPath) as! NewPostImageCell
            
            cell.imageview_NewPostImage.kf.indicatorType = .activity
            cell.imageview_NewPostImage.kf.setImage(with: URL(string: (selectedImagesArrayOfTeachersNParents.object(at: indexPath.row) as! NSDictionary).value(forKey: "full_path") as! String))
            
            cell.btn_Delete.tag = indexPath.row
            cell.btn_Delete.addTarget(self, action: #selector(btn_Handler_DeleteSelectedImage(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectedImagesArrayOfTeachersNParents.count <= 0 {
            return CGSize(width: collectionview_ImageSelection.frame.size.width, height: collectionview_ImageSelection.frame.size.height)
        }
        else if indexPath.row == selectedImagesArrayOfTeachersNParents.count {
            return CGSize(width: 80, height: 80)
        }
        else {
            return CGSize(width: (collectionview_ImageSelection.frame.size.width-4)/3, height: collectionview_ImageSelection.frame.size.height)
        }
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
