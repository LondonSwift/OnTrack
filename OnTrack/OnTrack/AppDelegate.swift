//
//  AppDelegate.swift
//  OnTrack
//
//  Created by Daren David Taylor on 01/09/2015.
//  Copyright (c) 2015 LondonSwift. All rights reserved.
//

import UIKit
import LSRepeater

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func setupDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("file") == nil {
            defaults.setObject("local.gpx", forKey:"file");
            defaults.synchronize();
        }
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        self.setupDefaults()
        let data = NSData(contentsOfURL: url)
        data?.writeToURL(NSURL.applicationDocumentsDirectory().URLByAppendingPathComponent("local.gpx"), atomically: true)
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
     
        return true
    }
}

