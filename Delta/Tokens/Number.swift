//
//  Number.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Number: Token {
    
    var value: Int
    
    func toString() -> String {
        return "\(value)"
    }
    
    func compute(with inputs: [String: Token]) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token]) -> Token {
        // Compute right
        let right = right.compute(with: inputs)
        
        // Sum
        if operation == .addition {
            // If value is 0
            if value == 0 {
                // 0 + x is x
                return right
            }
            
            // Rigth is number
            if let right = right as? Number {
                return Number(value: self.value + right.value)
            }
            
            // Return the sum
            return Sum(values: [self, right])
        }
        
        // Difference
        if operation == .subtraction {
            // If value is 0
            if value == 0 {
                // 0 - x is - x
                return right.opposite()
            }
            
            // Rigth is number
            if let right = right as? Number {
                return Number(value: self.value - right.value)
            }
            
            // Return the sum
            return Sum(values: [self, right.opposite()])
        }
        
        // Product
        if operation == .multiplication {
            // If value is 1
            if value == 1 {
                // It's 1 time right, return right
                return right
            }
            
            // If value is 0
            if value == 0 {
                // 0 * x is 0
                return self
            }
            
            // Rigth is number
            if let right = right as? Number {
                return Number(value: self.value * right.value)
            }
            
            // Right is a vector
            if let right = right as? Vector {
                return right.apply(operation: operation, right: self, with: inputs)
            }
            
            // Return the product
            return Product(values: [self, right])
        }
        
        // Fraction
        if operation == .division {
            // If value is 0
            if value == 0 {
                // 0 / x is 0
                return self
            }
            
            // Rigth is number
            if let right = right as? Number {
                // Multiple so division is an integer
                if self.value.isMultiple(of: right.value) {
                    return Number(value: self.value / right.value)
                }
                
                // Get the greatest common divisor
                let gcd = self.value.greatestCommonDivisor(with: right.value)
                
                // If it's greater than one
                if gcd > 1 {
                    let numerator = self.value / gcd
                    let denominator = right.value / gcd
                    
                    // Return simplified fraction
                    return Fraction(numerator: Number(value: numerator), denominator: Number(value: denominator))
                }
            }
            
            // Return the fraction
            return Fraction(numerator: self, denominator: right)
        }
        
        // Power
        if operation == .power {
            // Rigth is number
            if let right = right as? Number {
                return Number(value: Int(pow(Double(self.value), Double(right.value))))
            }
            
            // Return the power
            return Power(token: self, power: right)
        }
        
        // Root
        if operation == .root {
            // Apply root
            if let power = right as? Number {
                let value = pow(Double(self.value), 1/Double(power.value))
                
                if value == .infinity || value.isNaN {
                    return CalculError()
                } else if value == floor(value) {
                    return Number(value: Int(value))
                }
            }
            
            // Return root
            return Root(token: self, power: right)
        }
        
        // Unknown, return a calcul error
        return CalculError()
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return 3
    }
    
    func opposite() -> Token {
        return Number(value: -value)
    }
    
    func inverse() -> Token {
        return Fraction(numerator: Number(value: 1), denominator: self)
    }
    
    func getSign() -> FloatingPointSign {
        return value >= 0 ? .plus : .minus
    }
    
}
