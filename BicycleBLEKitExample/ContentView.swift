//
//  ContentView.swift
//  BicycleBLEKitExample
//
//  Created by Conrad Moeller on 26.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import SwiftUI
import BicycleBLEKit

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
    
    func foo() {
        let kit = BicycleBLEKit()
        kit.scanForHeartRateDevices()
        sleep(10)
        let id = kit.getHeartRateDevices()[0].getDeviceId()
        kit.listenToHeartRateService(deviceId: id, delegate: HeartRateDel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class HeartRateDel: HeartRateMeasurementDelegate {
    func notifyHeartRate(bpm: Int) {
        print(bpm)
    }
}
