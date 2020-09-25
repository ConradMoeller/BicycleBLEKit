//
//  PowerMeterService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 25.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import CoreBluetooth

protocol PowerMeterMeasurementDelegate {
    func notifyPower(power: Int)
    func notifyBalance(power: Int)
    func notifyCrankRPM(crankRPM: Int)
}

class PowerMeterService: BLEService {

    private var power = 0
    private var balance = 0
    private var rpm = 0
    
    private var previousCrankRevolutionCount: Int = 0
    private var previousCrankEvent: Int = 0
    private var previousRPM = 0
    
    var measurementDelegate: PowerMeterMeasurementDelegate!

    init(deviceId: String) {
        super.init(serviceId: "0x1818", characteristicId: "2A63", deviceId: deviceId)
        delegate = self
    }
}

extension PowerMeterService: BLEServiceDelegate {

    func notify(characteristic: CBCharacteristic) {
        readMetrics(from: characteristic)
    }

    private func readMetrics(from characteristic: CBCharacteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        var rpmOffset = 0
        var factor = 0
        var test = byteArray[0] & 0b1
        let p = ByteUtil.readUInt16(data: characteristicData as NSData, start: 2)
        if test == 0b1 {
            rpmOffset = 1
            factor = 1
            balance = ByteUtil.readUInt8(data: characteristicData as NSData, start: 4) / 2
        } else {
            rpmOffset = 0
            factor = 2
            balance = 50
        }
        test = byteArray[0] & 0b100000
        var r = 1
        if test == 0b100000 {
            var crankRevolutions: Int = 0
            var crankEvent: Int = 0
            crankRevolutions = ByteUtil.readUInt16(data: characteristicData as NSData, start: 4 + rpmOffset)
            crankEvent = ByteUtil.readUInt16(data: characteristicData as NSData, start: 6 + rpmOffset)
            r = calculateCrankRPM(currentCrankRevolutionCount: crankRevolutions, rawCrankEvent: crankEvent)
            rpm = r
        }
        if r > 0 {
            power = p * factor
        } else {
            power = 0
        }
    }

    private func calculateCrankRPM(currentCrankRevolutionCount: Int, rawCrankEvent: Int) -> Int {
        if previousCrankRevolutionCount == 0 {
            self.previousCrankRevolutionCount = currentCrankRevolutionCount
            self.previousCrankEvent = rawCrankEvent
            return 0
        }
        var deltaCE = rawCrankEvent - self.previousCrankEvent
        if deltaCE == 0 {
            let d = previousRPM
            previousRPM = 0
            return d
        }
        if deltaCE < 0 {
            deltaCE = rawCrankEvent + 0xffff - self.previousCrankEvent
        }
        let rpm = Int((Double(currentCrankRevolutionCount - self.previousCrankRevolutionCount) / (Double(deltaCE) / 1024)) * 60)
        self.previousCrankRevolutionCount = currentCrankRevolutionCount
        self.previousCrankEvent = rawCrankEvent
        self.previousRPM = rpm
        return rpm
    }
}
