//
//  Weather.swift
//  OnTrack
//
//  Created by Daren David Taylor on 09/12/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//


import UIKit
import MapKit
import AudioToolbox
import LSRepeater
import AVFoundation


class Weather {
    
    
    func sayWeather(location: CLLocation, synth: AVSpeechSynthesizer) {
        let path = String(format: "http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&APPID=6b0294939a60fdcbaebf05afff30f47f", Float(location.coordinate.latitude), Float(location.coordinate.longitude))
        let getWeatherTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: path)!) { (data, response, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let data = data, resultDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String:AnyObject], weatherArray = resultDictionary["weather"] as? [[String:AnyObject]] {
                    
                    if let weatherDictionary = weatherArray.last {
                        
                        
                        if let tempratureDictionary = resultDictionary["main"] as? [String : AnyObject] {
                            
                            let temp = Double(tempratureDictionary["temp"] as! Int)
                            let temperature :String = String(format: "%.f°C", (temp - 273.15))
                            
                            let myUtterance = AVSpeechUtterance(string:"The temprature is: \(temperature)")
                            synth.speakUtterance(myUtterance)
                            
                        }
                        
                        
                        if let weather = weatherDictionary["main"] as? String {
                            
                            let myUtterance = AVSpeechUtterance(string:"The Weather conditions are: \(weather)")
                            synth.speakUtterance(myUtterance)
                       
                        
                        
                        }
                    }
                }
            })
        }
        getWeatherTask.resume()
    }
    
}