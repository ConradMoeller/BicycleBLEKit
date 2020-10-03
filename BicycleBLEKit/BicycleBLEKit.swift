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

public protocol BLEDeviceDiscoverDelegate {
    func deviceDiscovered(device: BLEDevice)
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
    
    public func isHearRateDeviceConnected() -> Bool {
        return heartRateService.isDeviceConnected()
    }
    
    public func startScanHeartRateDevices(deviceDiscoverDelegate: BLEDeviceDiscoverDelegate) {
        heartRateService.deviceDiscovered = deviceDiscoverDelegate
        heartRateService.startScan(queue: nil)
    }
    
    public func stopScanHeartRateDevices() {
        heartRateService.stopScan()
    }
    
    public func startListenToHeartRateService(deviceId: String, delegate: HeartRateMeasurementDelegate) {
        heartRateService.measurementDelegate = delegate
        heartRateService.connect(deviceId: deviceId, queue: queue)
    }
    
    public func stopListenHeartRateService() {
        heartRateService.disconnect()
    }

    public func isCSCDeviceConnected() -> Bool {
        return cscService.isDeviceConnected()
    }

    public func startScanCSCDevices(deviceDiscoverDelegate: BLEDeviceDiscoverDelegate) {
        cscService.deviceDiscovered = deviceDiscoverDelegate
        cscService.startScan(queue: nil)
    }
    
    public func stopScanCSCDevices() {
        cscService.stopScan()
    }

    public func startListenToCSCService(deviceId: String, wheelSize: Int, delegate: CyclingSpeedCadenceMeasurementDelegate) {
        cscService.setWheelSize(wheelSize: wheelSize)
        cscService.measurementDelegate = delegate
        cscService.connect(deviceId: deviceId, queue: queue)
    }
    
    public func startListenToCSCService() {
        cscService.disconnect()
    }
    
    public func stopListenCSCService() {
        cscService.disconnect()
    }
    
    public func isPowerDeviceConnected() -> Bool {
        return powerService.isDeviceConnected()
    }

    public func startScanPowerDevices(deviceDiscoverDelegate: BLEDeviceDiscoverDelegate) {
        powerService.deviceDiscovered = deviceDiscoverDelegate
        powerService.startScan(queue: nil)
    }
    
    public func stopScanPowerDevices() {
        powerService.stopScan()
    }
    
    public func startListenToPowerService(deviceId: String, delegate: PowerMeterMeasurementDelegate) {
        powerService.measurementDelegate = delegate
        powerService.connect(deviceId: deviceId, queue: queue)
    }
    public func stopListenToPowerService() {
        powerService.disconnect()
    }
    
    public func stopAll() {
        heartRateService.disconnect()
        cscService.disconnect()
        powerService.disconnect()
    }
    
}
