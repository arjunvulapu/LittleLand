//
//  SelectTeacherORParentsVC.swift
//  LittleLand
//
//  Created by Lead on 22/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

protocol SelectedTeachersORParentsDelegate {
    func getSelectedTeachersORParentsIDandName(ID:String, NAME:String)
}
class SelectTeacherORParentsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var searchBar_ParentsNTeacher: UISearchBar!
    @IBOutlet weak var tableview_ParentsNTeacher: UITableView!
    @IBOutlet weak var lbl_Total_SelectedParentsNTeacher: UILabel!
    @IBOutlet weak var lbl_SelectAll: UILabel!
    @IBOutlet weak var imageview_SelectAll: UIImageView!
    @IBOutlet weak var btn_Clear: UIButton!
    @IBOutlet weak var btn_Done: UIButton!
    
    
    //MARK:- Variable Declarations
    var TeachersNParentsArray:NSMutableArray = NSMutableArray()
    var TeachersNParentsArrayCopy:NSMutableArray = NSMutableArray()
    var TeachersNParentsDic:NSMutableDictionary = NSMutableDictionary()
    
    var isSelectedAll:Bool = false
    var selectedNameOfClassNChild:String = String()
    var delegate:SelectedTeachersORParentsDelegate!
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = selectedNameOfClassNChild
        lbl_SelectAll.text = "\((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_selected_all").lowercased()))):"
        btn_Done.setTitle(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_done"), for: .normal)
        btn_Clear.setTitle(ApiUtillity.sharedInstance.getLanguageData(key: "lbl_clear"), for: .normal)
        
        TeachersNParentsArrayCopy = TeachersNParentsArray.mutableCopy() as! NSMutableArray
        self.isSelectAllTeachersORParents(isSelectAll: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btn_Handler_SelectAll(_ sender: Any) {
        if isSelectedAll == true {
            isSelectedAll = false
            imageview_SelectAll.image = UIImage(named: "ic_checkbox_uncheck")
            
            self.isSelectAllTeachersORParents(isSelectAll: false)
        }
        else {
            isSelectedAll = true
            imageview_SelectAll.image = UIImage(named: "ic_checkbox_check")
            
            self.isSelectAllTeachersORParents(isSelectAll: true)
        }
    }
    @IBAction func btn_Handler_Clear(_ sender: Any) {
        self.isSelectAllTeachersORParents(isSelectAll: false)
    }
    @IBAction func btn_Handler_Done(_ sender: Any) {
        var ID:String = ""
        var NAME:String = ""
        for item in TeachersNParentsArrayCopy {
            if TeachersNParentsDic.value(forKey: ((item as! NSDictionary).value(forKey: "uid") as! String)) as! String == "1" {
                ID = ID.appending("\(((item as! NSDictionary).value(forKey: "uid") as! String)),")
                NAME = NAME.appending("\(((item as! NSDictionary).value(forKey: "fname") as! String)), ")
            }
        }
        if !ID.isEmpty {
            ID = (ID as NSString).substring(to: (ID as NSString).length-1)
            NAME = (NAME as NSString).substring(to: (NAME as NSString).length-2)
        }
        delegate.getSelectedTeachersORParentsIDandName(ID: ID, NAME: NAME)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- All Method
    func isSelectAllTeachersORParents(isSelectAll:Bool) {
        if isSelectAll == true {
            for item in TeachersNParentsArray {
                TeachersNParentsDic.setValue("1", forKey: (item as! NSDictionary).value(forKey: "uid") as! String)
            }
        }
        else {
            for item in TeachersNParentsArray {
                TeachersNParentsDic.setValue("0", forKey: (item as! NSDictionary).value(forKey: "uid") as! String)
            }
        }
        self.isSelectAllTeachersORParents()
        tableview_ParentsNTeacher.reloadData()
    }
    
    func isSelectAllTeachersORParents() {
        var isSelectedAllTeacherORParents:Bool = true
        for item in TeachersNParentsArray {
            if TeachersNParentsDic.value(forKey: ((item as! NSDictionary).value(forKey: "uid") as! String)) as! String == "0" {
                isSelectedAllTeacherORParents = false
            }
        }
        var totalSelectTeacherORParents:Int = 0
        for item in TeachersNParentsDic.allKeys {
            if TeachersNParentsDic.value(forKey: item as! String) as! String == "1" {
                totalSelectTeacherORParents += 1
            }
        }
        lbl_Total_SelectedParentsNTeacher.text = "\((ApiUtillity.sharedInstance.setCapitalFirstLatter(word: ApiUtillity.sharedInstance.getLanguageData(key: "lbl_Select_Parents").lowercased()))) : \(totalSelectTeacherORParents)"
        
        if isSelectedAllTeacherORParents == true {
            isSelectedAll = true
            imageview_SelectAll.image = UIImage(named: "ic_checkbox_check")
        }
        else {
            isSelectedAll = false
            imageview_SelectAll.image = UIImage(named: "ic_checkbox_uncheck")
        }
        
        if TeachersNParentsArray.count <= 0 {
            isSelectedAll = false
            imageview_SelectAll.image = UIImage(named: "ic_checkbox_uncheck")
        }
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
        
        if TeachersNParentsDic.value(forKey: ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String)) as! String == "1" {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if TeachersNParentsDic.value(forKey: ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String)) as! String == "1" {
            TeachersNParentsDic.setValue("0", forKey: ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String))
        }
        else {
            TeachersNParentsDic.setValue("1", forKey: ((TeachersNParentsArray.object(at: indexPath.row) as! NSDictionary).value(forKey: "uid") as! String))
        }
        self.isSelectAllTeachersORParents()
        tableview_ParentsNTeacher.reloadData()
    }
    
    
    //MARK:- SearchBar Method
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let result:String = (searchBar.text! as NSString).replacingCharacters(in: range, with: text)
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
