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
    
    func compute(with inputs: [String: Token], format: Bool) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], format: Bool) -> Token {
        // Compute right
        let right = right.compute(with: inputs, format: format)
        
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
            
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: right.values + [self])
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
            
            // Right is a product
            if let right = right as? Product {
                return Product(values: right.values + [self])
            }
            
            // If we keep format
            if format {
                return Product(values: [self, right])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b * c = ac/b
                return Fraction(numerator: Product(values: [self, right.numerator]), denominator: right.denominator).compute(with: inputs, format: format)
            }
            
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: right.values.map{ Product(values: [$0, self]) }).compute(with: inputs, format: format)
            }
            
            // Right is a vector
            if let right = right as? Vector {
                return right.apply(operation: operation, right: self, with: inputs, format: format)
            }
            
            // Return the product
            return Product(values: [self, right])
        }
        
        // Fraction
        if operation == .division {
            // If value is 0
            if value == 0 && right as? Number == nil {
                // 0 / x is 0
                return self
            }
            
            // Rigth is number
            if let right = right as? Number {
                // If right is 0
                if right.value == 0 {
                    // x/0 is calcul error
                    return CalculError()
                }
                
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
        
        // Modulo
        if operation == .modulo {
            // Rigth is number
            if let right = right as? Number {
                // If right is 0
                if right.value == 0 {
                    // x/0 is calcul error
                    return CalculError()
                }
                
                return Number(value: self.value % right.value)
            }
            
            // Return the modulo
            return Modulo(dividend: self, divisor: right)
        }
        
        // Power
        if operation == .power {
            // Rigth is number
            if let right = right as? Number {
                // 0^0 is calcul error
                if value == 0 && right.value == 0 {
                    return CalculError()
                }
                
                // Apply power to number
                if right.value >= 0 {
                    return Number(value: Int(pow(Double(self.value), Double(right.value))))
                } else {
                    return Number(value: Int(pow(Double(self.value), Double(-right.value)))).inverse()
                }
            }
            
            // Return the power
            return Power(token: self, power: right)
        }
        
        // Root
        if operation == .root {
            // Apply root
            if let power = right as? Number {
                // Check sign
                if value >= 0 {
                    // Positive
                    let value = pow(Double(self.value), 1/Double(power.value))
                    
                    if value == .infinity || value.isNaN {
                        // Calcul error
                        return CalculError()
                    } else if value == floor(value) {
                        // Simplified root
                        return Number(value: Int(value))
                    }
                } else {
                    // Negative
                    let value = pow(Double(-self.value), 1/Double(power.value))
                    
                    if value == .infinity || value.isNaN {
                        // Calcul error
                        return CalculError()
                    } else if value == floor(value) {
                        // Simplified root
                        return Product(values: [Number(value: Int(value)), Variable(name: "i")])
                    } else {
                        // Root of negative as i * sqrt(-value)
                        return Product(values: [Root(token: Number(value: -self.value), power: right), Variable(name: "i")])
                    }
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
    
    func asDouble() -> Double? {
        return Double(value)
    }
    
    func getSign() -> FloatingPointSign {
        return value >= 0 ? .plus : .minus
    }
    
}
