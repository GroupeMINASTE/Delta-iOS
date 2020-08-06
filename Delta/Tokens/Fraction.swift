//
//  Fraction.swift
//  Delta
//
//  Created by Nathan FALLET on 09/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Fraction: Token {
    
    var numerator: Token
    var denominator: Token
    
    func toString() -> String {
        if let number = numerator as? Number, let powerOfTen = denominator as? Number, powerOfTen.value.isPowerOfTen() {
            // Print it as decimal
            return "\(Double(number.value)/Double(powerOfTen.value))"
        }
        
        // Print it as a fraction
        return "\(numerator.needBrackets(for: .division) ? "(\(numerator.toString()))" : numerator.toString()) / \(denominator.needBrackets(for: .division) ? "(\(denominator.toString()))" : denominator.toString())"
    }
    
    func compute(with inputs: [String : Token], format: Bool) -> Token {
        let numerator = self.numerator.compute(with: inputs, format: format)
        let denominator = self.denominator.compute(with: inputs, format: format)
        
        // Check numerator
        if let number = numerator as? Number {
            // 0/x is 0
            if number.value == 0 {
                return number
            }
        }
        
        // Check denominator
        if let number = denominator as? Number {
            // x/1 is x
            if number.value == 1 {
                return numerator
            }
            
            // x/0 is calcul error
            if number.value == 0 {
                return CalculError()
            }
        }
        
        // Apply to simplify
        return numerator.apply(operation: .division, right: denominator, with: inputs, format: format)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], format: Bool) -> Token {
        // Compute right
        let right = right.compute(with: inputs, format: format)
        
        // If addition
        if operation == .addition {
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: right.values + [self])
            }
            
            // If we keep format
            if format {
                return Sum(values: [self, right])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b + c/d = (ad+cb)/bd
                return Fraction(numerator: Sum(values: [Product(values: [self.numerator, right.denominator]), Product(values: [right.numerator, self.denominator])]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, format: format)
            }
            
            // Right is anything else
            // a/b + c = (a+cb)/b
            return Fraction(numerator: Sum(values: [self.numerator, Product(values: [right, self.denominator])]), denominator: denominator).compute(with: inputs, format: format)
        }
        
        // If subtraction
        if operation == .subtraction {
            // If we keep format
            if format {
                return Sum(values: [self, right.opposite()])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b - c/d = (ad-cb)/bd
                return Fraction(numerator: Sum(values: [Product(values: [self.numerator, right.denominator]), Product(values: [right.numerator, self.denominator]).opposite()]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, format: format)
            }
            
            // Right is anything else
            // a/b - c = (a-cb)/b
            return Fraction(numerator: Sum(values: [self.numerator, Product(values: [right, self.denominator]).opposite()]), denominator: denominator).compute(with: inputs, format: format)
        }
        
        // If product
        if operation == .multiplication {
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
                // a/b * c/d = ac/bd
                return Fraction(numerator: Product(values: [self.numerator, right.numerator]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, format: format)
            }
            
            // Right is anything else
            // a/b * c = ac/b
            return Fraction(numerator: Product(values: [right, self.numerator]), denominator: denominator).compute(with: inputs, format: format)
        }
        
        // If fraction
        if operation == .division {
            // If we keep format
            if format {
                return Fraction(numerator: self, denominator: right)
            }
            
            // Multiply by its inverse
            return Product(values: [self, right.inverse()]).compute(with: inputs, format: format)
        }
        
        // Power
        if operation == .power {
            // If we keep format
            if format {
                return Power(token: self, power: right)
            }
            
            // Apply power to numerator and denominator
            return Fraction(numerator: Power(token: numerator, power: right), denominator: Power(token: denominator, power: right)).compute(with: inputs, format: format)
        }
        
        // Root
        if operation == .root {
            // If we keep format
            if format {
                return Root(token: self, power: right)
            }
            
            // Apply root to numerator and denominator
            return Fraction(numerator: Root(token: numerator, power: right), denominator: Root(token: denominator, power: right)).compute(with: inputs, format: format)
        }
        
        // Delegate to default
        return defaultApply(operation: operation, right: right, with: inputs, format: format)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return operation.getPrecedence() >= Operation.division.getPrecedence()
    }
    
    func getMultiplicationPriority() -> Int {
        return 1
    }
    
    func opposite() -> Token {
        return Fraction(numerator: Product(values: [Number(value: -1), numerator]), denominator: denominator).compute(with: [:], format: false)
    }
    
    func inverse() -> Token {
        return Fraction(numerator: denominator, denominator: numerator).compute(with: [:], format: false)
    }
    
    func equals(_ right: Token) -> Bool {
        return defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        if let numerator = numerator.asDouble(), let denominator = denominator.asDouble() {
            return numerator/denominator
        }
        
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }
    
}
