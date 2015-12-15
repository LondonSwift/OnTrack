//
//  LocationSpoofer.swift
//  OnTrack
//
//  Created by Daren David Taylor on 14/12/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import UIKit
import MapKit
import AudioToolbox
import LSRepeater
import AVFoundation

protocol LocationSpooferDelegate {
    func locationSpoofer(spoofer:LocationSpoofer, location:CLLocation)
}

class LocationSpoofer {
    
    var delegate: LocationSpooferDelegate?
    
    var position = 0
    
    var locationArray:Array<LocationAndRelativeTime>?
    
    var replayIndex = 0
    
    
    func load (gpxPath: String) {
        
        
        let url = NSURL.applicationBundleDirectory().URLByAppendingPathComponent(gpxPath)
        
        self.locationArray = Array<LocationAndRelativeTime>()
        
        var lastTime:NSDate?
        var timeDiff:Double?
        
        if let root = GPXParser.parseGPXAtURL(url) {
            
            if let tracks = root.tracks {
                for track in tracks as! [GPXTrack] {
                    
                    for trackSegment in track.tracksegments as! [GPXTrackSegment] {
                        for trackPoint in  trackSegment.trackpoints as! [GPXTrackPoint] {
                            let location = CLLocation(latitude: CLLocationDegrees(trackPoint.latitude), longitude: CLLocationDegrees(trackPoint.longitude))
                            
                            if let lastTime = lastTime {
                                
                                timeDiff = trackPoint.time.timeIntervalSinceDate(lastTime)
                                
                            }
                            else {
                                timeDiff = 0
                            }
                            
                            lastTime = trackPoint.time
                            
                            
                            let locationAndRelativeTime = LocationAndRelativeTime()
                            
                            locationAndRelativeTime.location = location
                            locationAndRelativeTime.relativeTime = timeDiff
                            
                            
                            self.locationArray!.append(locationAndRelativeTime)
                        }
                    }
                }
            }
            
        }
    }
    
    
    
    
    func start(delegate: LocationSpooferDelegate) {
        
        self.delegate = delegate
        
        self.triggerNext()
        
        
    }
    
    func triggerNext() {
        
        if let locationArray = self.locationArray {
            
            if replayIndex < locationArray.count {
                let locationAndRelativeTime = locationArray[self.replayIndex]
                
                if let relativeTime = locationAndRelativeTime.relativeTime {
                    
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(relativeTime * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        
                        if let location = locationAndRelativeTime.location {
                            
                            self.delegate?.locationSpoofer(self, location: location)
                            
                            self.replayIndex++
                            self.triggerNext()
                            
                        }
                    }
                    
                }
            }
            
        }
    }
    
}