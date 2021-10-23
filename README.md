# com.awareframework.ios.sensor.ibeacon

[![CI Status](https://img.shields.io/travis/awareframework/com.awareframework.ios.sensor.ibeacon.svg?style=flat)](https://travis-ci.org/tetujin/com.awareframework.ios.sensor.ibeacon)
[![Version](https://img.shields.io/cocoapods/v/com.awareframework.ios.sensor.ibeacon.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.ibeacon)
[![License](https://img.shields.io/cocoapods/l/com.awareframework.ios.sensor.ibeacon.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.ibeacon)
[![Platform](https://img.shields.io/cocoapods/p/com.awareframework.ios.sensor.ibeacon.svg?style=flat)](https://cocoapods.org/pods/com.awareframework.ios.sensor.ibeacon)

## Requirements
iOS 10 or later

## Installation

Add `NSLocationWhenInUseUsageDescription` and  `NSLocationAlwaysUsageDescription` keys into Info.plist 

If you need persistent background ranging for beacons, you'll need to activate the **Background Modes capability (Location Updates)** for your application.

com.aware.ios.sensor.ibeacon is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'com.awareframework.ios.sensor.ibeacon'
```

Import com.awareframework.ios.sensor.ibeacon library into your source code.
```swift
import com_awareframework_ios_sensor_ibeacon
```

## Public functions

### IBeaconSensor

+ `init(config:ibeaconSensor.Config?)` : Initializes the IBeacon sensor with the optional configuration.
+ `start()`: Starts the IBeacon sensor with the optional configuration.
+ `stop()`: Stops the service.

### IBeaconSensor.Config

Class to hold the configuration of the sensor.

#### Fields
+ `regions: Array<CLBeaconRegion>`  Regions that you use to detect Bluetooth beacons.
+ `sensorObserver: IBeaconObserver?` A sensor observer for monitoring sensor events
+ `enabled: Boolean` Sensor is enabled or not. (default = `false`)
+ `debug: Boolean` enable/disable logging to `Logcat`. (default = `false`)
+ `label: String` Label for the data. (default = "")
+ `deviceId: String` Id of the device that will be associated with the events and the sensor. (default = "")
+ `dbEncryptionKey` Encryption key for the database. (default = `null`)
+ `dbType: Engine` Which db engine to use for saving data. (default = `Engine.DatabaseType.NONE`)
+ `dbPath: String` Path of the database. (default = "aware_ibeacon")
+ `dbHost: String` Host for syncing the database. (default = `null`)

## Broadcasts

### Fired Broadcasts

+ `IBeaconSensor.ACTION_AWARE_IBEACON` fired when ibeacon saved data to db after the period ends.

### Received Broadcasts

+ `IBeaconSensor.ACTION_AWARE_IBEACON_START`: received broadcast to start the sensor.
+ `IBeaconSensor.ACTION_AWARE_IBEACON_STOP`: received broadcast to stop the sensor.
+ `IBeaconSensor.ACTION_AWARE_IBEACON_SYNC`: received broadcast to send sync attempt to the host.
+ `IBeaconSensor.ACTION_AWARE_IBEACON_SET_LABEL`: received broadcast to set the data label. Label is expected in the `IBeaconSensor.EXTRA_LABEL` field of the intent extras.

## Data Representations

### iBeacon Data

Contains the raw sensor data.

| Field     | Type   | Description                                                         |
| --------- | ------ | ------------------------------------------------------------------- |
| uuid         | String | The unique ID of the beacons being targeted. |
| major         | Int16 |  The value identifying a group of beacons. (16bit) |
| minor         | Int16 |  The value identifying a specific beacon within a group. (16bit) |
| rssi   | Int |  The received signal strength of the beacon, measured in decibels. |
|identifier| String| The identifer of the beacon. |
|proximity|Int| The relative distance to the beacon. (0=unknown, 1=immediate, 2=near, 3=far)|
|accuracy|Double| The accuracy of the proximity value, measured in meters from the beacon. |
| label     | String | Customizable label. Useful for data calibration or traceability     |
| deviceId  | String | AWARE device UUID                                                                 |
| label     | String | Customizable label. Useful for data calibration or traceability     |
| timestamp | Int64   | Unixtime milliseconds since 1970                                          |
| timezone  | Int    | Timezone  of the device                                       |
| os        | String | Operating system of the device (ex. android)                              |

### iBeacon Region State Data

| Field     | Type   | Description                                                         |
| --------- | ------ | ------------------------------------------------------------------- |
|identifier| String| The identifer of the beacon.  |
|state|Int| The current state of the device with reference to a region. (0=unknown, 1= inside, 2=outside)|
| label     | String | Customizable label. Useful for data calibration or traceability     |
| deviceId  | String | AWARE device UUID                                                                 |
| label     | String | Customizable label. Useful for data calibration or traceability     |
| timestamp | Int64   | Unixtime milliseconds since 1970                                          |
| timezone  | Int    | Timezone  of the device                                       |
| os        | String | Operating system of the device (ex. android)                              |

### iBeacon Region Event Data

| Field     | Type   | Description                                                         |
| --------- | ------ | ------------------------------------------------------------------- |
|identifier| String| The identifer of the beacon.  |
|state|Int| The event of region enter and exit events (0=exit, 1=enter)|
| label     | String | Customizable label. Useful for data calibration or traceability     |
| deviceId  | String | AWARE device UUID                                                                 |
| label     | String | Customizable label. Useful for data calibration or traceability     |
| timestamp | Int64   | Unixtime milliseconds since 1970                                          |
| timezone  | Int    | Timezone  of the device                                       |
| os        | String | Operating system of the device (ex. android)                              |


### Example usage
Import ibeacon sensor library (com_aware_ios_sensor_ibeacon) to your target class.

```swift
import com_awareframework_ios_sensor_ibeacon
```

Generate an ibeacon sensor instance and start/stop the sensor.

```swift
let ibeacon = IBeaconSensor(IBeaconSensor.Config().apply{config in
    let uuid =  UUID.init(uuidString: "D8219342-6770-4AA4-8075-02E4A10084D9")
    let regionA = CLBeaconRegion(proximityUUID:uuid!, identifier: "Test")
    config.addRegion(regionA)
    config.sensorObserver = Observer()
})

ibeacon?.start()

ibeacon?.stop()
```

```swift
class Observer:IBeaconObserver{
    func didDetermineState(region: IBeaconRegionStateData) {
        // Your code here
    }

    func didRangeBeacons(beacons: [IBeaconData]) {
        // Your code here
    }

    func didEnterRegion(region: IBeaconRegionEventData) {
        // Your code here
    }

    func didExitRegion(region: IBeaconRegionEventData) {
        // Your code here
    }
}
```

## Author
Yuuki Nishiyama, yuuki.nishiyama@oulu.fi

## Related Links
* [ Apple | iBeacon ](https://developer.apple.com/ibeacon/)
* [ Apple | Getting Started with iBeacon ](https://developer.apple.com/ibeacon/Getting-Started-with-iBeacon.pdf)

## License
Copyright (c) 2021 AWARE Mobile Context Instrumentation Middleware/Framework (http://www.awareframework.com)

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

