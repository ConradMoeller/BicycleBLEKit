//
//  HeartRateService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int)
}

class HeartRateService: BLEService {
    
    var measurementDelegate: HeartRateMeasurementDelegate!
    
    init(deviceId: String) {
        super.init(serviceId: "0x180D", characteristicId: "2A37", deviceId: deviceId);
        delegate = self
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
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}
