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

On the simulator, the background outside of the image is white-transparent. On the device, it looks perfect (Bug?).
Example:
https://www.dropbox.com/s/54fk58klpqxw1fu/iOS%20Simulator%20Screen%20Shot%2021.09.2015%2011.22.52.png?dl=0

https://www.dropbox.com/s/on1h793jiyf6bpl/Screen%20Shot%202015-09-21%20at%2011.23.33.png?dl=0

