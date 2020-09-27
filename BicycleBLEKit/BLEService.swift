//
//  BLEService.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import CoreBluetooth

protocol BLEServiceDelegate: class {
    func notify(characteristic: CBCharacteristic)
}

class BLEDeviceImpl: BLEDevice {
    
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    func getDeviceId() -> String {
        return id
    }
    
    func getDeviceName() -> String {
        return name
    }
}

class BLEService: NSObject {

    static let batteryService = "0x180F"
    static let batteryLevel = "2A19"

    var devices = [BLEDevice]()
    var scanCounter = 0
    
    var delegate: BLEServiceDelegate?

    private var serviceUUID: CBUUID!
    private var characteristicUUID: CBUUID!
    var deviceId: String!

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!

    var batteryLevel = UInt8(0)

    private var wasConnected = false
    
    func getServiceUUID() -> String {
        return ""
    }
    
    func getCharacteristicUUID() -> String {
        return ""
    }
    
    func getDevices() -> [BLEDevice] {
        return devices
    }

    func connect(deviceId: String, queue: DispatchQueue?) {
        serviceUUID = CBUUID(string: getServiceUUID())
        characteristicUUID = CBUUID(string: getCharacteristicUUID())
        self.deviceId = deviceId
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
    
    func startScan(queue: DispatchQueue?) {
        serviceUUID = CBUUID(string: getServiceUUID())
        scanCounter = 0
        devices.removeAll()
        if !isDeviceConnected() {
            wasConnected = false
            centralManager = CBCentralManager(delegate: self, queue: queue)
        }
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
        } else {
            scanCounter+=1
            if (!devices.contains(where: { (d) -> Bool in
                return d.getDeviceId() == peripheral.identifier.uuidString
            })) {
                devices.append(BLEDeviceImpl(id: peripheral.identifier.uuidString, name: peripheral.name!))
            }
            if scanCounter > 10 {
                stopScan()
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID(string: BLEService.batteryService), serviceUUID])
    }

}

extension BLEService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: BLEService.batteryLevel), characteristicUUID], for: service)
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        if service.uuid == CBUUID(string: BLEService.batteryService) {
            readBatteryLevel(characteristics, peripheral)
        } else {
            readAndSwitchOnNotification(characteristics, peripheral)
        }
    }
    
    fileprivate func readBatteryLevel(_ characteristics: [CBCharacteristic], _ peripheral: CBPeripheral) {
        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: BLEService.batteryLevel) {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    fileprivate func readAndSwitchOnNotification(_ characteristics: [CBCharacteristic], _ peripheral: CBPeripheral) {
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
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
        case CBUUID(string: BLEService.batteryLevel):
            batteryLevel = (characteristic.value?.first)!
        default:
            ()
        }
    }

}
