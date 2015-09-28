//
//  NSURL+applicationDocumentsDirectory.swift
//  OnTrack
//
//  Created by Daren David Taylor on 27/09/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import Foundation

extension NSURL {
    
    class func applicationDocumentsDirectory() -> NSURL! {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last
    }
    
}
  