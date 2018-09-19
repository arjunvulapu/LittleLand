//
//  ApiUtillity.swift
//  Trends
//
//  Created by Lead on 24/06/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import SVProgressHUD
import Whisper
import AVFoundation
import Photos

private let _sharedInstance = ApiUtillity()
var VCname:String = String()
var ClassName:String = String()
var ClassID:String = String()
public var PassProductId:String = String()
let BASE_URL:String = "https://dashboard.littlelandapp.com/api/"
//http://server.mywebdemo.in/nurcery/api/

class ApiUtillity: NSObject {
    
    class var sharedInstance: ApiUtillity {
        return _sharedInstance
    }
    
    
    // For API Link
    func API(Join:String) -> String {
        return BASE_URL + Join
    }
    
    // For Set Login Type
    func setLoginType(type:String) {
        UserDefaults.standard.setValue(type, forKey: "LOGIN_TYPE")
    }
    
    // For Get Login Type
    func getLoginType() -> String {
        return UserDefaults.standard.string(forKey: "LOGIN_TYPE")!
    }
    
    // For Get/Set SelectedDate
    struct selectedDate {
        var Day:Int = 0
        var Month:Int = 0
        var Year:Int = 0
        var Date:String = ""
    }
    
    // For Get Current Language String
    func getCurrentLanguageString(key:String) -> String {
        if let Name:String =  UserDefaults.standard.value(forKey: "CURRENT_LANGUAGE") as? String {
            if Name == "en" {
                return key
            }
            else{
                return key+"_ar"
            }
        }
        else {
            return key
        }
    }
    
