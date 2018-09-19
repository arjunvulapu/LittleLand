//
//  ViewPostDetailsVC.swift
//  LittleLand
//
//  Created by Lead on 21/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import Alamofire

class ViewPostDetailsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var lbl_ClassName: UILabel!
    @IBOutlet weak var imageview_Back: UIImageView!
    
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Date: UILabel!
    
    @IBOutlet weak var imageview_Post: UIImageView!
    
    @IBOutlet weak var lbl_Post_Heder: UILabel!
    @IBOutlet weak var lbl_Post_Description: UILabel!
    
    @IBOutlet weak var collectionview_PostDetail: UICollectionView!
    @IBOutlet weak var view_Left_Arrow: UIView!
    @IBOutlet weak var view_Right_Arrow: UIView!
    
    @IBOutlet weak var btn_Opinion: UIButton!
    
    
    //MARK:- Variable Declarations
    var postID:String = String()
    var formatter:DateFormatter = DateFormatter()
    var imageScrollIndex:Int = 0
    var imageArray:NSMutableArray = NSMutableArray()
    var isOpenSideMenu:Bool = false
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For Collectionview Layout
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.size.width-20, height: UIScreen.main.bounds.size.height-218)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        collectionview_PostDetail.collectionViewLayout = layout
        
        self.view_Left_Arrow.isHidden = true
        self.view_Right_Arrow.isHidden = true
        
        ApiUtillity.sharedInstance.setCornurRadius(obj: imageview_Post, cornurRadius: 10, isClipToBound: true, borderColor: "A282BC", borderWidth: 5)
        ApiUtillity.sharedInstance.setCornurRadius(obj: collectionview_PostDetail, cornurRadius: 10, isClipToBound: true, borderColor: "A282BC", borderWidth: 5)
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_view_post").uppercased())
        lbl_ClassName.text = "\((ApiUtillity.sharedInstance.getLanguageData(key: "lbl_class")).uppercased()) - \(ApiUtillity.sharedInstance.getClass().ClassName)".uppercased()
        self.getDetailsOfPost()
        
        if isOpenSideMenu == true {
            imageview_Back.image = UIImage(named: "ic_menu")
        }
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
    
    @IBAction func btn_Handler_Left(_ sender: Any) {
        if imageArray.count <= 0 {
            return
        }
        if imageScrollIndex == 0 {
            return
        }
        if imageScrollIndex == 1 {
            self.view_Left_Arrow.alpha = 0.3
        }
        self.view_Right_Arrow.alpha = 1
        
        imageScrollIndex-=1
        collectionview_PostDetail.scrollToItem(at: IndexPath(row: imageScrollIndex, section: 0), at: .left, animated: true)
    }
    
    @IBAction func btn_Handler_Right(_ sender: Any) {
        if imageArray.count <= 0 {
            return
        }
        if imageScrollIndex == imageArray.count-1 {
            return
        }
        if imageScrollIndex == imageArray.count-2 {
            self.view_Right_Arrow.alpha = 0.3
        }
        self.view_Left_Arrow.alpha = 1
        
        imageScrollIndex+=1
        collectionview_PostDetail.scrollToItem(at: IndexPath(row: imageScrollIndex, section: 0), at: .left, animated: true)
    }
    
    @IBAction func btn_Handler_Opinion(_ sender: Any) {
        if ApiUtillity.sharedInstance.getLoginType() == "teacher" {
            let vc:ViewAllOpinionVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewAllOpinionVC") as! ViewAllOpinionVC
            vc.postID = postID
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc:MyOpinionVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MyOpinionVC") as! MyOpinionVC
            vc.postID = postID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    

    //MARK:- All Method
    func getDetailsOfPost() {
        let params = ["uid":ApiUtillity.sharedInstance.getUserData(key: "uid"), "post_id":postID, "action":"get_post_details", "lan":ApiUtillity.sharedInstance.getCurrentLanguageName()] as [String : Any]
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "post_cms.php"), method: .post, parameters: params, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict:NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "success") != nil) {
                    let success:NSMutableDictionary = (dict.value(forKey: "success") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                    
                    self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let tempDate:Date = self.formatter.date(from: success.value(forKey: "stamp") as! String)!
                    self.formatter.dateFormat = "hh:mm a"
                    self.lbl_Time.text = self.formatter.string(from: tempDate)
                    self.formatter.dateFormat = "dd-MM-yyyy"
                    self.lbl_Date.text = self.formatter.string(from: tempDate)
                    
                    self.lbl_Heder.text = (success.value(forKey: "title") as! String).uppercased()
                    self.lbl_Post_Heder.text = (success.value(forKey: "title") as! String)
                    self.lbl_Post_Description.text = (success.value(forKey: "body") as! String)
                    
                    if (success.value(forKey: "is_opinion") as! String) == "1" {
                        self.btn_Opinion.setTitle((ApiUtillity.sharedInstance.getLoginType() == "teacher" ? (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_viewall_opinion")) : (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_my_opinion"))), for: .normal)
                        self.btn_Opinion.isHidden = false
                    }
                    
                    self.imageArray = (success.value(forKey: "media") as! NSArray).mutableCopy() as! NSMutableArray
                    if self.imageArray.count > 1 {
                        self.view_Left_Arrow.isHidden = false
                        self.view_Right_Arrow.isHidden = false
                        self.view_Left_Arrow.alpha = 0.3
                    }
                    self.collectionview_PostDetail.reloadData()
                    
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
    
    
    //MARK:- CollectionView Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:UICollectionViewCell = collectionview_PostDetail.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.clipsToBounds = true;
        
        let imageView_Post:UIImageView = cell.viewWithTag(1) as! UIImageView
        let view_Video:UIView = cell.viewWithTag(2)!
        
        if ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "media_type") as! String) == "image" {
            imageView_Post.kf.indicatorType = .activity
            imageView_Post.kf.setImage(with: URL(string: ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "path") as! String)))
            
            imageView_Post.isHidden = false
            view_Video.isHidden = true
        }
        else if ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
            //imageView_Post.isHidden = true
            //view_Video.isHidden = false
            
            imageView_Post.kf.indicatorType = .activity
            imageView_Post.kf.setImage(with: URL(string: ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "thumb") as! String)))
            imageView_Post.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));

            imageView_Post.isHidden = false
            view_Video.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "media_type") as! String) == "video" {
            let vc:PlayResourcesVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "PlayResourcesVC") as! PlayResourcesVC
            vc.resource_Name = "video"
            vc.video_Url = ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "path") as! String)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            var images = [SKPhoto]()
            var currentIndex:Int = 0
            var i:Int = 0
            for item in imageArray {
                if ((item as! NSDictionary).value(forKey: "media_type") as! String) == "image" {
                    if ((item as! NSDictionary).value(forKey: "path") as! String) == ((imageArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "path") as! String) {
                        currentIndex = i
                    }
                    let photo = SKPhoto.photoWithImageURL(((item as! NSDictionary).value(forKey: "path") as! String))
                    photo.shouldCachePhotoURLImage = true
                    images.append(photo)
                    i += 1
                }
            }
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(currentIndex)
            present(browser, animated: true, completion: {})
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionview_PostDetail {
            let visibleCellsArray = collectionview_PostDetail.visibleCells
            imageScrollIndex = (collectionview_PostDetail.indexPath(for: visibleCellsArray[0])?.row)!
            self.view_Left_Arrow.alpha = 1.0
            self.view_Right_Arrow.alpha = 1.0
            if imageScrollIndex == 0 {
                self.view_Left_Arrow.alpha = 0.3
            }
            else if imageScrollIndex == imageArray.count-1 {
                self.view_Right_Arrow.alpha = 0.3
            }
        }
    }
    
}
