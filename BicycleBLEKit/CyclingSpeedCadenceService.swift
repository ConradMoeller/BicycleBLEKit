//
//  CyclingSpeedCadenceService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 25.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import CoreBluetooth

class CyclingSpeedCadenceService: BLEService {

    private var lastSpeedCalculation = Date(timeIntervalSince1970: 0)
    private var wheelSize = 0

    private var speed = 0.0
    private var crankRPM = 0
    private var distance = 0.0
    private var wheelRPM = 0
    private var wheelRevolutions = 0
    
    
    private var previousWheelRevolutionCount: UInt32 = 0
    private var previousWheelEvent: Int = 0
    private var wheelRevolutionsData = 0

    private var previousCrankRevolutionCount: Int = 0
    private var previousCrankEvent: Int = 0

    var measurementDelegate: CyclingSpeedCadenceMeasurementDelegate!
    
    override init() {
        super.init()
        delegate = self
    }
    
    override func getServiceUUID() -> String {
        return "0x1816"
    }
    
    override func getCharacteristicUUID() -> String {
        return "2A5B"
    }
    
    func setWheelSize(wheelSize: Int) {
        self.wheelSize = wheelSize
    }

}

extension CyclingSpeedCadenceService: BLEServiceDelegate {

    func notify(characteristic: CBCharacteristic) {
        readMetrics(from: characteristic)
        if measurementDelegate != nil {
            measurementDelegate.notifySpeed(speed: speed)
            measurementDelegate.notifyDistance(dist: distance)
            measurementDelegate.notifyWheelRPM(wheelRPM: wheelRPM)
            measurementDelegate.notifyWheelRevolutions(wheelRev: wheelRevolutions)
            measurementDelegate.notifyCrankRPM(crankRPM: crankRPM)
        }
    }

    private func readMetrics(from characteristic: CBCharacteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        let speedTest = byteArray[0] & UInt8(1)
        if speedTest == 1 {
            var wheelRevolutions: UInt32 = 0
            var wheelEvent: Int = 0
            wheelRevolutions = ByteUtil.readUInt32(data: characteristicData as NSData, start: 1)
            wheelEvent = ByteUtil.readUInt16(data: characteristicData as NSData, start: 5)
            speed = calculateSpeed(currentWheelRevolutionCount: wheelRevolutions, rawWheelEvent: wheelEvent)
        }
        let cadTest = byteArray[0] & UInt8(2)
        if cadTest == 2 {
            var crankRevolutions: Int = 0
            var crankEvent: Int = 0
            crankRevolutions = ByteUtil.readUInt16(data: characteristicData as NSData, start: 7)
            crankEvent = ByteUtil.readUInt16(data: characteristicData as NSData, start: 9)
            crankRPM = calculateCrankRPM(currentCrankRevolutionCount: crankRevolutions, rawCrankEvent: crankEvent)
        }
    }

    private func calculateSpeed(currentWheelRevolutionCount: UInt32, rawWheelEvent: Int) -> Double {
        if previousWheelRevolutionCount == 0 {
            previousWheelRevolutionCount = currentWheelRevolutionCount
            previousWheelEvent = rawWheelEvent
            return 0
        }
        var deltaWE = rawWheelEvent - previousWheelEvent
        var deltaWRC = currentWheelRevolutionCount - previousWheelRevolutionCount
        wheelRevolutions = Int(deltaWRC)
        if deltaWE == 0 && deltaWRC == 0 {
            if abs(lastSpeedCalculation.timeIntervalSinceNow) < 1.1 {
                return speed
            } else {
                return 0.0
            }
        }
        if deltaWE <= 0 {
            deltaWE = rawWheelEvent + 0xffff - previousWheelEvent
        }
        if deltaWRC <= 0 {
            deltaWRC = currentWheelRevolutionCount + 0xffffffff - previousWheelRevolutionCount
        }
        if deltaWE == 0 {
            deltaWE = 1024
        }
        wheelRPM = Int((Double(deltaWRC) / (Double(deltaWE) / 1024)) * 60)
        speed = Double(deltaWRC) * Double(wheelSize) * 0.001 / (Double(deltaWE) / 1024)
        previousWheelRevolutionCount = currentWheelRevolutionCount
        previousWheelEvent = rawWheelEvent
        lastSpeedCalculation = Date()
        return speed
    }

    private func calculateCrankRPM(currentCrankRevolutionCount: Int, rawCrankEvent: Int) -> Int {
        if previousCrankRevolutionCount == 0 {
            self.previousCrankRevolutionCount = currentCrankRevolutionCount
            self.previousCrankEvent = rawCrankEvent
            return 0
        }
        var deltaCE = rawCrankEvent - self.previousCrankEvent
        if deltaCE == 0 {
            return 0
        }
        if deltaCE < 0 {
            deltaCE = rawCrankEvent + 0xffff - self.previousCrankEvent
        }
        let rpm = Int((Double(currentCrankRevolutionCount - self.previousCrankRevolutionCount) / (Double(deltaCE) / 1024)) * 60)
        self.previousCrankRevolutionCount = currentCrankRevolutionCount
        self.previousCrankEvent = rawCrankEvent
        return rpm
    }
}