    // For Check-Permission
    func checkPermission(name:String, vc:UIViewController) -> Bool {
        if name == "photo" {
            if PHPhotoLibrary.authorizationStatus() == .denied {
                let alert = UIAlertController(title: "Photo Access", message: "Please give this app permission to access your photo library in your settings app!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (UIAlertAction) in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                vc.present(alert, animated: true, completion: nil)
                return false
            }
            else {
                return true
            }
        }
        else if name == "camera" {
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied {
                let alert = UIAlertController(title: "Camera Access", message: "Please give this app permission to access your camera in your settings app!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { (UIAlertAction) in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                vc.present(alert, animated: true, completion: nil)
                return false
            }
            else {
                return true
            }
        }
        return false
    }
    
    // For Get Color Using HexCode
    func getColorIntoHex(Hex:String) -> UIColor {
        if Hex.isEmpty {
            return UIColor.clear
        }
        let scanner = Scanner(string: Hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        return UIColor.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: 1)
    }
    
    // Open SideMenu
    func openSideMenu() {
        let storyboard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        SideMenuManager.menuLeftNavigationController = storyboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuWidth = 170;
    }
    
    // Set Language Data
    func setLanguageData(data:NSMutableDictionary) {
        var Dic:NSMutableDictionary = NSMutableDictionary()
        Dic = data.mutableCopy() as! NSMutableDictionary
        
        UserDefaults.standard.setValue(Dic, forKey: "LANGUAGE_DATA")
    }
    // Get Language Data
    func getLanguageData(key:String) -> String {
        if var Dic:NSMutableDictionary =  UserDefaults.standard.value(forKey: "LANGUAGE_DATA") as? NSMutableDictionary {
            Dic = (Dic.value(forKey: (self.checkCurrentlanguageEnglishOrNot() == true ? "en" : "ar")) as! NSMutableDictionary).mutableCopy() as! NSMutableDictionary
            if Dic.value(forKey: key) as? String != nil {
                let value:String = Dic.value(forKey: key) as! String
                if !value.isEmpty {
                    return value;
                }
                else{
                    return ""
                }
            }
            else{
                return ""
            }
        }
        else {
            return ""
        }
    }
    
    // Show All Type Message
    func showErrorMessage(Title:String, SubTitle:String, ForNavigation:UINavigationController) {
        let announcement = Announcement(title: Title, subtitle: SubTitle, image: UIImage(named: ""), duration: 2)
        Whisper.show(shout: announcement, to: ForNavigation)
    }
    
    // Get Current Language Name
    func getCurrentLanguageName() -> String {
        let lan_name:String = (self.checkCurrentlanguageEnglishOrNot() == true ? "en" : "ar")
        return lan_name
    }
    
    // Get Current Language Storyboard Name
    func getCurrentLanguageStoryboard() -> UIStoryboard {
        if let Name:String =  UserDefaults.standard.value(forKey: "CURRENT_LANGUAGE") as? String {
            if Name == "en" {
                let Storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                return Storyboard
            }
            else{
                let Storyboard: UIStoryboard = UIStoryboard(name: "Main_Arabic", bundle: nil)
                return Storyboard
            }
        }
        else {
            let Storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            return Storyboard
        }
    }
    // For Check Current Language English Or Not
    func checkCurrentlanguageEnglishOrNot() -> Bool {
        if let Name:String =  UserDefaults.standard.value(forKey: "CURRENT_LANGUAGE") as? String {
            if Name == "en" {
                return true
            }
            else{
                return false
            }
        }
        else {
            return true
        }
    }
    
    // For Set ClassName & ID
    func setClass(Name:String, ID:String) {
        ClassName = Name;
        ClassID = ID;
    }
    // For Get ClassName & ID
    func getClass() -> selectedClassData {
        return selectedClassData(ClassName: ClassName, ClassID: ClassID)
    }
    struct selectedClassData {
        var ClassName:String = ""
        var ClassID:String = ""
    }
    
    // For Set UserData
    func setUserData(data:NSMutableDictionary) {
        var Dic:NSMutableDictionary = NSMutableDictionary()
        Dic = data.mutableCopy() as! NSMutableDictionary
        
        for item in Dic {
            if item.value is NSNull {
                Dic.setValue("", forKey: item.key as! String)
            }
        }
        
        UserDefaults.standard.setValue(Dic, forKey: "USER_DATA")
    }
    // For Get UserData
    func getUserData(key:String) -> String {
        if let Dic:NSMutableDictionary =  UserDefaults.standard.value(forKey: "USER_DATA") as? NSMutableDictionary {
            if Dic.value(forKey: key) as? String != nil {
                let value:String = Dic.value(forKey: key) as! String
                if !value.isEmpty {
                    return value;
                }
                else{
                    return ""
                }
            }
            else{
                return ""
            }
        }
        else {
            return ""
        }
    }
    // For Get Class & Child Into UserData
    func getDataIntoUserData(key:String) -> NSArray {
        if let Dic:NSMutableDictionary =  UserDefaults.standard.value(forKey: "USER_DATA") as? NSMutableDictionary {
            if Dic.value(forKey: key) as? NSArray != nil {
                let value:NSArray = Dic.value(forKey: key) as! NSArray
                return value;
            }
            else{
                return []
            }
        }
        else {
            return []
        }
    }
    
    // For Set IphoneData
    func setIphoneData(data:NSMutableDictionary) {
        var Dic:NSMutableDictionary = NSMutableDictionary()
        
        if let temp:NSMutableDictionary =  UserDefaults.standard.value(forKey: "IPHONE_DATA") as? NSMutableDictionary {
            Dic = temp.mutableCopy() as! NSMutableDictionary
        }
        
        for item in data {
            Dic.setValue(item.value, forKey: item.key as! String)
        }
        
        for item in Dic {
            if item.value is NSNull {
                Dic.setValue("", forKey: item.key as! String)
            }
        }
        
        UserDefaults.standard.setValue(Dic, forKey: "IPHONE_DATA")
    }
    // For Get IphoneData
    func getIphoneData(key:String) -> String {
        if let Dic:NSMutableDictionary =  UserDefaults.standard.value(forKey: "IPHONE_DATA") as? NSMutableDictionary {
            if Dic.value(forKey: key) as? String != nil {
                let value:String = Dic.value(forKey: key) as! String
                if !value.isEmpty {
                    return value;
                }
                else{
                    return ""
                }
            }
            else{
                return ""
            }
        }
        else {
            return ""
        }
    }
    
    // For Set SliderData
    func setSliderData(data:NSMutableDictionary) {
        var Dic:NSMutableDictionary = NSMutableDictionary()
        
        if let temp:NSMutableDictionary =  UserDefaults.standard.value(forKey: "SLIDER_DATA") as? NSMutableDictionary {
            Dic = temp.mutableCopy() as! NSMutableDictionary
        }
        
        for item in data {
            Dic.setValue(item.value, forKey: item.key as! String)
        }
        
        for item in Dic {
            if item.value is NSNull {
                Dic.setValue("", forKey: item.key as! String)
            }
        }
        
        UserDefaults.standard.setValue(Dic, forKey: "SLIDER_DATA")
    }
    // For Get SliderData
    func getSliderData(key:String) -> String {
        if let Dic:NSMutableDictionary =  UserDefaults.standard.value(forKey: "SLIDER_DATA") as? NSMutableDictionary {
            if Dic.value(forKey: key) as? String != nil {
                let value:String = Dic.value(forKey: key) as! String
                if !value.isEmpty {
                    return value;
                }
                else{
                    return ""
                }
            }
            else{
                return ""
            }
        }
        else {
            return ""
        }
    }
    
    // For Set Shadow To All Control
    func setShadow(obj:Any, cornurRadius:CGFloat, ClipToBound:Bool, masksToBounds:Bool, shadowColor:String, shadowOpacity:Float, shadowOffset:CGSize, shadowRadius:CGFloat, shouldRasterize:Bool, shadowPath:CGRect) {
        if obj is UIView {
            let tempView:UIView = obj as! UIView
            tempView.clipsToBounds = ClipToBound
            tempView.layer.cornerRadius = cornurRadius
            tempView.layer.shadowOffset = shadowOffset
            tempView.layer.shadowOpacity = shadowOpacity
            tempView.layer.shadowRadius = shadowRadius
            tempView.layer.shadowColor = self.getColorIntoHex(Hex: shadowColor).cgColor
            tempView.layer.masksToBounds =  masksToBounds
            tempView.layer.shouldRasterize = shouldRasterize
            tempView.layer.shadowPath = UIBezierPath(roundedRect: tempView.bounds, cornerRadius: cornurRadius).cgPath
        }
    }
    
    // For Set CornurRadius To All Control
    func setCornurRadius(obj:Any, cornurRadius:CGFloat, isClipToBound:Bool, borderColor:String, borderWidth:CGFloat) {
        if obj is UILabel {
            let tempLabel:UILabel = obj as! UILabel
            tempLabel.layer.cornerRadius = cornurRadius
            tempLabel.clipsToBounds = isClipToBound
            tempLabel.layer.borderColor = self.getColorIntoHex(Hex: borderColor).cgColor
            tempLabel.layer.borderWidth = borderWidth
        }
        if obj is UITextField {
            let tempTextField:UITextField = obj as! UITextField
            tempTextField.layer.cornerRadius = cornurRadius
            tempTextField.clipsToBounds = isClipToBound
            tempTextField.layer.borderColor = self.getColorIntoHex(Hex: borderColor).cgColor
            tempTextField.layer.borderWidth = borderWidth
        }
        if obj is UIButton {
            let tempButton:UIButton = obj as! UIButton
            tempButton.layer.cornerRadius = cornurRadius
            tempButton.clipsToBounds = isClipToBound
            tempButton.layer.borderColor = self.getColorIntoHex(Hex: borderColor).cgColor
            tempButton.layer.borderWidth = borderWidth
        }
        if obj is UITextView {
            let tempTextView:UITextView = obj as! UITextView
            tempTextView.layer.cornerRadius = cornurRadius
            tempTextView.clipsToBounds = isClipToBound
            tempTextView.layer.borderColor = self.getColorIntoHex(Hex: borderColor).cgColor
            tempTextView.layer.borderWidth = borderWidth
        }
        if obj is UIView {
            let tempView:UIView = obj as! UIView
            tempView.layer.cornerRadius = cornurRadius
            tempView.clipsToBounds = isClipToBound
            tempView.layer.borderColor = self.getColorIntoHex(Hex: borderColor).cgColor
            tempView.layer.borderWidth = borderWidth
        }
    }
    
    // For Set Same CornurRadius To All Control
    func setCornurRadiusToAllControls(allObj:[Any], cornurRadius:CGFloat, isClipToBound:Bool, borderColor:String, borderWidth:CGFloat) {
        for item in allObj {
            self.setCornurRadius(obj: item, cornurRadius: cornurRadius, isClipToBound: isClipToBound, borderColor: borderColor, borderWidth: borderWidth)
        }
    }
    
    // For Set PlaceHolderColor To TextField
    func setPlaceHolderColorToTextField(obj:UITextField,color:String) {
        obj.attributedPlaceholder = NSAttributedString(string:obj.placeholder!, attributes: [NSForegroundColorAttributeName:self.getColorIntoHex(Hex:color)])
    }
    // For Set PlaceHolderColorS To All TextFields
    func setPlaceHolderColorsToAllTextFields(allObj:[UITextField],color:String) {
        for item in allObj {
            self.setPlaceHolderColorToTextField(obj: item, color: color)
        }
    }
    
    // For Set Capital First Latter
    func setCapitalFirstLatter(word:String) -> String {
        if !word.isEmpty {
            let temp_Word:NSString = word as NSString
            let First_Char:NSString = (temp_Word.substring(to: 1) as NSString).uppercased as NSString
            let New_Upper_String:String = (First_Char as String) + ((temp_Word.substring(from: 1) as NSString) as String)
            return New_Upper_String
        }
        else {
            return ""
        }
    }
    
    //Set Pending ViewController
    func setPendingVC(name:String, ProductId:String) {
        VCname = name
        PassProductId = ProductId
    }
    //Get Pending ViewController
    func getPendingVC() -> getPendingVCData {
        let temp = getPendingVCData.init(name: VCname, ProductId: PassProductId)
        return temp
    }
    //Remove Pending ViewController
    func removePendingVC() {
        VCname = ""
        PassProductId = ""
    }
    
    struct getPendingVCData {
        var name:String = VCname
        var ProductId:String = PassProductId
    }
    
    // For Show SVProgressHUD
    func showSVProgressHUD(text:String) {
        if !text.isEmpty {
            SVProgressHUD.show(withStatus: text)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else{
            SVProgressHUD.show(withStatus: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loading"))
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
    }
    
    func dismissSVProgressHUD() {
        SVProgressHUD.dismiss()
    }
    
    func dismissSVProgressHUDWithSuccess(success:String) {
        if !success.isEmpty {
            SVProgressHUD.showSuccess(withStatus: success)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
    
    func dismissSVProgressHUDWithError(error:String) {
        if !error.isEmpty {
            SVProgressHUD.showError(withStatus: error)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
            SVProgressHUD.dismiss(withDelay: 2.0)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
    
    func dismissSVProgressHUDWithAPIError(error:NSError) {
        if error.code == -1009 {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else if error.code == -1004 {
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
}
