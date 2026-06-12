import Foundation
import com_awareframework_ios_core
import GRDB

public struct IBeaconData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_ibeacon"

    public var uuid: String = ""
    public var major: Int = 0
    public var minor: Int = 0
    public var identifier: String = ""
    public var rssi: Int = 0
    public var proximity: Int = 0
    public var accuracy: Double = 0

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp  = dict["timestamp"] as? Int64 ?? 0
        label      = dict["label"] as? String ?? ""
        deviceId   = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        uuid       = dict["uuid"] as? String ?? ""
        major      = dict["major"] as? Int ?? 0
        minor      = dict["minor"] as? Int ?? 0
        identifier = dict["identifier"] as? String ?? ""
        rssi       = dict["rssi"] as? Int ?? 0
        proximity  = dict["proximity"] as? Int ?? 0
        accuracy   = dict["accuracy"] as? Double ?? 0
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("uuid",.text).notNull()
            t.column("timezone",.integer).notNull(); t.column("os",.text).notNull()
            t.column("jsonVersion",.integer).notNull()
            t.column("major",.integer).notNull(); t.column("minor",.integer).notNull()
            t.column("identifier",.text).notNull(); t.column("rssi",.integer).notNull()
            t.column("proximity",.integer).notNull(); t.column("accuracy",.double).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "uuid": uuid, "major": major, "minor": minor, "identifier": identifier,
         "rssi": rssi, "proximity": proximity, "accuracy": accuracy]
    }
}

public struct IBeaconRegionStateData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_ibeacon_region_state"

    public var identifier: String = ""
    public var state: Int = 0

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp  = dict["timestamp"] as? Int64 ?? 0
        label      = dict["label"] as? String ?? ""
        deviceId   = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        identifier = dict["identifier"] as? String ?? ""
        state      = dict["state"] as? Int ?? 0
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("identifier",.text).notNull()
            t.column("timezone",.integer).notNull(); t.column("os",.text).notNull()
            t.column("jsonVersion",.integer).notNull()
            t.column("state",.integer).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "identifier": identifier, "state": state]
    }
}

public struct IBeaconRegionEventData: BaseDbModelSQLite {
    public var id: Int64?
    public var timestamp: Int64 = 0
    public var deviceId: String = AwareUtils.getCommonDeviceId()
    public var label: String = ""
    public var timezone: Int = AwareUtils.getTimeZone()
    public var os: String = "iOS"
    public var jsonVersion: Int = 1
    public static let databaseTableName = "ios_ibeacon_region_event"

    public var identifier: String = ""
    public var state: Int = 0

    public init() {}
    public init(_ dict: Dictionary<String, Any>) {
        timestamp  = dict["timestamp"] as? Int64 ?? 0
        label      = dict["label"] as? String ?? ""
        deviceId   = dict["deviceId"] as? String ?? AwareUtils.getCommonDeviceId()
        identifier = dict["identifier"] as? String ?? ""
        state      = dict["state"] as? Int ?? 0
    }
    public static func createTable(queue: DatabaseQueue) throws {
        try queue.write { db in try db.create(table: databaseTableName, ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("deviceId",.text).notNull(); t.column("timestamp",.integer).notNull()
            t.column("label",.text).notNull(); t.column("identifier",.text).notNull()
            t.column("timezone",.integer).notNull(); t.column("os",.text).notNull()
            t.column("jsonVersion",.integer).notNull()
            t.column("state",.integer).notNull()
        }}
    }
    public func toDictionary() -> Dictionary<String, Any> {
        ["id": id ?? -1, "timestamp": timestamp, "deviceId": deviceId, "label": label,
         "identifier": identifier, "state": state]
    }
}
