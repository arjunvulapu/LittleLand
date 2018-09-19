//
//  PlayResourcesVC.swift
//  LittleLand
//
//  Created by Lead on 29/08/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayResourcesVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var lbl_Heder: UILabel!
    
    
    //MARK:- Variable Declarations
    var resource_Name:String = String()
    var video_Url:String = String()
    let playerController = AVPlayerViewController()
    
    
    //MARK:- ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if resource_Name == "video" {
            let player = AVPlayer(url: URL(string: video_Url)!)
            playerController.player = player
            self.present(playerController, animated: false) {
                player.play()
                self.playerController.addObserver(self, forKeyPath: #keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
            }
            //NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:- ButtonAction
    @IBAction func btn_Handler_Back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- All Method
    func playerDidFinishPlaying(note: NSNotification) {
        self.navigationController?.popViewController(animated: false)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.playerController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
        self.navigationController?.popViewController(animated: false)
    }
    
}
