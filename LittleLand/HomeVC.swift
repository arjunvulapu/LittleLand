//
//  HomeVC.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class HomeVC: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {
    
    //MARK:- Outlets
    @IBOutlet weak var view_Pager: FSPagerView!{
        didSet {
            self.view_Pager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.view_Pager.itemSize = .zero
            self.view_Pager.interitemSpacing = 0
        }
    }
    
    @IBOutlet weak var imageview_Slider: UIImageView!
    
    @IBOutlet weak var view_Heder: UIView!
    
    @IBOutlet weak var view_Login_Temp: UIView!
    @IBOutlet weak var view_Login: UIView!
    @IBOutlet weak var imageview_Left: UIImageView!
    
    @IBOutlet weak var btn_Teachers: UIButton!
    @IBOutlet weak var imageview_Teachers_Layer: UIImageView!
    @IBOutlet weak var lbl_Teachers: UILabel!
    @IBOutlet weak var lbl_LoginTeachers: UILabel!
    @IBOutlet weak var btn_Parents: UIButton!
    @IBOutlet weak var imageview_Parents_Layer: UIImageView!
    @IBOutlet weak var lbl_Parents: UILabel!
    @IBOutlet weak var lbl_Login_Parents: UILabel!
    @IBOutlet weak var imageview_Right: UIImageView!
    
    
    //MARK:- Variable Declarations
    let teacherPuls:Pulsator = Pulsator()
    let parentsPuls:Pulsator = Pulsator()
    let sliderArray:NSMutableArray = NSMutableArray()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
//        let alert = UIAlertController(title: "Alert", message: ApiUtillity.sharedInstance.getIphoneData(key: "PUSH_TOKEN"), preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
        self.navigationController?.isNavigationBarHidden = true
        
        if ApiUtillity.sharedInstance.getLanguageData(key: "lbl_teachers").isEmpty {
            self.APIWords()
        }
        
        lbl_Teachers.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_teachers").uppercased()
        lbl_LoginTeachers.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loginhere").uppercased()
        lbl_Parents.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_parents").uppercased()
        lbl_Login_Parents.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loginhere").uppercased()
        
        // For Set Curve View
        //self.setHederCurve()
        self.setLoginViewCurve()
        self.getSliderData()
        
        self.imageview_Slider.kf.indicatorType = .activity
        self.imageview_Slider.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getSliderData(key: "home")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // For Pulsator
        teacherPuls.position = CGPoint(x: imageview_Teachers_Layer.bounds.size.width/2, y: imageview_Teachers_Layer.bounds.size.height/2)
        teacherPuls.numPulse = 3;
        teacherPuls.radius = 70;
        teacherPuls.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        imageview_Teachers_Layer.layer.addSublayer(teacherPuls)
        teacherPuls.start()
        
        parentsPuls.position = CGPoint(x: imageview_Parents_Layer.bounds.size.width/2, y: imageview_Parents_Layer.bounds.size.height/2)
        parentsPuls.numPulse = 3;
        parentsPuls.radius = 70;
        parentsPuls.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0).cgColor
        imageview_Parents_Layer.layer.addSublayer(parentsPuls)
        parentsPuls.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        
    }
    
    @IBAction func btn_handler_Teachers(_ sender: Any) {
        ApiUtillity.sharedInstance.setLoginType(type: "teacher")
        
        let vc:TeacherLoginVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherLoginVC") as! TeacherLoginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_handler_Parents(_ sender: Any) {
        ApiUtillity.sharedInstance.setLoginType(type: "parent")
        
        let vc:TeacherLoginVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherLoginVC") as! TeacherLoginVC
        self.navigationController?.pushViewController(vc, animated: true)
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
        LoginCurve1.addLine(to: CGPoint.init(x: self.view.frame.size.width, y: 155))
        LoginCurve1.addLine(to: CGPoint.init(x: 0, y: 155))
        LoginCurve1.addLine(to: CGPoint.init(x: 0, y: 20))

        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = LoginCurve1.cgPath
        shapeLayer1.fillColor = UIColor.white.cgColor
        shapeLayer1.strokeColor = UIColor.white.cgColor
        shapeLayer1.lineWidth = 1.0
        view_Login_Temp.layer.addSublayer(shapeLayer1)
    }
    
    func getSliderData() {
        let params = ["action":"sliders", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "get_data.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableArray = (dict.value(forKey: "success") as! NSArray).mutableCopy() as! NSMutableArray
                    let Dic:NSMutableDictionary = NSMutableDictionary()
                    for image in success {
                        self.sliderArray.add(((image as! NSDictionary).value(forKey: "photo") as! String))
                        if ((image as! NSDictionary).value(forKey: "type") as! String) == "home" {
                            Dic.setValue(((image as! NSDictionary).value(forKey: "photo") as! String), forKey: "home")
                        }
                        else if ((image as! NSDictionary).value(forKey: "type") as! String) == "login" {
                            Dic.setValue(((image as! NSDictionary).value(forKey: "photo") as! String), forKey: "login")
                        }
                    }
                    //self.view_Pager.reloadData()
                    ApiUtillity.sharedInstance.setSliderData(data: Dic)
                    
                    self.imageview_Slider.kf.indicatorType = .activity
                    self.imageview_Slider.kf.setImage(with: URL(string: ApiUtillity.sharedInstance.getSliderData(key: "home")))
                    
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
    
    func APIWords() {
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "Loading...")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "words.php"), method: .post, parameters: nil, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict : NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "en") != nil) {
                    ApiUtillity.sharedInstance.setLanguageData(data: dict.mutableCopy() as! NSMutableDictionary)
                    
                    // Set Home Data
                    self.lbl_Teachers.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_teachers").uppercased()
                    self.lbl_LoginTeachers.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loginhere").uppercased()
                    self.lbl_Parents.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_parents").uppercased()
                    self.lbl_Login_Parents.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_loginhere").uppercased()
                    
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
    
    
    //MARK:- FSPagerView Method
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return sliderArray.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.kf.indicatorType = .activity
        cell.imageView?.kf.setImage(with: URL(string: sliderArray.object(at: index) as! String))
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        return cell
    }
    
}
