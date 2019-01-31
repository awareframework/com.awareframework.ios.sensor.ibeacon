//
//  iBeaconData.swift
//  com.awareframework.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2019/01/25.
//

import UIKit
import com_awareframework_ios_sensor_core

public class IBeaconData: AwareObject {
    
    public static var TABLE_NAME = "iBeaconData"
    
    @objc public var uuid:String = ""
    @objc public var major:Int16 = 0
    @objc public var minor:Int16 = 0
    @objc public var identifier:String = ""
    @objc public var rssi:Int = 0
    @objc public var proximity:Int8  = 0
    @objc public var accuracy:Double = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["uuid"]      = uuid
        dict["major"]     = major
        dict["minor"]     = minor
        dict["identifier"] = identifier
        dict["rssi"]      = rssi
        dict["proximity"] = proximity
        dict["accuracy"]  = accuracy
        return dict
    }
}

public class IBeaconRegionStateData: AwareObject {
    
    public static var TABLE_NAME = "iBeaconRegionStateData"
    
    @objc public var identifier:String = ""
    @objc public var state:Int = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["identifier"] = identifier
        dict["state"] = state
        return dict
    }
}

public class IBeaconRegionEventData: AwareObject {
    
    public static var TABLE_NAME = "IBeaconRegionEventData"
    
    @objc public var identifier:String = ""
    @objc public var state:Int = 0
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var dict = super.toDictionary()
        dict["identifier"] = identifier
        dict["state"] = state
        return dict
    }
}

