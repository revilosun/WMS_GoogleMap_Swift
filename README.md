#WMS_GoogleMap_Swift
Example of using WMS with GoogleMaps in Swift 3.0

This code is translate from https://github.com/Sumbera/WMS_iOS_GoogleMapSDK written in Object-C


Requirements:

- GoogleMaps 1.10.4
- Swift 3.0 (XCode 8)
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


Third Part Licence:<br>
GoogleMaps SDK for iOS <br>https://developers.google.com/maps/terms


UPDATE: Convert from Swift 2.0 to Swift 3.0
If "compiled error (newer version of Swift language (3.0) than previous files ( Swift 2.0)) with linker command", you must update your pod with:
- run command "pod update".
- clean the project in XCode8, then exit the programm
- delete the DerivedData Folder and then build your project again


