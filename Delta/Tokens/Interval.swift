//
//  Interval.swift
//  Delta
//
//  Created by Nathan FALLET on 16/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Interval: Token {
    
    var left: Token
    var right: Token
    var left_closed: Bool
    var right_closed: Bool
    
    func toString() -> String {
        return "\(left_closed ? "[" : "]")\(left.toString()), \(right.toString())\(right_closed ? "]" : "[")"
    }
    
    func compute(with inputs: [String: Token], mode: ComputeMode) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], mode: ComputeMode) -> Token {
        // Compute right
        //let right = right.compute(with: inputs)
        
        // Unknown, return a calcul error
        return CalculError()
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return 1
    }
    
    func opposite() -> Token {
        // Unknown
        return self
    }
    
    func inverse() -> Token {
        // Unknown
        return self
    }
    
    func equals(_ right: Token) -> Bool {
        return defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }
    
}
