import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapview: GMSMapView!
    
    let locationManager = CLLocationManager()
    let layer: WMSTileOverlay
    var url = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapview.isMyLocationEnabled = true
        mapview.settings.myLocationButton = true
        
        url = ""
 
        self.getCardfromGeoserver()
        self.mapview.mapType = kGMSTypeTerrain
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    required init?(coder aDecoder: NSCoder) {
        self.layer = WMSTileOverlay(urlArg: url)
        super.init(coder: aDecoder)
    }

    // Warnung ueber Geoserver holen
    func getCardfromGeoserver() {
        mapview.clear()
        mapview.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: 51.0000000, longitude: 10.0000000), zoom: 5.5, bearing: 0, viewingAngle: 0)
        
        // Implement GMSTileURLConstructor
        // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
        let urls: GMSTileURLConstructor = { (x: UInt, y: UInt, zoom: UInt) -> URL in
            let bbox = self.layer.bboxFromXYZ(x, y: y, z: zoom)
            let urlKN = "https://__GEOSERVER__?LAYERS=__LAYER__&STYLES=&SERVICE=WMS&VERSION=1.3&REQUEST=GetMap&SRS=EPSG:900913&width=256&height=256&format=image/png&transparent=true&BBOX=\(bbox.left),\(bbox.bottom),\(bbox.right),\(bbox.top)"

            return URL(string: urlKN)!
        }
        
        let tileLayer = GMSURLTileLayer(urlConstructor: urls)
        tileLayer?.opacity = 0.75
        
        tileLayer?.map = nil
        tileLayer?.map = mapview
    }

    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapview.isMyLocationEnabled = true
            mapview.settings.myLocationButton = true
        }
    }
    
    
}

