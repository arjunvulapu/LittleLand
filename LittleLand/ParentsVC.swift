//
//  ParentsVC.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class ParentsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionview_Parents: UICollectionView!
    
    var XibName:String = "ParentsCell"
    var Radius:CGFloat = 10
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For Collectionview Layout
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionview_Parents.frame.size.width-80, height: collectionview_Parents.frame.size.height)
        layout.minimumLineSpacing = 80
        layout.minimumInteritemSpacing = 80
        layout.sectionInset = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40)
        layout.scrollDirection = .horizontal
        collectionview_Parents.collectionViewLayout = layout
        
        // For Size
        if UIScreen.main.bounds.size.width == 375 {
            XibName = "ParentsCell@2x"
            Radius = 11
        }
        else if UIScreen.main.bounds.size.width == 414 {
            XibName = "ParentsCell@3x"
            Radius = 12
        }
        
        // For Register Class & Nib
        collectionview_Parents.register(ParentsCell.self, forCellWithReuseIdentifier: "ParentsCell")
        collectionview_Parents.register(UINib(nibName: XibName, bundle: nil), forCellWithReuseIdentifier: "ParentsCell")
        
        ApiUtillity.sharedInstance.openSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
    }
    
    @IBAction func btn_Handler_Alarm(_ sender: Any) {
        
    }
    
    @IBAction func btn_Handler_ViewCalender(_ sender: Any) {
        let vc:MonthlyCalendarVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "MonthlyCalendarVC") as! MonthlyCalendarVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Handler_AttendanceReports(_ sender: Any) {
        let vc:ParentsAttendanceVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ParentsAttendanceVC") as! ParentsAttendanceVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Handler_DirectMessage(_ sender: Any) {
        
    }
    
    
    //MARK:- All Method
    
    
    //MARK:- CollectionView Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ParentsCell = collectionview_Parents.dequeueReusableCell(withReuseIdentifier: "ParentsCell", for: indexPath) as! ParentsCell
        ApiUtillity.sharedInstance.setCornurRadius(obj: cell.btn_ViewMore, cornurRadius: Radius, isClipToBound: true, borderColor: "9D7CB7", borderWidth: 2.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc:ViewPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostVC") as! ViewPostVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
