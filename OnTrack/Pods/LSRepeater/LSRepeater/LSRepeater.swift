//
//  LSRepeater.swift
//  LSRepeater
//
//  Created by Daren David Taylor on 27/09/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import Foundation

public typealias LSRepeatClosure = () -> Void

// we need to subclass NSObject, as NSTimer uses the runtime for method invocation
public class LSRepeater: NSObject {
    
    var timer:NSTimer!
    var execute:LSRepeatClosure!
    
    public class func repeater(interval:NSTimeInterval, execute: LSRepeatClosure) -> LSRepeater {
        
        let repeater = LSRepeater()
        repeater.execute = execute
        
        repeater.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target:repeater, selector: Selector("timerDidFire"), userInfo: nil, repeats: true)
        
        repeater.timerDidFire()
        
        return repeater
    }
    
    public func invalidate()
    {
        self.timer.invalidate()
    }
    
    func timerDidFire() {
        self.execute()
    }
    
}
