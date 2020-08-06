//
//  Variable.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Variable: Token {

    var name: String

    func toString() -> String {
        return name
    }
    
    func compute(with inputs: [String: Token], mode: ComputeMode) -> Token {
        // Chech if an input corresponds to this variable
        if let value = inputs[name] {
            return value.compute(with: inputs, mode: .simplify)
        }
        
        // No input found
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], mode: ComputeMode) -> Token {
        // Compute right
        let right = right.compute(with: inputs, mode: mode)
        
        // Power
        if operation == .power {
            // Check for i
            if name == "i" {
                // If right is a number
                if let number = right as? Number {
                    // i^0 = 1
                    if number.value % 4 == 0 {
                        return Number(value: 1)
                    }
                    // i^2 = -1
                    if number.value % 4 == 2 {
                        return Number(value: -1)
                    }
                    // i^3 = -i
                    if number.value % 4 == 3 {
                        return Product(values: [Number(value: -1), self])
                    }
                    // Simplificated power of i
                    return Power(token: self, power: Number(value: number.value % 4)).compute(with: inputs, mode: mode)
                }
            }
            // Check for e
            if name == "e" {
                // If right is a number
                if let number = right as? Number {
                    // e^0 = 1
                    if number.value == 0 {
                        return Number(value: 1)
                    }
                }
            }
            
            return Power(token: self, power: right)
        }
        
        // Delegate to default
        return defaultApply(operation: operation, right: right, with: inputs, mode: mode)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return 2
    }
    
    func opposite() -> Token {
        return Product(values: [self, Number(value: -1)])
    }
    
    func inverse() -> Token {
        return Fraction(numerator: Number(value: 1), denominator: self)
    }
    
    func equals(_ right: Token) -> Bool {
        return defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        // Exp
        if name == "e" {
            // give an aproximated value
            return exp(1)
        }
        // Pi
        if name == "π" {
            // Value of pi
            return Double.pi
        }
        
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }

}
