//
//  MapViewController.swift
//  OnTrack
//
//  Created by Daren David Taylor on 01/09/2015.
//  Copyright (c) 2015 LondonSwift. All rights reserved.
//

import UIKit
import MapKit

public enum MapType: Int {
    case AppleStandard = 0
    case AppleSatellite
    case AppleHybrid
    case None
    case OpenCycleMap
}



class MapViewController: UIViewController , MKMapViewDelegate{
    
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var youButton: UIButton!
    
    var mapType:MapType = .AppleStandard
    var boundingRect:MKMapRect?
    var overlay:MKTileOverlay?
    
    @IBAction func didPressMapTypeButton(sender: AnyObject) {
        if let newValue = MapType(rawValue: self.mapType.rawValue + 1) {
            self.mapType = newValue
        }
        else {
            self.mapType = .AppleStandard
        }
        
        self.updateMapType()
        
    }
    
    @IBAction func didPressAllButton(sender: AnyObject) {
    }
    @IBAction func didPressYouButton(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.showsUserLocation = true
        
        //  self.addPolylineToMap()
        
        self.zoomMapToRoute()
        
        
        
    }
    
    func zoomMapToRoute() {
        
        if let boundingRect = self.boundingRect {
            self.mapView.setVisibleMapRect(boundingRect, animated:true);
        }
    }
    
    
    func updateMapType() {
        self.mapView.removeOverlay(self.overlay);
        
        self.overlay = nil;
        
        switch (self.mapType)
        {
        case .AppleStandard:
            self.mapView.mapType = .Standard;
        case .AppleSatellite:
            self.mapView.mapType = .Satellite;
        case .AppleHybrid:
            self.mapView.mapType = .Hybrid;
        case .None:
            self.removeMapTiles()
        case .OpenCycleMap:
            self.addStreetMap();
        default:
            break;
        }
    }
    
    
    func addStreetMap() {
        let template = "http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        self.overlay = MKTileOverlay(URLTemplate:template)
        if let overlay = self.overlay {
            overlay.canReplaceMapContent = true
            self.mapView.addOverlay(overlay, level:.AboveLabels)
        }
    }
    
    func removeMapTiles() {
        self.overlay = MKTileOverlay()
        if let overlay = self.overlay {
            overlay.canReplaceMapContent = true;
            self.mapView.addOverlay(overlay, level:.AboveLabels);
        }
    }
    
}



