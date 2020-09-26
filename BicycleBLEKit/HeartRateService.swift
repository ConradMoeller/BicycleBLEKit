//
//  HeartRateService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation
import CoreBluetooth

class HeartRateService: BLEService {
    
    var measurementDelegate: HeartRateMeasurementDelegate!
        
    override init() {
        super.init()
        delegate = self
    }
    
    override func getServiceUUID() -> String {
        return "0x180D"
    }
    
    override func getCharacteristicUUID() -> String {
        return "2A37"
    }

    
    
}
    
extension HeartRateService: BLEServiceDelegate {

    func notify(characteristic: CBCharacteristic) {
        if measurementDelegate != nil {
            measurementDelegate.notifyHeartRate(bpm: heartRate(from: characteristic))
        }
    }

    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        let ch = HeartRateCharacteristics(byteArray: byteArray)
        return ch.getHeartRate()
    }
}

class HeartRateCharacteristics {
    
    private let byteArray: [UInt8]
    
    init(byteArray: [UInt8]) {
        self.byteArray = byteArray
    }
    
    func getHeartRate() -> Int {
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}
