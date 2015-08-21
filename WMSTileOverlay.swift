//
//  WMSTileOverlay.swift
//
//  Created by Oliver Nass on 31.07.15.
//  Copyright (c) 2015 revilosun. All rights reserved.
//


import Foundation


class WMSTileOverlay: GMSTileLayer {
  
  var url: String
  var image: UIImage

  init(urlArg: String) {
    self.image = UIImage(named: "placeholder.png")!
    self.url = urlArg
    super.init()
  }
  
  
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
  
  func bboxFromXYZ(x: UInt, y: UInt, z: UInt) -> BBox {
    let bbox = BBox(left: mercatorXofLongitude(xOfColumn(x,zoom: z)), bottom: mercatorYofLatitude(yOfRow(y+1,zoom: z)), right: mercatorXofLongitude(xOfColumn(x+1,zoom: z)), top: mercatorYofLatitude(yOfRow(y,zoom: z)))
    return bbox
  }
  
  func xOfColumn(column: UInt, zoom: UInt) -> Double {
    var x = Double(column)
    var z = Double(zoom)
    return x / pow(2.0, z) * 360.0 - 180
  }
  
  func yOfRow(row: UInt, zoom: UInt) -> Double {
    var y = Double(row)
    var z = Double(zoom)
    var n = M_PI - 2.0 * M_PI * y / pow(2.0, z)
    return 180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)))
  }
  
  func mercatorXofLongitude(lon: Double) -> Double {
    return lon * 20037508.34 / 180
  }
  
  func mercatorYofLatitude(lat: Double) -> Double {
    var y = log(tan((90 + lat) * M_PI / 360)) / (M_PI / 180)
    y = y * 20037508.34 / 180
    return y
  }
  
  func md5Hash(stringData: NSString) -> NSString {
    let str = stringData.cStringUsingEncoding(NSUTF8StringEncoding)
    let strLen = CUnsignedInt(stringData.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
    
    let digestLen = Int(CC_MD5_DIGEST_LENGTH)
    let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
    CC_MD5(str, strLen, result)
    
    var hash = NSMutableString()
    for i in 0..<digestLen {
      hash.appendFormat("%02x", result[i])
    }
    
    result.dealloc(digestLen)
    
    return String(format: hash)
  }
  
  func createPathIfNecessary(path: String) -> Bool {
    var succeeded = true
    var fm = NSFileManager.defaultManager()
    if(!fm.fileExistsAtPath(path)) {
      succeeded = fm.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    return succeeded
  }
  
  func cachePathWithName(name: String) -> String {
    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    var cachesPath: String = paths
    var cachePath = name.stringByAppendingPathComponent(cachesPath)
    createPathIfNecessary(cachesPath)
    createPathIfNecessary(cachePath)
    
    return cachePath
  }
  
  
  func getFilePathForURL(url: NSURL, folderName: String) -> String {
    return cachePathWithName(folderName).stringByAppendingPathComponent(md5Hash("\(url)"))
  }
  
  func cacheUrlToLocalFolder(url: NSURL, data: NSData, folderName: String) {
    let localFilePath = getFilePathForURL(url, folderName: folderName)
    data.writeToFile(localFilePath, atomically: true)
  }
  

  func tileLoad(url: String, online: Bool) -> UIImage {
    let url1 = NSURL(string: url)!
    let filePath = getFilePathForURL(url1, folderName: TILE_CACHE)
    // check if cached
    var file = NSFileManager.defaultManager()
    if file.fileExistsAtPath(filePath) {
      let imagetmp = NSData(contentsOfFile: filePath, options: .DataReadingMappedIfSafe, error: nil)
      image = UIImage(data: imagetmp!)!
    }
    else if online {
      let imgData = NSData(contentsOfURL: url1, options: .DataReadingMappedIfSafe, error: nil)
      imgData!.writeToFile(filePath, atomically: true)
      image = UIImage(data: imgData!)!
    }
    return image
  }

  func getUrlX(x1: UInt, y1: UInt, z1: UInt) -> String {
    let bbox = bboxFromXYZ(x1, y: y1, z: z1)
    var resolvedUrl = "\(self.url)&BBOX=\(bbox.left),\(bbox.bottom),\(bbox.right),\(bbox.top)"
    //       println("Url tile overlay \(resolvedUrl)")
    
    return resolvedUrl
  }
  
  func drawTileAtX(x: UInt, y: UInt, z: UInt, url: String, receiver: GMSTileReceiver) {
    let image = tileLoad(url, online: false)
    receiver.receiveTileWithX(x, y: y, zoom: z, image: image)
  }
  
  override func requestTileForX(x: UInt, y: UInt, zoom: UInt, receiver: GMSTileReceiver!) {
    let urlStr = self.getUrlX(x, y1: y, z1: zoom)
    if urlStr == "" {
      println("URL Evaluation error")
      receiver.receiveTileWithX(x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
      return
    }
    let url1 = NSURL(string: url)!
    let filePath = getFilePathForURL(url1, folderName: TILE_CACHE)
    // check if cached
    var file = NSFileManager.defaultManager()
    if file.fileExistsAtPath(filePath) {
      self.drawTileAtX(x, y: y, z: zoom, url: urlStr, receiver: receiver)
      return
    }
    else {
      let url = NSURL(string: urlStr)!
      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "GET"
      
      NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
        
        if error != nil {
          println("Error downloading tile")
          receiver.receiveTileWithX(x, y: y, zoom: zoom, image: kGMSTileLayerNoTile)
        }
        else {
          data.writeToFile(filePath, atomically: true)
          self.drawTileAtX(x, y: y, z: zoom, url: urlStr, receiver: receiver)
        }
      }

    }
    
  }
  
}

