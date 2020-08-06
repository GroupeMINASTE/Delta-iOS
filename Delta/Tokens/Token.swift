//
//  Token.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

protocol Token {
    
    func toString() -> String
    func compute(with inputs: [String: Token], format: Bool) -> Token
    func apply(operation: Operation, right: Token, with inputs: [String: Token], format: Bool) -> Token
    func needBrackets(for operation: Operation) -> Bool
    func getMultiplicationPriority() -> Int
    func opposite() -> Token
    func inverse() -> Token
    func equals(_ right: Token) -> Bool
    func asDouble() -> Double?
    func getSign() -> FloatingPointSign
    
}

extension Token {
    
    func defaultApply(operation: Operation, right: Token, with inputs: [String : Token], format: Bool) -> Token {
        // Compute right
        let right = right.compute(with: inputs, format: format)
        
        // Sum
        if operation == .addition {
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: right.values + [self])
            }
            
            // Left and right are the same
            if equals(right) {
                return Product(values: [self, Number(value: 2)]).compute(with: inputs, format: format)
            }
            
            return Sum(values: [self, right])
        }
        
        // Difference
        if operation == .subtraction {
            return Sum(values: [self, right.opposite()]).compute(with: inputs, format: format)
        }
        
        // Product
        if operation == .multiplication {
            // Right is a product
            if let right = right as? Product {
                return Product(values: right.values + [self])
            }
            
            // Left and right are the same
            if equals(right) {
                return Power(token: self, power: Number(value: 2)).compute(with: inputs, format: format)
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
            
            return Product(values: [self, right])
        }
        
        // Fraction
        if operation == .division {
            // Left and right are products
            let left = self as? Product ?? Product(values: [self])
            let right = right as? Product ?? Product(values: [right])
            
            // Check for common factor
            var leftValues = left.values
            var rightValues = right.values
            var leftIndex = 0
            while leftIndex < leftValues.count {
                // Iterate right values
                var rightIndex = 0
                while rightIndex < rightValues.count {
                    // Check if left and right are the same
                    if leftValues[leftIndex].equals(rightValues[rightIndex]) {
                        // We have a common factor
                        leftValues[leftIndex] = Number(value: 1)
                        rightValues[rightIndex] = Number(value: 1)
                    }
                    
                    // Check if both are numbers with gcd != 1
                    if let leftNumber = leftValues[leftIndex] as? Number, let rightNumber = rightValues[rightIndex] as? Number {
                        let gcd = leftNumber.value.greatestCommonDivisor(with: rightNumber.value)
                        if gcd != 1 {
                            // We have a common factor
                            leftValues[leftIndex] = Number(value: leftNumber.value / gcd)
                            rightValues[rightIndex] = Number(value: rightNumber.value / gcd)
                        }
                    }
                    
                    // Increment
                    rightIndex += 1
                }
                
                // Increment
                leftIndex += 1
            }
            
            // Return the fraction
            return Fraction(numerator: Product(values: leftValues).compute(with: inputs, format: format), denominator: Product(values: rightValues).compute(with: inputs, format: format))
        }
        
        // Modulo
        if operation == .modulo {
            // Return the modulo
            return Modulo(dividend: self, divisor: right)
        }
        
        // Power
        if operation == .power {
            // Return the power
            return Power(token: self, power: right)
        }
        
        // Root
        if operation == .root {
            return Root(token: self, power: right)
        }
        
        // Unknown, return a calcul error
        return CalculError()
    }
    
    func defaultEquals(_ right: Token) -> Bool {
        // Compare value (if possible)
        if let leftDouble = asDouble(), let rightDouble = right.asDouble() {
            return leftDouble == rightDouble
        }
        
        // Compare string
        return toString() == right.toString()
    }
    
}
