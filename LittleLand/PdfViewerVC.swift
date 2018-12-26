//
//  AboutUsVC.swift
//  LittleLand
//
//  Created by Lead on 25/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit

class PdfViewerVC: UIViewController, UIWebViewDelegate {

    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    @IBOutlet weak var webview_AboutUs: UIWebView!
    var pdfUrl:String = ""
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Heder.text = (ApiUtillity.sharedInstance.getLanguageData(key: "lbl_file_viewer").uppercased())
        ApiUtillity.sharedInstance.showSVProgressHUD(text: "")
        DispatchQueue.main.async {
            self.webview_AboutUs.loadRequest(URLRequest(url: URL(string: self.pdfUrl)!))

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_SideMenu(_ sender: Any) {
//        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MFSidemenu_Open"), object: nil)
        self.navigationController?.popViewController(animated: true);
    }
    
    
    //MARK:- WebView Method
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ApiUtillity.sharedInstance.dismissSVProgressHUD()
    }
    
}
