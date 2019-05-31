//
//  Console.swift
//  ConsoleSend
//
//  Created by Ruben Fernandez on 31/05/2019.
//

import Foundation

class Console {
    
    static func readString() -> String {
        return readLine() ?? ""
    }
    
    static func readInt() -> Int {
        while true {
            if let number = Int(readLine() ?? "") {
                return number
            }
        }
    }
    
    static func readInt(min: Int, max: Int) -> Int {
        while true {
            if let number = Int(readLine() ?? ""), number >= min, number <= max {
                return number
            }
        }
    }
    
}
