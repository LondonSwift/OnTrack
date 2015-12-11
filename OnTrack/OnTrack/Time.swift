//
//  Time.swift
//  OnTrack
//
//  Created by Daren David Taylor on 09/12/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import UIKit
import AVFoundation


class Time {
    func sayTime(synth: AVSpeechSynthesizer) {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
        let dateString = formatter.stringFromDate(NSDate())
        
        
        let myUtterance = AVSpeechUtterance(string:"Its the \(dateString)")
        synth.speakUtterance(myUtterance)
        
        
    }
}