//
//  BicycleBLEKit.swift
//  BicycleBLEKit
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import Foundation

public protocol HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int)
}

public final class BicycleBLEKit {

    private var heartRateService: HeartRateService!
    
    public init() {
        
    }
    
    public func listenToHeartRateService(deviceId: String, delegate: HeartRateMeasurementDelegate) {
        heartRateService = HeartRateService(deviceId: deviceId)
        heartRateService.connect()
        heartRateService.measurementDelegate = delegate
    }
    
}
