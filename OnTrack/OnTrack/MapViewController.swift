//
//  MapViewController.swift
//  OnTrack
//
//  Created by Daren David Taylor on 01/09/2015.
//  Copyright (c) 2015 LondonSwift. All rights reserved.
//

import UIKit
import MapKit
import AudioToolbox

public enum MapType: Int {
    case AppleStandard = 0
    case AppleSatellite
    case AppleHybrid
    case None
    case OpenCycleMap
}

class MapViewController: UIViewController {
    var locationArray:Array<CLLocation>?
    var polylineArray:Array<MKPolyline>?
    var rendererArray:Array<MKPolylineRenderer>?
    var interpolatedLocationArray:Array<CLLocation>?
    
    @IBOutlet weak var mapTypeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var youButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var mapType:MapType = .AppleStandard
    var boundingRect:MKMapRect?
    var overlay:MKTileOverlay?
    
    
    var locationManager: CLLocationManager!
    
    var found = false
    
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1]
    }
    
    lazy var locationArrayArray:Array<Array<CLLocation>> = {
        
        var locationArrayArray = Array<Array<CLLocation>>()
        
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("local.gpx")
        
        if let root = GPXParser.parseGPXAtURL(url) {
            
            if let tracks = root.tracks {
                for track in tracks as! [GPXTrack] {
                    
                    for trackSegment in track.tracksegments as! [GPXTrackSegment] {
                        var array = [CLLocation]()
                        for trackPoint in  trackSegment.trackpoints as! [GPXTrackPoint] {
                            let location = CLLocation(latitude: CLLocationDegrees(trackPoint.latitude), longitude: CLLocationDegrees(trackPoint.longitude))
                            array.append(location)
                        }
                        locationArrayArray.append(array)
                    }
                }
            }
            
            if let routes = root.routes {
                for route in routes as! [GPXRoute] {
                    var array = [CLLocation]()
                    
                    for routePoint in  route.routepoints as! [GPXRoutePoint] {
                        let location = CLLocation(latitude: CLLocationDegrees(routePoint.latitude), longitude: CLLocationDegrees(routePoint.longitude))
                        array.append(location)
                    }
                    
                    locationArrayArray.append(array)
                }
            }
        }
        
        return locationArrayArray;
        
        }()
    
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
        self.calculateBoundingRect()
        self.zoomMapToRoute()
    }
    
    @IBAction func didPressYouButton(sender: AnyObject) {
        self.mapView.setUserTrackingMode(.FollowWithHeading, animated:true);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.interpolateWith(5)
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.popolateMapWithPolyline()
        self.zoomMapToRoute()
        self.allButton.selected = true
        self.updateMapType()
        self.setupLocationManager()
    }
    
    func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
    
    func populateWithPoints()
    {
        if let locationArray = self.locationArray {
            for location in locationArray {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location.coordinate;
                self.mapView.addAnnotation(annotation);
            }
        }
    }
    
    func calculateBoundingRect () {
        self.boundingRect = MKMapRectNull;
        
        if let location = self.mapView.userLocation.location {
            
            let point = MKMapPointForCoordinate(location.coordinate)
            self.boundingRect = MKMapRectMake(point.x, point.y,0,0);
        }
        
        
        if let polylineArray = self.polylineArray {
            
            for polyline in polylineArray {
                
                if let boundingRect = self.boundingRect {
                    self.boundingRect = MKMapRectUnion(polyline.boundingMapRect, boundingRect);
                }
                else {
                    self.boundingRect = polyline.boundingMapRect;
                }
                
            }
        }
        
        if let boundingRect = self.boundingRect {
            self.boundingRect = MKMapRectInset(boundingRect, -boundingRect.size.width / 2, -boundingRect.size.height/2);
        }
    }
    
    func popolateMapWithPolyline()
    {
        self.polylineArray = Array<MKPolyline>()
        self.rendererArray = Array<MKPolylineRenderer>()
        
        
        for locationArray in self.locationArrayArray {
            let coordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(locationArray.count)
            var i = 0
            for location in locationArray {
                coordinates[i++] = location.coordinate;
            }
            
            let polyline = MKPolyline(coordinates: coordinates, count: locationArray.count)
            let renderer = MKPolylineRenderer(polyline: polyline)
            
            renderer.strokeColor = UIColor.darkGrayColor()
            renderer.lineWidth = 3;
            
            self.polylineArray?.append(polyline)
            self.rendererArray?.append(renderer)
            
            self.mapView.addOverlay(polyline, level:.AboveLabels);
        }
        
        
        self.calculateBoundingRect()
        
        
    }
    
    func zoomMapToRoute() {
        
        if let boundingRect = self.boundingRect {
            self.mapView.setVisibleMapRect(boundingRect, animated:true);
        }
    }
    
    func updateMapType() {
        
        if let overlay = self.overlay {
            
            self.mapView.removeOverlay(overlay);
            
            self.overlay = nil;
        }
            switch (self.mapType)
            {
            case .AppleStandard:
                self.mapView.mapType = .Standard;
            case .AppleSatellite:
                self.mapView.mapType = .Satellite;
            case .AppleHybrid:
                self.mapView.mapType = .Hybrid;
            case .OpenCycleMap:
                self.addStreetMap();
            default:
                break;
            }
        
    }
    
    func addStreetMap() {
        let template = "http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        self.overlay = MKTileOverlay(URLTemplate:template)
        self.overlay?.canReplaceMapContent = true
        self.mapView.addOverlay(self.overlay!, level:.AboveLabels)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        if (mode == .None) {
            self.allButton.selected = true;
            self.youButton.selected = false;
        }
        else if (mode == .Follow) {
            self.allButton.selected = true;
            self.youButton.selected = false;
        }
        else if (mode == .FollowWithHeading) {
            self.allButton.selected = false;
            self.youButton.selected = true;
        }
        
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay.isKindOfClass(MKTileOverlay) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        if let polylineArray = self.polylineArray {
            
            if let overlay = overlay as? MKPolyline {
                if let i = polylineArray.indexOf(overlay) {
                    
                    if let rendererArray = self.rendererArray {
                        
                        return rendererArray[i]
                    }
                }
                
            }
        }
        
        return MKTileOverlayRenderer(overlay: overlay)
        
    }
    
    
    func interpolateWith(metres: CLLocationDistance) {
        self.interpolatedLocationArray = [CLLocation]()
        var lastLocation: CLLocation?
        
        for locationArray in self.locationArrayArray {
            for location in locationArray {
                if let lastLocation = lastLocation {
                    let distance = location.distanceFromLocation(lastLocation)
                    let bearing = self.bearingToLocation(location, fromLocation:lastLocation);
                    
                    print(distance / metres)
                    
                    for var i:CLLocationDistance = 0 ; i < distance / metres ; i++ {
                        
                        let cooridinate = self.locationWithBearing(bearing, distance:metres*i, origin:lastLocation.coordinate)
                        
                        let interpolatedLocation = CLLocation(latitude: cooridinate.latitude, longitude:cooridinate.longitude)
                        
                        self.interpolatedLocationArray?.append(interpolatedLocation)
                    }
                }
                lastLocation = location
            }
        }
    }
    
    func locationWithBearing(bearing:CLLocationDistance, distance:CLLocationDistance, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distance / (6372797.6) // earth radius in meters
        
        let lat1 = origin.latitude * M_PI / 180
        let lon1 = origin.longitude * M_PI / 180
        
        let lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing))
        let lon2 = lon1 + atan2( sin(bearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2) )
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / M_PI, longitude: lon2 * 180 / M_PI)
    }
    
    func degreesToRadians(degrees: CLLocationDegrees) -> Double {
        return degrees * M_PI / 180
    }
    
    func bearingToLocation(location: CLLocation, fromLocation:CLLocation) ->Double {
        
        let lat1 = self.degreesToRadians(fromLocation.coordinate.latitude)
        let lon1 = self.degreesToRadians(fromLocation.coordinate.longitude);
        
        let lat2 = self.degreesToRadians(location.coordinate.latitude);
        let lon2 = self.degreesToRadians(location.coordinate.longitude);
        
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansBearing;
    }
}

extension MapViewController : CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.first
        
        var minimumDistance: CLLocationDistance = CLLocationDistance.infinity;
        
        if let interpolatedLocationArray = self.interpolatedLocationArray {
            
            for location in interpolatedLocationArray {
                let distance = location.distanceFromLocation(currentLocation!);
                minimumDistance = min(minimumDistance, distance);
                
            }
            
            let warningDistance:CLLocationDistance = 100
            
            if minimumDistance > warningDistance {
                AudioServicesPlaySystemSound (1033);
                self.found = false;
            }
            else {
                if self.found == false {
                    AudioServicesPlaySystemSound (1028);
                }
                self.found = true;
            }
            
            self.distanceLabel.text = String(format:"%.2fm", minimumDistance);
        }
        
    }
}



