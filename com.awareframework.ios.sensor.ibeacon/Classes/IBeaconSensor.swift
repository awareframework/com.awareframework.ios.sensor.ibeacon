//
//  iBeacon.swift
//  com.awareframework.ios.sensor.core
//
//  Created by Yuuki Nishiyama on 2019/01/25.
//

import UIKit
import CoreLocation
import UserNotifications
import com_awareframework_ios_sensor_core


extension Notification.Name {
    public static let actionAwareIBeacon       = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON)
    public static let actionAwareIBeaconStart  = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_START)
    public static let actionAwareIBeaconStop   = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_STOP)
    public static let actionAwareIBeaconSync   = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_SYNC)
    public static let actionAwareIBeaconSetLabel  = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_SET_LABEL)
    public static let actionAwareIBeaconSyncCompletion  = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_SYNC_COMPLETION)
    
    public static let actionAwareIBeaconEnterRegion = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_ENTER_REGION)
    public static let actionAwareIBeaconExitRegion = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_EXIT_REGION)
    
    public static let actionAwareIBeaconDetermineStatus = Notification.Name(IBeaconSensor.ACTION_AWARE_IBEACON_DETERMINE_STATUS)
}

public protocol IBeaconObserver {
    func didDetermineState(region: IBeaconRegionStateData)
    func didRangeBeacons(beacons: [IBeaconData])
    func didEnterRegion(region: IBeaconRegionEventData)
    func didExitRegion(region: IBeaconRegionEventData)
}

public class IBeaconSensor: AwareSensor {
    
    public static let ACTION_AWARE_IBEACON = "com.awareframework.ios.sensor.ibeacon"
    public static let ACTION_AWARE_IBEACON_START = "com.awareframework.ios.sensor.ibeacon.start"
    public static let ACTION_AWARE_IBEACON_STOP  = "com.awareframework.ios.sensor.ibeacon.stop"
    public static let ACTION_AWARE_IBEACON_SYNC  = "com.awareframework.ios.sensor.ibeacon.sync"
    public static let ACTION_AWARE_IBEACON_SET_LABEL = "com.awareframework.ios.sensor.ibeacon.set_label"
    public static let ACTION_AWARE_IBEACON_SYNC_COMPLETION = "com.awareframework.ios.sensor.ibeacon.sync_completion"
    
    public static let ACTION_AWARE_IBEACON_ENTER_REGION = "com.awareframework.ios.sensor.ibeacon.enter_region"
    public static let ACTION_AWARE_IBEACON_EXIT_REGION  = "com.awareframework.ios.sensor.ibeacon.exit_region"
    public static let ACTION_AWARE_IBEACON_DETERMINE_STATUS = "com.awareframework.ios.sensor.ibeacon.determine_status"
    
    public static let EXTRA_STATUS = "status"
    public static let EXTRA_ERROR = "error"
    public static let EXTRA_OBJECT_TYPE = "objectType"
    public static let EXTRA_TABLE_NAME  = "tableName"
    
    var locationManager: CLLocationManager?
    
    public var CONFIG = IBeaconSensor.Config()
    
    public class Config:SensorConfig {
        
        public var regions = Array<CLBeaconIdentityConstraint>()
        public var sensorObserver: IBeaconObserver?
        
        public override init() {
            super.init()
            dbPath = "aware_ibeacons"
        }
        
        public func apply(closure:(_ config: IBeaconSensor.Config ) -> Void ) -> Self {
            closure(self)
            return self
        }
        
        public func addRegion(_ region:CLBeaconIdentityConstraint){
            self.regions.append(region)
        }
        
        public func removeRegion(_ region:CLBeaconIdentityConstraint){
            
            for (i, r) in zip(regions.indices, regions) {
                let uuid = r.uuid.uuidString
                let major = r.major ?? 0
                let minor = r.minor ?? 0
                if uuid == region.uuid.uuidString &&
                   major == (region.major ?? 0) &&
                   minor == (region.minor ?? 0) {
                    self.regions.remove(at: i)
                }
            }
            
        }
    }
    
