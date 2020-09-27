//
//  BicycleBLEKit.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation

public protocol BLEDevice {
    func getDeviceId() -> String
    func getDeviceName() -> String
}


public protocol HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int)
}

public protocol CyclingSpeedCadenceMeasurementDelegate {
    func notifySpeed(speed: Double)
    func notifyCrankRPM(crankRPM: Int)
    func notifyWheelRevolutions(wheelRev: Int)
    func notifyWheelRPM(wheelRPM: Int)
    func notifyDistance(dist: Double)
}

public protocol PowerMeterMeasurementDelegate {
    func notifyPower(power: Int)
    func notifyBalance(power: Int)
    func notifyCrankRPM(crankRPM: Int)
}

public final class BicycleBLEKit {

    private let queue = DispatchQueue(label: "BicycleBLEKit")
    
    private var heartRateService: HeartRateService
    private var cscService: CyclingSpeedCadenceService
    private var powerService: PowerMeterService
    
    public init() {
        heartRateService = HeartRateService()
        cscService = CyclingSpeedCadenceService()
        powerService = PowerMeterService()
    }
    
    public func scanForHeartRateDevices() {
        heartRateService.startScan(queue: queue)
    }
    
    public func getHeartRateDevices() -> [BLEDevice] {
        return heartRateService.getDevices()
    }
    
    public func listenToHeartRateService(deviceId: String, delegate: HeartRateMeasurementDelegate) {
        heartRateService.measurementDelegate = delegate
        heartRateService.connect(deviceId: deviceId, queue: queue)
    }
    
    public func stopHeartRateService() {
        heartRateService.disconnect()
    }

    public func scanCSCDevices() {
        cscService.startScan(queue: queue)
    }

    public func getCSCDevices() -> [BLEDevice] {
        return cscService.getDevices()
    }
    
    public func listenToCSCService(deviceId: String, wheelSize: Int, delegate: CyclingSpeedCadenceMeasurementDelegate) {
        cscService.setWheelSize(wheelSize: wheelSize)
        cscService.measurementDelegate = delegate
        cscService.connect(deviceId: deviceId, queue: queue)
    }
    
    public func stopCSCService() {
        cscService.disconnect()
    }

    public func scanPowerDevices() {
        powerService.startScan(queue: queue)
    }

    public func getPowerDevices() -> [BLEDevice] {
        return powerService.getDevices()
    }
    
    public func listenToPowerService(deviceId: String, delegate: PowerMeterMeasurementDelegate) {
        powerService.measurementDelegate = delegate
        powerService.connect(deviceId: deviceId, queue: queue)
    }
    
    public func stopPowerService() {
        powerService.disconnect()
    }
    
    public func stopAll() {
        heartRateService.disconnect()
        cscService.disconnect()
        powerService.disconnect()
    }
    
}
