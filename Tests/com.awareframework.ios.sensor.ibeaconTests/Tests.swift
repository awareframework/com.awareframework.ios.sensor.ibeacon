import XCTest
import CoreLocation
@testable import com_awareframework_ios_sensor_ibeacon
import com_awareframework_ios_core

/// Records the rows saved to it and whether they were saved on the main thread
private final class RecordingEngine: Engine {
    private let lock = NSLock()
    private(set) var savedRows = 0
    private(set) var savesOnMain = 0
    // EngineConfig has no public initializer: borrow one from an engine the package builds
    init() { super.init(Engine.Builder().build().config) }
    override func save(_ data: [any BaseDbModelSQLite], completion: ((Error?) -> Void)?) {
        lock.lock()
        savedRows += data.count
        if Thread.isMainThread { savesOnMain += 1 }
        lock.unlock()
        completion?(nil)
    }
}

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    /// Region events are saved off the main thread; actionAwareIBeacon is posted on the main thread
    func testEventsAreSavedOffMainAndNotifiedOnMain() {
        let sensor = IBeaconSensor(IBeaconSensor.Config())
        let engine = RecordingEngine()
        sensor.dbEngine = engine
        let region = CLBeaconRegion(uuid: UUID(), identifier: "test-region")

        let notified = expectation(description: "notified twice")
        notified.expectedFulfillmentCount = 2
        let token = NotificationCenter.default.addObserver(forName: .actionAwareIBeacon, object: sensor, queue: nil) { _ in
            XCTAssertTrue(Thread.isMainThread)
            notified.fulfill()
        }
        // From the main thread, as Core Location calls the delegate, and from another thread
        sensor.locationManager(sensor.locationManager!, didEnterRegion: region)
        DispatchQueue.global().async {
            sensor.locationManager(sensor.locationManager!, didExitRegion: region)
        }
        wait(for: [notified], timeout: 5)
        sensor.waitForPendingSaves()
        XCTAssertEqual(engine.savedRows, 2)
        XCTAssertEqual(engine.savesOnMain, 0, "never saved on the main thread")
        NotificationCenter.default.removeObserver(token)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }

    /// The sensor creates all its tables, and each table can be read back for sync by an engine
    /// for that table (one engine used to be synced for every table, so only one was ever uploaded)
    func testSensorCreatesAndSyncsEveryTable() {
        let path = "create_table_test_\(UUID().uuidString)"
        let sensor = IBeaconSensor(IBeaconSensor.Config().apply { config in config.dbPath = path })
        guard let engine = sensor.dbEngine else { return XCTFail("no engine") }
        let saved = expectation(description: "saved")
        saved.expectedFulfillmentCount = 3
        engine.save([IBeaconData()]) { error in XCTAssertNil(error); saved.fulfill() }
        engine.save([IBeaconRegionStateData()]) { error in XCTAssertNil(error); saved.fulfill() }
        engine.save([IBeaconRegionEventData()]) { error in XCTAssertNil(error); saved.fulfill() }
        wait(for: [saved], timeout: 5)
        func tableEngine(_ table: String) -> Engine {
            Engine.Builder().setPath(path).setType(.sqlite).setTableName(table).build()
        }
        XCTAssertEqual(tableEngine(IBeaconData.databaseTableName).fetch(filter: nil, limit: nil)?.count, 1, "IBeaconData can be read for sync")
        XCTAssertEqual(tableEngine(IBeaconRegionStateData.databaseTableName).fetch(filter: nil, limit: nil)?.count, 1, "IBeaconRegionStateData can be read for sync")
        XCTAssertEqual(tableEngine(IBeaconRegionEventData.databaseTableName).fetch(filter: nil, limit: nil)?.count, 1, "IBeaconRegionEventData can be read for sync")
        XCTAssertEqual(IBeaconSensor.tables.map(\.name), [IBeaconData.databaseTableName, IBeaconRegionStateData.databaseTableName, IBeaconRegionEventData.databaseTableName])
    }
}
