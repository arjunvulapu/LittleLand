//
//  AppDelegate.swift
//  LittleLand
//
//  Created by Lead on 20/07/17.
//  Copyright © 2017 Lead. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //MARK:- LifeCycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var isRundidFinishLaunching = true
        if let Remote = launchOptions {
            if Remote[UIApplicationLaunchOptionsKey.remoteNotification] != nil {
                isRundidFinishLaunching = false
            }
        }
        IQKeyboardManager.shared.enable = true

        self.setPushNotification()
        self.APIWords()
        
        if !ApiUtillity.sharedInstance.getUserData(key: "uid").isEmpty {
            let VC:TeacherPostVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "TeacherPostVC") as! TeacherPostVC
            let Nav:UINavigationController = UINavigationController(rootViewController: VC)
            window?.rootViewController = Nav
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
       
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK:- PushNotification
    func setPushNotification() {
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            UIApplication.shared.registerForRemoteNotifications()
        }
        // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        let param:NSMutableDictionary = NSMutableDictionary()
        param.setValue(UIDevice.current.identifierForVendor!.uuidString, forKey: "UDID")
        ApiUtillity.sharedInstance.setIphoneData(data: param)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("APNs device token: \(deviceTokenString)")
        
        let param:NSMutableDictionary = NSMutableDictionary()
        param.setValue(deviceTokenString, forKey: "PUSH_TOKEN")
        ApiUtillity.sharedInstance.setIphoneData(data: param)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
        
        let param:NSMutableDictionary = NSMutableDictionary()
        param.setValue("NA", forKey: "PUSH_TOKEN")
        ApiUtillity.sharedInstance.setIphoneData(data: param)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        print("Push notification received: \(data)")
        if ApiUtillity.sharedInstance.getUserData(key: "uid").isEmpty {
            let vc:HomeVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            let Nav:UINavigationController = UINavigationController(rootViewController: vc)
            Nav.isNavigationBarHidden = true
            window?.rootViewController = Nav
        }
        else {
            let aps:NSDictionary = data[AnyHashable("aps")] as! NSDictionary
            if (aps["data"] as! NSDictionary).value(forKey: "msg_type") as! String == "direct_message" {
                let vc:ChatVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                vc.isOpenSideMenu = true
                vc.to_ID = (((aps["data"] as! NSDictionary).value(forKey: "from_uid")) is Int ? "\(((aps["data"] as! NSDictionary).value(forKey: "from_uid") as! Int))" : ((aps["data"] as! NSDictionary).value(forKey: "from_uid") as! String))
                vc.selectedNameOfTeachersNParents = ((aps["data"] as! NSDictionary).value(forKey: "msg_title") as! String)
                let Nav:UINavigationController = UINavigationController(rootViewController: vc)
                Nav.isNavigationBarHidden = true
                window?.rootViewController = Nav
            }
            else if (aps["data"] as! NSDictionary).value(forKey: "msg_type") as! String == "post" {
                let vc:ViewPostDetailsVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "ViewPostDetailsVC") as! ViewPostDetailsVC
                vc.isOpenSideMenu = true
                vc.postID = ((aps["data"] as! NSDictionary).value(forKey: "ref_id") as! String)
                let Nav:UINavigationController = UINavigationController(rootViewController: vc)
                Nav.isNavigationBarHidden = true
                window?.rootViewController = Nav
            }
            else if (aps["data"] as! NSDictionary).value(forKey: "msg_type") as! String == "attendance" {
                let vc:NotificationVC = ApiUtillity.sharedInstance.getCurrentLanguageStoryboard().instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                vc.isOpenSideMenu = true
                let Nav:UINavigationController = UINavigationController(rootViewController: vc)
                Nav.isNavigationBarHidden = true
                window?.rootViewController = Nav
            }
        }
    }
    
    //MARK:- Get Language Data
    func APIWords() {
        Alamofire.request(ApiUtillity.sharedInstance.API(Join: "words.php"), method: .post, parameters: nil, encoding: URLEncoding.default).responseJSON { response in
            debugPrint(response)
            if let json = response.result.value {
                print("JSON: \(json)")
                let dict : NSDictionary = (json as? NSDictionary)!
                
                if (dict.value(forKey: "en") != nil) {
                    ApiUtillity.sharedInstance.setLanguageData(data: dict.mutableCopy() as! NSMutableDictionary)
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
    
}

