//
//  ByteUtil.swift
//  conRadAnalyzer
//
//  Created by Conrad Moeller on 13.09.19.
//  Copyright © 2019 Conrad Moeller. All rights reserved.
//

import Foundation

enum Bit: UInt8, CustomStringConvertible {
    case zero, one
    
    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}

class ByteUtil {
    
    static func isSet(oneByte: UInt8, index: Int) -> Bool {
        
        if index < 0 || index > 7 {
            return false
        }
        let bitArray = bits(fromByte: oneByte)
        return bitArray[index] == .one
    }
    
    private static func bits(fromByte byte: UInt8) -> [Bit] {
        
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        for i in 0 ..< 8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
                bits[i] = .one
            }
            byte >>= 1
        }
        return bits
    }
    
    static func readUInt8(data: NSData, start: Int) -> Int {
        var d: UInt8 = 0
        data.getBytes(&d, range: NSRange(location: start, length: 1))
        return Int(d)
    }
    
    static func readUInt12(data: NSData, start: Int) -> Int {
        var d: UInt16 = 0
        data.getBytes(&d, range: NSRange(location: start, length: 3))
        return Int(d)
    }
    
    static func readUInt16(data: NSData, start: Int) -> Int {
        var d: UInt16 = 0
        data.getBytes(&d, range: NSRange(location: start, length: 2))
        return Int(d)
    }
    
    static func readUInt32(data: NSData, start: Int) -> UInt32 {
        var d: UInt32 = 0
        data.getBytes(&d, range: NSRange(location: start, length: 4))
        return d
    }
    
    static func bytesConvertToHexstring(bytes: [UInt8]) -> String {
        var string = "< "
        for val in bytes {
            string = string + String(format: "%02X ", val)
        }
        return string + ">"
    }
    
}
