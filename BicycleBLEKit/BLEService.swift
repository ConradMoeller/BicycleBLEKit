//
//  BLEService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 12.11.18.
//  Copyright © 2018 Conrad Moeller. All rights reserved.
//

import CoreBluetooth

protocol BLEServiceDelegate: class {
    func connected()
    func notify(characteristic: CBCharacteristic)
}

class BLEService: NSObject {

    static let battery_service = "0x180F"
    static let battery_level = "2A19"

    var delegate: BLEServiceDelegate?

    private var serviceUUID: CBUUID
    private var characteristicUUID: CBUUID
    var deviceId: String!

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!

    var batteryLevel = UInt8(0)

    private var wasConnected = false

    init(serviceId: String, characteristicId: String, deviceId: String) {
        serviceUUID = CBUUID(string: serviceId)
        characteristicUUID = CBUUID(string: characteristicId)
        self.deviceId = deviceId
    }

    func connect() {
        connect(queue: nil)
    }

    func connect(queue: DispatchQueue?) {
        if !isDeviceConnected() {
            wasConnected = false
            centralManager = CBCentralManager(delegate: self, queue: queue)
        }
    }

    func disconnect() {
        if isDeviceConnected() {
            centralManager.cancelPeripheralConnection(peripheral)
            wasConnected = false
        }
    }

    func isDeviceConnected() -> Bool {
        if centralManager == nil || peripheral == nil || characteristic == nil {
            return false
        }
        if peripheral.state == .connected {
            return true
        } else {
            return false
        }
    }

    func didDeviceLostConnection() -> Bool {
        if !wasConnected {
            return false
        }
        return !isDeviceConnected()
    }

    func stopScan() {
        if centralManager != nil {
            centralManager.stopScan()
            centralManager = nil
            if peripheral != nil {
                peripheral.delegate = nil
            }
            peripheral = nil
            characteristic = nil
        }
    }

    func writeValue(value: Data) {
        if isDeviceConnected() {
            peripheral?.writeValue(value, for: characteristic!, type: .withoutResponse)
        }
    }

    func getBatteryLevel() -> UInt8 {
        return batteryLevel
    }
}

extension BLEService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if deviceId == peripheral.identifier.uuidString {
            self.peripheral = peripheral
            peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral)
            wasConnected = true
            delegate?.connected()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID(string: BLEService.battery_service), serviceUUID])
    }

}

extension BLEService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: BLEService.battery_level), characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        if service.uuid == CBUUID(string: BLEService.battery_service) {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: BLEService.battery_level) {
                    peripheral.readValue(for: characteristic)
                }
            }
        } else {
            for characteristic in characteristics {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            return
        }
        switch characteristic.uuid {
        case characteristicUUID:
            if delegate != nil {
                delegate?.notify(characteristic: characteristic)
            }
        case CBUUID(string: BLEService.battery_level):
            batteryLevel = (characteristic.value?.first)!
        default:
            ()
        }
    }

}