    public init(_ config:IBeaconSensor.Config){
        super.init()
        self.locationManager = CLLocationManager()
        self.CONFIG = config
        self.locationManager?.delegate = self;
        self.initializeDbEngine(config: config)
    }
    
    public override convenience init() {
        self.init(IBeaconSensor.Config())
    }
    
    
    public override func start() {
        if self.CONFIG.debug { print(#function) }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager?.requestAlwaysAuthorization()
            return
        case .restricted, .denied:
            // Disable location features
            return
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable basic location features
            break
        @unknown default:
            break
        }
        
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            return
        }
        
        for region in self.CONFIG.regions {
            if self.CONFIG.debug { print("start a region monitoring: \(region.description)") }
            locationManager?.startRangingBeacons(satisfying: region)
        }
        
        self.notificationCenter.post(name: .actionAwareIBeaconStart, object: self)
    }
    
    public override func stop() {
        if self.CONFIG.debug { print(#function) }
        for region in self.CONFIG.regions {
            if self.CONFIG.debug { print("start a region monitoring: \(region.description)") }
            locationManager?.stopRangingBeacons(satisfying: region)
        }
        self.notificationCenter.post(name: .actionAwareIBeaconStop, object: self)
    }
    
    public override func sync(force: Bool) {
        if self.CONFIG.debug { print(#function) }
        if let engine = self.dbEngine {
            let syncConfig = DbSyncConfig().apply{ config in
                config.debug = self.CONFIG.debug
                config.dispatchQueue = DispatchQueue(label: "com.awareframework.ios.sensor.ibeacon.sync.queue")
            }
            engine.startSync(IBeaconData.TABLE_NAME, IBeaconData.self, syncConfig.apply{config in
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_STATUS:status,
                                                            IBeaconSensor.EXTRA_TABLE_NAME:IBeaconData.TABLE_NAME,
                                                            IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconData.self]
                    if let e = error {
                        userInfo[IBeaconSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareIBeaconSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            engine.startSync(IBeaconRegionStateData.TABLE_NAME, IBeaconRegionStateData.self, syncConfig.apply{config in
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_STATUS:status,
                                                            IBeaconSensor.EXTRA_TABLE_NAME:IBeaconRegionStateData.TABLE_NAME,
                                                            IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconRegionStateData.self]
                    if let e = error {
                        userInfo[IBeaconSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareIBeaconSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            engine.startSync(IBeaconRegionEventData.TABLE_NAME, IBeaconRegionEventData.self, syncConfig.apply{config in
                config.completionHandler = { (status, error) in
                    var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_STATUS:status,
                                                            IBeaconSensor.EXTRA_TABLE_NAME:IBeaconRegionEventData.TABLE_NAME,
                                                            IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconRegionEventData.self]
                    if let e = error {
                        userInfo[IBeaconSensor.EXTRA_ERROR] = e
                    }
                    self.notificationCenter.post(name: .actionAwareIBeaconSyncCompletion ,
                                                 object: self,
                                                 userInfo:userInfo)
                }
            })
            
            self.notificationCenter.post(name: .actionAwareIBeaconSync, object: self)
        }
    }
    
    public func sendNotification(title:String, body:String, interval:TimeInterval, id:String){
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body,
                                                                arguments: nil)
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: false)
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        // Schedule the request.
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    public func requestNotification(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
    }
}

extension IBeaconSensor:CLLocationManagerDelegate{
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if self.CONFIG.debug { print(#function) }
        switch status {
        case .authorizedAlways:
            self.stop()
            self.start()
            break
        case .authorizedWhenInUse:
            self.stop()
            self.start()
            break
        default:
            break
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if self.CONFIG.debug { print(#function) }
        manager.requestState(for: region);
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        let beaconState = IBeaconRegionStateData()
        beaconState.identifier = region.identifier
        beaconState.state = state.rawValue
        if let engine = self.dbEngine {
            engine.save(beaconState) { (error) in
                var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_TABLE_NAME:IBeaconRegionStateData.TABLE_NAME,
                                                        IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconRegionStateData.self]
                if let e = error {
                    userInfo[IBeaconSensor.EXTRA_ERROR] = e
                }
                self.notificationCenter.post(name: .actionAwareIBeacon, object: self, userInfo:userInfo)
            }
        }
        
        if let observer = CONFIG.sensorObserver {
            observer.didDetermineState(region: beaconState)
        }
        

        
        switch (state) {
        case .inside:
            print("iBeacon inside");
//            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            if let l = region as? CLBeaconRegion {
                manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: l.uuid))
            }
            break;
        case .outside:
            print("iBeacon outside")
            break;
        case .unknown:
            print("iBeacon unknown")
            break;
        }

    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if self.CONFIG.debug { print(#function) }

        var results = Array<IBeaconData>()
        if beacons.count > 0 {
            for beacon in beacons {
                let beaconData = IBeaconData()
                beaconData.identifier = region.identifier
                beaconData.accuracy = beacon.accuracy
                beaconData.major = Int16(truncating: beacon.major)
                beaconData.minor = Int16(truncating: beacon.minor)
                beaconData.proximity = Int8(beacon.proximity.rawValue)
                beaconData.rssi = beacon.rssi
                beaconData.uuid = beacon.uuid.uuidString
                results.append(beaconData)
            }
        }

        if let engine = self.dbEngine {
            engine.save(results) { (error) in
                var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_TABLE_NAME:IBeaconData.TABLE_NAME,
                                                        IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconData.self]
                if let e = error {
                    userInfo[IBeaconSensor.EXTRA_ERROR] = e
                }
                self.notificationCenter.post(name: .actionAwareIBeacon, object: self, userInfo:userInfo)
            }
        }
        
        if let observer = CONFIG.sensorObserver {
            observer.didRangeBeacons(beacons: results)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if self.CONFIG.debug { print(#function) }
        
        let beaconEvent = IBeaconRegionEventData()
        beaconEvent.identifier = region.identifier
        beaconEvent.state = 1
        if let engine = self.dbEngine {
            engine.save(beaconEvent) { (error) in
                var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_TABLE_NAME:IBeaconRegionEventData.TABLE_NAME,
                                                        IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconRegionEventData.self]
                if let e = error {
                    userInfo[IBeaconSensor.EXTRA_ERROR] = e
                }
                self.notificationCenter.post(name: .actionAwareIBeacon, object: self, userInfo:userInfo)
            }
        }
        
        if let observer = CONFIG.sensorObserver {
            observer.didEnterRegion(region: beaconEvent)
        }
        
//        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        if let l = region as? CLBeaconRegion {
            manager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: l.uuid))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if self.CONFIG.debug { print(#function) }
        
        let beaconEvent = IBeaconRegionEventData()
        beaconEvent.identifier = region.identifier
        beaconEvent.state = 0
        if let engine = self.dbEngine {
            engine.save(beaconEvent) { (error) in
                var userInfo: Dictionary<String,Any> = [IBeaconSensor.EXTRA_TABLE_NAME:IBeaconRegionEventData.TABLE_NAME,
                                                        IBeaconSensor.EXTRA_OBJECT_TYPE:IBeaconRegionEventData.self]
                if let e = error {
                    userInfo[IBeaconSensor.EXTRA_ERROR] = e
                }
                self.notificationCenter.post(name: .actionAwareIBeacon, object: self, userInfo:userInfo)
            }
        }
        
        if let observer = CONFIG.sensorObserver {
            observer.didExitRegion(region: beaconEvent)
        }
        
//        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        if let l = region as? CLBeaconRegion {
            manager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: l.uuid))
        }
    }
    
}

