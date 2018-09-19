//
//  TeacherLoginVC.swift
//  LittleLand
//
//  Created by Lead on 25/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class TeacherLoginVC: UIViewController {
    
    @IBOutlet weak var imageview_Slider: UIImageView!
    
    @IBOutlet weak var view_Heder: UIView!
    
    @IBOutlet weak var view_Login_Temp: UIView!
    @IBOutlet weak var view_Login: UIView!
    @IBOutlet weak var imageview_Left: UIImageView!
    @IBOutlet weak var btn_Teachers: UIButton!
    @IBOutlet weak var imageview_Teachers_Layer: UIImageView!
    @IBOutlet weak var imageview_Right: UIImageView!
    
    @IBOutlet weak var txt_TeacherID: UITextField!
    @IBOutlet weak var txt_Password: UITextField!
    @IBOutlet weak var btn_SignIn: UIButton!
    @IBOutlet weak var btn_ForgotPassword: UIButton!
    @IBOutlet weak var btn_ForgotPassword_Desc: UIButton!
    
    
    let teacherPuls:Pulsator = Pulsator()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txt_TeacherID.placeholder = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_teacher_id").uppercased()
        txt_Password.placeholder = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_password").uppercased()
        btn_SignIn.setTitle(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_signin").uppercased(), for: .normal)
        btn_ForgotPassword.setTitle(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_forgot").uppercased(), for: .normal)
        btn_ForgotPassword_Desc.setTitle((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_contact_admin").lowercased())), for: .normal)
        
        // For Set Curve View
        //self.setHederCurve()
        self.setLoginViewCurve()
        
        //txt_TeacherID.text = "teacher"
        //txt_Password.text = "123456"
        if ApiUtillity.sharedInstance.getLoginType() == "parent" {
            //txt_TeacherID.text = "parent"
            btn_Teachers.setImage(UIImage(named: "ic_pareents_login"), for: .normal)
            txt_TeacherID.placeholder = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_parent_id").uppercased()
        }
        
        let textFieldArray:[UITextField] = [txt_TeacherID, txt_Password]
        ApiUtillity.sharedInstance.setPlaceHolderColorsToAllTextFields(allObj: textFieldArray, color: "586160")
        ApiUtillity.sharedInstance.setCornurRadiusToAllControls(allObj: textFieldArray, cornurRadius: 15, isClipToBound: true, borderColor: "DE6855", borderWidth: 1.5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: btn_SignIn, cornurRadius: 15, isClipToBound: true, borderColor: "DE6855", borderWidth: 0)
        
        self.imageview_Slider.kf.indicatorType = .activity
        self.imageview_Slider.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getSliderData(key: "login")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // For Pulsator
        teacherPuls.position = CGPoint(x: imageview_Teachers_Layer.bounds.size.width/2, y: imageview_Teachers_Layer.bounds.size.height/2)
        teacherPuls.numPulse = 3
        teacherPuls.radius = 70
        teacherPuls.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        imageview_Teachers_Layer.layer.addSublayer(teacherPuls)
        teacherPuls.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        
    }
    
    @IBAction func btn_handler_Teachers(_ sender: Any) {
        
    }
    
    @IBAction func btn_Handler_SignIn(_ sender: Any) {
        if txt_TeacherID.text!.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.getLoginType() == "parent" ? (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Parents_Id").lowercased())) : (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Teacher_Id").lowercased()))), ForNavigation: self.navigationController!)
            return
        }
        if txt_Password.text!.isEmpty {
            ApiUtillity.sharedInstance.showErrorMessage(Title: (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_error")), SubTitle: (ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "error_Please_Enter_Password").lowercased())), ForNavigation: self.navigationController!)
            return
        }
        
        let params = ["type":ApiUtillity.sharedInstance.getLoginType(), "username":txt_TeacherID.text!, "password":txt_Password.text!, "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: (ApiUtillity.sharedInstance.checkCurrentlanguageEnglishOrNot() == true ? "Log In..." : "تسجيل الدخول..."))
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "login_user.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    // For Set UserData
                    ApiUtillity.sharedInstance.setUserData(data: success.mutableCopy() as! NSMutableDictionary)
                    
                    let vc:TeacherPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherPostVC") as! TeacherPostVC
                    self.navigationController?.pushViewController(vc, animated: true)
                    
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
    
    @IBAction func btn_Handler_ForgotPassword(_ sender: Any) {
        
    }
    
    
    //MARK:- All Method
    func setHederCurve() {
        let HederCurve = UIBezierPath()
        HederCurve.move(to: CGPoint.init(x: 0, y: 64))
        HederCurve.addCurve(to: CGPoint.init(x: self.view.frame.size.width, y: 64), controlPoint1: CGPoint.init(x: (self.view.frame.size.width/3), y: 70), controlPoint2: CGPoint.init(x: (self.view.frame.size.width/3)*2, y: 70))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = HederCurve.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        view_Heder.layer.addSublayer(shapeLayer)
    }
    
    func setLoginViewCurve() {
        // Step One
        let LoginCurve = UIBezierPath()
        LoginCurve.move(to: CGPoint.init(x: 0, y: 0))
        LoginCurve.addCurve(to: CGPoint.init(x: self.view.frame.size.width, y: 0), controlPoint1: CGPoint.init(x: (self.view.frame.size.width/3), y: 55), controlPoint2: CGPoint.init(x: (self.view.frame.size.width/3)*2, y: 55))
        LoginCurve.addLine(to: CGPoint.init(x: self.view.frame.size.width, y: 70))
        LoginCurve.addLine(to: CGPoint.init(x: 0, y: 70))
        LoginCurve.addLine(to: CGPoint.init(x: 0, y: 0))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = LoginCurve.cgPath
        shapeLayer.fillColor = ApiUtillity.sharedInstance.getColorIntoHex(Hex: "B69EC2").cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1.0
        view_Login_Temp.layer.addSublayer(shapeLayer)
        
        // Step Two
        let LoginCurve1 = UIBezierPath()
        LoginCurve1.move(to: CGPoint.init(x: 0, y: 20))
        LoginCurve1.addCurve(to: CGPoint.init(x: self.view.frame.size.width, y: 20), controlPoint1: CGPoint.init(x: (self.view.frame.size.width/3), y: 70), controlPoint2: CGPoint.init(x: (self.view.frame.size.width/3)*2, y: 70))
        LoginCurve1.addLine(to: CGPoint.init(x: self.view.frame.size.width, y: 275))
        LoginCurve1.addLine(to: CGPoint.init(x: 0, y: 275))
        LoginCurve1.addLine(to: CGPoint.init(x: 0, y: 20))
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = LoginCurve1.cgPath
        shapeLayer1.fillColor = UIColor.white.cgColor
        shapeLayer1.strokeColor = UIColor.white.cgColor
        shapeLayer1.lineWidth = 1.0
        view_Login_Temp.layer.addSublayer(shapeLayer1)
    }
    
}
