//
//  NSURL+applicationDocumentsDirectory.swift
//  OnTrack
//
//  Created by Daren David Taylor on 27/09/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import Foundation

extension NSURL {
    class func applicationDocumentsDirectory() -> NSURL {
        return NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
    }

    class func applicationBundleDirectory() -> NSURL {
        return NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
    }

}
  