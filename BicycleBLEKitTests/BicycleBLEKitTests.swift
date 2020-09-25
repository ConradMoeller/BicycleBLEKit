//
//  BicycleBLEKitTests.swift
//  BicycleBLEKitTests
//
//  Created by Conrad Moeller on 23.09.20.
//  Copyright © 2020 Conrad Moeller. All rights reserved.
//

import XCTest
@testable import BicycleBLEKit

class BicycleBLEKitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testByteUtil() {
        
        var byte: UInt8 = 0b00000001
        XCTAssertTrue(ByteUtil.isSet(oneByte: byte, index: 0))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 1))
        byte = 0b10010001
        XCTAssertTrue(ByteUtil.isSet(oneByte: byte, index: 0))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 1))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 2))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 3))
        XCTAssertTrue(ByteUtil.isSet(oneByte: byte, index: 4))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 5))
        XCTAssertFalse(ByteUtil.isSet(oneByte: byte, index: 6))
        XCTAssertTrue(ByteUtil.isSet(oneByte: byte, index: 7))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
