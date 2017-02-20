import Foundation

extension String {
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
}

class WMSTileOverlay: GMSTileLayer {
    
    var url: String
    var image: UIImage
    
    init(urlArg: String) {
        self.image = UIImage(named: "placeholder.png")!
        self.url = urlArg
        super.init()
    }
    
    
    // MapViewUtils
    
    let TILE_SIZE = 256.0
    let MINIMUM_ZOOM = 0
    let MAXIMUM_ZOOM = 25
    let TILE_CACHE = "TILE_CACHE"
    
    struct BBox {
        let left: Double
        let bottom: Double
        let right: Double
        let top: Double
    }
    
    func bboxFromXYZ(_ x: UInt, y: UInt, z: UInt) -> BBox {
        let bbox = BBox(left: mercatorXofLongitude(xOfColumn(x,zoom: z)), bottom: mercatorYofLatitude(yOfRow(y+1,zoom: z)), right: mercatorXofLongitude(xOfColumn(x+1,zoom: z)), top: mercatorYofLatitude(yOfRow(y,zoom: z)))
        return bbox
    }
    
    func xOfColumn(_ column: UInt, zoom: UInt) -> Double {
        let x = Double(column)
        let z = Double(zoom)
        return x / pow(2.0, z) * 360.0 - 180
    }
    
    func yOfRow(_ row: UInt, zoom: UInt) -> Double {
        let y = Double(row)
        let z = Double(zoom)
        let n = M_PI - 2.0 * M_PI * y / pow(2.0, z)
        return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)))
    }
    
    func mercatorXofLongitude(_ lon: Double) -> Double {
        return lon * 20037508.34 / 180
    }
    
    func mercatorYofLatitude(_ lat: Double) -> Double {
        var y = log(tan((90 + lat) * M_PI / 360)) / (M_PI / 180)
        y = y * 20037508.34 / 180
        return y
    }
    
    func md5Hash(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    func createPathIfNecessary(_ path: String) -> Bool {
        var succeeded = true
        let fm = FileManager.default
        if(!fm.fileExists(atPath: path)) {
            do {
                try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                succeeded = true
            } catch _ {
                succeeded = false
            }
        }
        return succeeded
    }
    
    func cachePathWithName(_ name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let cachesPath: String = paths as String
        let cachePath = name.stringByAppendingPathComponent(cachesPath)
        var succeeded = false
        succeeded = createPathIfNecessary(cachesPath)
        succeeded = createPathIfNecessary(cachePath)
        if succeeded == false {
            print("Cannot create cachePath WMSTileOverlay")
        }
        
        return cachePath
    }
    
    
    func getFilePathForURL(_ url: URL, folderName: String) -> String {
        return cachePathWithName(folderName).stringByAppendingPathComponent(md5Hash("\(url)" as String) as String)
    }
    
    func cacheUrlToLocalFolder(_ url: URL, data: Data, folderName: String) {
        let localFilePath = getFilePathForURL(url, folderName: folderName)
        try? data.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])
    }
    
    // MapViewUtils END ************
    
    
    func tileLoad(_ url: String, online: Bool) -> UIImage {
        let url1 = URL(string: url)!
        let filePath = getFilePathForURL(url1, folderName: TILE_CACHE)
        // check if cached
        let file = FileManager.default
        if file.fileExists(atPath: filePath) {
            let imagetmp = try? Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
            image = UIImage(data: imagetmp!)!
        }
        else if online {
            let imgData = try? Data(contentsOf: url1, options: .mappedIfSafe)
            try? imgData!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            image = UIImage(data: imgData!)!
        }
        return image
    }
    
    func getUrlX(_ x1: UInt, y1: UInt, z1: UInt) -> String {
        let bbox = bboxFromXYZ(x1, y: y1, z: z1)
        let resolvedUrl = "\(self.url)&BBOX=\(bbox.left),\(bbox.bottom),\(bbox.right),\(bbox.top)"
        //       println("Url tile overlay \(resolvedUrl)")
        
        return resolvedUrl
    }
    
    func drawTileAtX(_ x: UInt, y: UInt, z: UInt, url: String, receiver: GMSTileReceiver) {
        let image = tileLoad(url, online: false)
        receiver.receiveTileWith(x: x, y: y, zoom: z, image: image)
    }
    
    override func requestTileFor(x: UInt, y: UInt, zoom: UInt, receiver: GMSTileReceiver!) {
        let urlStr = self.getUrlX(x, y1: y, z1: zoom)
        if urlStr == "" {
            print("URL Evaluation error")
            receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
            return
        }
        let url1 = URL(string: url)!
        let filePath = getFilePathForURL(url1, folderName: TILE_CACHE)
        // check if cached
        let file = FileManager.default
        if file.fileExists(atPath: filePath) {
            self.drawTileAtX(x, y: y, z: zoom, url: urlStr, receiver: receiver)
            return
        }
        else {
            let url = URL(string: urlStr)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
                if error != nil{
                    print("Error downloading tile")
                    receiver.receiveTileWith(x: x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
                }
                else {
                    try? data!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
                    self.drawTileAtX(x, y: y, z: zoom, url: urlStr, receiver: receiver)
                }
            }
            task.resume()
            
        }
        
    }
    
}

