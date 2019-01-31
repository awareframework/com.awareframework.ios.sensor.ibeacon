//
//  AppDelegate.swift
//  com.awareframework.ios.sensor.ibeacon
//
//  Created by tetujin on 01/25/2019.
//  Copyright (c) 2019 tetujin. All rights reserved.
//

import UIKit
import CoreLocation
import com_awareframework_ios_sensor_ibeacon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var ibeacon:IBeaconSensor?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ibeacon = IBeaconSensor(IBeaconSensor.Config().apply{config in
            let uuid =  UUID.init(uuidString: "D8219342-6770-4AA4-8075-02E4A10084D9")
            let regionA = CLBeaconRegion(proximityUUID:uuid!, identifier: "A Test Beacon")
            config.addRegion(regionA)
            config.debug = true
        })
        ibeacon?.CONFIG.sensorObserver = Observer(ibeacon!)
        ibeacon?.start()
        ibeacon?.requestNotification()
        
        return true
    }
    
    class Observer:IBeaconObserver {
        
        var ibSensor:IBeaconSensor?
        
        init(_ ibSensor:IBeaconSensor) {
            self.ibSensor = ibSensor
        }
        
        func didDetermineState(region: IBeaconRegionStateData) {
            ibSensor?.sendNotification(title: region.identifier, body: "\(region.state)", interval: 1, id: String(Date.init().timeIntervalSince1970))
        }
        
        func didRangeBeacons(beacons: [IBeaconData]) {
            for beacon in beacons {
                ibSensor?.sendNotification(title: beacon.identifier,
                                           body:  "\(beacon.major) \(beacon.minor) \(beacon.accuracy) \(beacon.rssi)",
                                           interval: 1,
                                           id: String(Date.init().timeIntervalSince1970))
            }
        }
        
        func didEnterRegion(region: IBeaconRegionEventData) {
            ibSensor?.sendNotification(title: region.identifier, body: "Enter", interval: 1, id: String(Date.init().timeIntervalSince1970))
        }
        
        func didExitRegion(region: IBeaconRegionEventData) {
            ibSensor?.sendNotification(title: region.identifier, body: "Exit", interval: 1, id: String(Date.init().timeIntervalSince1970))
        }
        
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

