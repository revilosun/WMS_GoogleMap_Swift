//
//  MapViewController.swift
//
//  Created by Oliver Nass on 31.07.15.
//  Copyright (c) 2015 revilosun. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
  
  @IBOutlet weak var mapView: GMSMapView!
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
   
      var url = "https://maps.dwd.de/geoserver/dwd/wms?LAYERS=Pollenflug_Graeser&STYLES=&SERVICE=WMS&VERSION=1.3&REQUEST=GetMap&SRS=EPSG:900913&width=256&height=256&format=image/png8&transparent=true"
    
    // Create the GMSTileLayer
    var layer = WMSTileOverlay(urlArg: url)
    layer.opacity = 0.0
    layer.map = mapView

    // GMSTileURLConstructor
        var urls: GMSTileURLConstructor = { (x: UInt, y: UInt, zoom: UInt) -> NSURL in
        let bbox = layer.bboxFromXYZ(x, y: y, z: zoom)
        let urlKN = "https://maps.dwd.de/geoserver/dwd/wms?LAYERS=Pollenflug_Graeser&STYLES=&SERVICE=WMS&VERSION=1.3&REQUEST=GetMap&SRS=EPSG:900913&width=256&height=256&format=image/png8&transparent=true&BBOX=\(bbox.left),\(bbox.bottom),\(bbox.right),\(bbox.top)"
          
        return NSURL(string: urlKN)!
      }

    let tileLayer = GMSURLTileLayer(URLConstructor: urls)
    tileLayer.zIndex = 100
    tileLayer.opacity = 0.5
    tileLayer.map = mapView
    
  }

  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
      
      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
    }
  }

  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let location = locations.first as? CLLocation {
      mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 5, bearing: 0, viewingAngle: 0)
      
      locationManager.stopUpdatingLocation()
    }
  }
  
  }
  
