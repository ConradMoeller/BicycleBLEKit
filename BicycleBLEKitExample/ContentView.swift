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
        print(kit.scanForHeartRateDevices())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
