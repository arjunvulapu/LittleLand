//
//  FindTeacherORParentsVC.swift
//  LittleLand
//
//  Created by Lead on 24/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class FindTeacherORParentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var searchBar_ParentsNTeacher: UISearchBar!
    @IBOutlet weak var tableview_ParentsNTeacher: UITableView!
    
    
    //MARK:- Variable Declarations
    var selectedNameOfClassNChild:String = String()
    var TeachersNParentsArray:NSMutableArray = NSMutableArray()
    var TeachersNParentsArrayCopy:NSMutableArray = NSMutableArray()
    var TeachersNParentsDic:NSMutableDictionary = NSMutableDictionary()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = selectedNameOfClassNChild
        TeachersNParentsArrayCopy = TeachersNParentsArray.mutableCopy() as! NSMutableArray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Tableview Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TeachersNParentsArray.count <= 0 {
            let noDataLabel:UILabel = UILabel(frame: tableview_ParentsNTeacher.frame)
            noDataLabel.text = ApiUtillity.sharedInstance.getLanguageData(key: "lbl_no_search_result_found")
            noDataLabel.font = UIFont(name: "Lato-Bold", size: 20.0)
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableview_ParentsNTeacher.backgroundView = noDataLabel
        }
        else {
            tableview_ParentsNTeacher.backgroundView = nil
        }
        return TeachersNParentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableview_ParentsNTeacher.dequeueReusableCell(withIdentifier: "cell")!
        
        let name:UILabel = cell.viewWithTag(1) as! UILabel
        name.text = "\(((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "fname") as! String)) \(((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "lname") as! String))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:ChatVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.to_ID = ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String)
        vc.selectedNameOfTeachersNParents = "\(((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "fname") as! String)) \(((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "lname") as! String))"
        vc.selectedProfileOfTeachersNParents = ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "profile_pic") as! String)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK:- SearchBar Method
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var result:String = (searchBar.text! as NSString).replacingCharacters(in: range, with: text)
        result = result.replacingOccurrences(of: "\n", with: "")
        if !result.isEmpty {
            searchBar_ParentsNTeacher.setShowsCancelButton(true, animated: true)
            
            TeachersNParentsArray = NSMutableArray()
            for item in TeachersNParentsArrayCopy {
                let fname:String = (item as! NSDictionary).value(forKey: "fname") as! String
                let lname:String = (item as! NSDictionary).value(forKey: "lname") as! String
                let range_fname:NSRange = (fname as NSString).range(of: result)
                let range_lname:NSRange = (lname as NSString).range(of: result)
                if range_fname.length > 0 || range_lname.length > 0 {
                    TeachersNParentsArray.add(item)
                }
            }
            tableview_ParentsNTeacher.reloadData()
        }
        else {
            searchBar_ParentsNTeacher.setShowsCancelButton(false, animated: true)
            
            TeachersNParentsArray = TeachersNParentsArrayCopy.mutableCopy() as! NSMutableArray
            tableview_ParentsNTeacher.reloadData()
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar_ParentsNTeacher.setShowsCancelButton(false, animated: true)
            
            TeachersNParentsArray = TeachersNParentsArrayCopy.mutableCopy() as! NSMutableArray
            tableview_ParentsNTeacher.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar_ParentsNTeacher.setShowsCancelButton(false, animated: true)
        searchBar_ParentsNTeacher.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar_ParentsNTeacher.setShowsCancelButton(false, animated: true)
        searchBar_ParentsNTeacher.resignFirstResponder()
    }
}
