//
//  AppDelegate.swift
//  OnTrack
//
//  Created by Daren David Taylor on 01/09/2015.
//  Copyright (c) 2015 LondonSwift. All rights reserved.
//

import UIKit
import LSRepeater
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func setupDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey("file") == nil {
            defaults.setObject("Peak200.gpx", forKey:"file");
            defaults.synchronize();
        }
      
        if defaults.objectForKey("OffTrackAudioOn") == nil {
            defaults.setBool(false, forKey:"OffTrackAudioOn");
            defaults.synchronize();
        }

        if defaults.objectForKey("OffTrackDistance") == nil {
            defaults.setDouble(10.0, forKey:"OffTrackDistance");
            defaults.synchronize();
        }
        
        if defaults.objectForKey("hasCopiedFiles") == nil {
            defaults.setBool(true, forKey:"hasCopiedFiles");
            defaults.synchronize();
            
            self.copyFiles()
        }
    }
    
    func copyFiles() {
        
        let fileManager = NSFileManager.defaultManager()
        
        do {
            
            for path in ["BrenigLoop", "Peak200", "PennineBridlewayDouble", "PennineBridlewayComplete","TheRidgeway"] {
                
                if let fullSourcePath = NSBundle.mainBundle().pathForResource(path, ofType:"gpx") {
                
                if fileManager.fileExistsAtPath(fullSourcePath) {
                    
                    try fileManager.copyItemAtPath(fullSourcePath, toPath: NSURL.applicationDocumentsDirectory().URLByAppendingPathComponent(path+".gpx").path!)
                }
                }
            }
            
        }
        catch {
            print("error copying")
        }
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        self.setupDefaults()
        let data = NSData(contentsOfURL: url)
        
        if let path = url.lastPathComponent {
            
            data?.writeToURL(NSURL.applicationDocumentsDirectory().URLByAppendingPathComponent(path), atomically: true)
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(path, forKey:"file");
            defaults.synchronize();
            
            let vc = self.window?.rootViewController as! MapViewController
            vc.loadRoute(path)
        }
        
        
        

        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Crashlytics.self()])

        self.setupDefaults()

        return true
    }
}

