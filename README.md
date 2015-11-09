#WMS_GoogleMap_Swift
Example of using WMS with GoogleMaps in Swift 2.0

This code is translate from https://github.com/Sumbera/WMS_iOS_GoogleMapSDK written in Object-C


Requirements:

- GoogleMaps 1.10.4
- Swift 2.0 (XCode 7)
- pod


To use:

- Copy this project
- Run pod install in the path of podfile
- Embedded the GoogleMaps.framework
- Create the Bridging-Header File
- Add your API key for GoogleMaps in AppDelegate.swift
- Modify the URL for the Geoserver in ViewController.swift

To compile:

Build Settings:
- Enable BitCode = No
- Other Linker Flags: -ObjC

Remarks:
On the simulator, the background outside of the image is white. On the device, it looks perfect (Bug?).
