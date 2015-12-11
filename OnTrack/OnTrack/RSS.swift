//
//  RSS.swift
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


class RSS : NSObject, NSXMLParserDelegate {
    
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    
    
    func sayRSS(path: String, synth: AVSpeechSynthesizer) {
        
        self.beginParsing(path, synth: synth)
        
        return
        
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
    
    
    
    func beginParsing(path: String, synth: AVSpeechSynthesizer)
    {
        self.posts = []
        self.parser = NSXMLParser(contentsOfURL:(NSURL(string:path))!)!
        self.parser.delegate = self
        self.parser.parse()
        
        print(elements["title"])
        
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.systemLocale()
        //   formatter.dateFormat:inFormat];
        
        formatter.dateFormat = "yyyy-dd-MM HH:mm:ss"
        
        for post in self.posts {
            
            if let dateString = post["date"] as? String{
                
                let dateStringTrimmed = dateString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    
                    
                    if let date = formatter.dateFromString(dateStringTrimmed) {
                        
                        let dateFiveMinsAgo = NSDate().dateByAddingTimeInterval(-(60*5))
                        
                        if date.earlierDate(dateFiveMinsAgo) == dateFiveMinsAgo {
                            
                            if let title = post["title"] as? String{
                                
                                let myUtterance = AVSpeechUtterance(string:title)
                                synth.speakUtterance(myUtterance)
                            }
                        }
                    }
                }
            
        }
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        
        print(elementName)
        
        self.element = elementName
        if (elementName as NSString).isEqualToString("item")
        {
            self.elements = NSMutableDictionary()
            self.elements = [:]
            self.title1 = NSMutableString()
            self.title1 = ""
            self.date = NSMutableString()
            self.date = ""
        }
    }
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if self.element.isEqualToString("title") {
            self.title1.appendString(string)
        } else if self.element.isEqualToString("pubDate") {
            self.date.appendString(string)
        }
    }
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqualToString("item") {
            
            if !self.date.isEqual(nil) {
                self.elements.setObject(self.date, forKey: "date")
            }
            
            if !self.title1.isEqual(nil) {
                self.elements.setObject(self.title1, forKey: "title")
            }
            
            
            self.posts.addObject(self.elements)
        }
    }
}