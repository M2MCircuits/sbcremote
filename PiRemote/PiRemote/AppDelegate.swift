//
//  AppDelegate.swift
//  PiRemote
//
//  Authors: Hunter Heard, Josh Binkley
//  Copyright (c) 2016 JLL Consulting. All rights reserved.
//

//To Do list:

//Register for notifications
//work out how to get weaved, webiopi, or the Raspberry Pi to send notifications
//get asynchronous requests working
//get the Activity Indicator working with those

//Top
//Figure out sending/receiving webiopi requests
//Figure out how to tie those to the switches
//figure out where to put the requests

//figure out how to save app settings
//Figure out how to create a structure of app settings
//Figure out how to save it, or send it to the raspberry pi
//Figure out how to retrieve those settings, or load them

import UIKit

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var accountOnRecord : Bool = false;
    
    var window: UIWindow?
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
    let DEVICE_IS_SIMULATOR = true
    var tokenString: String? = "enter device id"
    #else
    let DEVICE_IS_SIMULATOR = false
    var tokenString : String? = nil

    #endif
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Loads up saved user profule from NSUserDefaults
        self.accountOnRecord = MainUser.sharedInstance.loadSaved()
        
        //If no account, we continue normal initilization
        guard self.accountOnRecord == true else{
            print("User's first time")
            return true
        }

        // We get phone token everytime user starts up per Apple's official documentation guideline
        registerForPushNotifications(application)

        
        // If token string is nil then continue intialization
        guard self.tokenString != nil else{
            // If no token string, just continue on with app initialization
            return true
        }

        
        let previousToken = MainUser.sharedInstance.phone_token
        if previousToken == nil{
            print("Previous token is empty")
        }
        
        //If the new token is different or there previously was no phone token, update user, and send it to app engine/
        if previousToken == nil || previousToken != tokenString{
        
            MainUser.sharedInstance.phone_token = tokenString
            MainUser.sharedInstance.saveUser()
            self.registerTokenWithAppEngine(completion: { (sucess) in
                guard sucess == true else{
                    print("Failed to update token with app engine")
                    return
                }
                    
                print("Token registered with app engine")
                DispatchQueue.main.async{
                    self.loadDevicesView()
                    }
                })
            return true
                
        }else{
            // The tokens are the same. Continue on as usual
            print("Token has not changed. Continuing initialization")
            self.loadDevicesView()
            return true
            }
        
        
    }
    
    
    func loadDevicesView(){
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let devicesVC = storyboard.instantiateViewController(withIdentifier: "DEVICE_TABLE") as! DevicesTableViewController
        let nav = storyboard.instantiateViewController(withIdentifier: "MAIN_NAV") as! UINavigationController
        devicesVC.initialLogin = false
        //Sets devicesVC as rootvc
        nav.pushViewController(devicesVC, animated: true)
        //sets new navigation as system rootvc
        self.window?.rootViewController = nav
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This occur for certain types of 
        // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the 
        // application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should
        // use this method to pause the game.
    }

    func registerTokenWithAppEngine(completion: @escaping (_ sucess: Bool)->Void){
        let appManager = AppEngineManager()
        appManager.registerPhoneToken(phoneToken: self.tokenString!) { (sucess) in
            completion(sucess)
        }
        
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application
        // state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of 
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the
        // changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If 
        // the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. 
        // See also applicationDidEnterBackground:.
    }
    
    //register for push notifications when app starts
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(
            types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }

    //if the user chose to allow notifications, enable remote notifications for pi
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }

    //get the device token if the user allowed notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.tokenString = deviceTokenString
        print("Device Token: " + deviceTokenString)
        
    }

    //otherwise display an error
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        sleep(4)
    }
}
