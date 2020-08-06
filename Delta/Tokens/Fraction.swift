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
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        let numerator = self.numerator.compute(with: inputs, mode: mode)
        let denominator = self.denominator.compute(with: inputs, mode: mode)
        
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
        return numerator.apply(operation: .division, right: denominator, with: inputs, mode: mode)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        // Compute right
        let right = right.compute(with: inputs, mode: mode)
        
        // If addition
        if operation == .addition {
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: right.values + [self])
            }
            
            // If we keep format
            if mode == .formatted {
                return Sum(values: [self, right])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b + c/d = (ad+cb)/bd
                return Fraction(numerator: Sum(values: [Product(values: [self.numerator, right.denominator]), Product(values: [right.numerator, self.denominator])]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, mode: mode)
            }
            
            // Right is anything else
            // a/b + c = (a+cb)/b
            return Fraction(numerator: Sum(values: [self.numerator, Product(values: [right, self.denominator])]), denominator: denominator).compute(with: inputs, mode: mode)
        }
        
        // If subtraction
        if operation == .subtraction {
            // If we keep format
            if mode == .formatted {
                return Sum(values: [self, right.opposite()])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b - c/d = (ad-cb)/bd
                return Fraction(numerator: Sum(values: [Product(values: [self.numerator, right.denominator]), Product(values: [right.numerator, self.denominator]).opposite()]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, mode: mode)
            }
            
            // Right is anything else
            // a/b - c = (a-cb)/b
            return Fraction(numerator: Sum(values: [self.numerator, Product(values: [right, self.denominator]).opposite()]), denominator: denominator).compute(with: inputs, mode: mode)
        }
        
        // If product
        if operation == .multiplication {
            // Right is a product
            if let right = right as? Product {
                return Product(values: right.values + [self])
            }
            
            // If we keep format
            if mode == .formatted {
                return Product(values: [self, right])
            }
            
            // Right is a fraction
            if let right = right as? Fraction {
                // a/b * c/d = ac/bd
                return Fraction(numerator: Product(values: [self.numerator, right.numerator]), denominator: Product(values: [self.denominator, right.denominator])).compute(with: inputs, mode: mode)
            }
            
            // Right is anything else
            // a/b * c = ac/b
            return Fraction(numerator: Product(values: [right, self.numerator]), denominator: denominator).compute(with: inputs, mode: mode)
        }
        
        // If fraction
        if operation == .division {
            // If we keep format
            if mode == .formatted {
                return Fraction(numerator: self, denominator: right)
            }
            
            // Multiply by its inverse
            return Product(values: [self, right.inverse()]).compute(with: inputs, mode: mode)
        }
        
        // Power
        if operation == .power {
            // If we keep format
            if mode == .formatted {
                return Power(token: self, power: right)
            }
            
            // Apply power to numerator and denominator
            return Fraction(numerator: Power(token: numerator, power: right), denominator: Power(token: denominator, power: right)).compute(with: inputs, mode: mode)
        }
        
        // Root
        if operation == .root {
            // If we keep format
            if mode == .formatted {
                return Root(token: self, power: right)
            }
            
            // Apply root to numerator and denominator
            return Fraction(numerator: Root(token: numerator, power: right), denominator: Root(token: denominator, power: right)).compute(with: inputs, mode: mode)
        }
        
        // Delegate to default
        return defaultApply(operation: operation, right: right, with: inputs, mode: mode)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return operation.getPrecedence() >= Operation.division.getPrecedence()
    }
    
    func getMultiplicationPriority() -> Int {
        return 1
    }
    
    func opposite() -> Token {
        return Fraction(numerator: Product(values: [Number(value: -1), numerator]), denominator: denominator).compute(with: [:], mode: .simplify)
    }
    
    func inverse() -> Token {
        return Fraction(numerator: denominator, denominator: numerator).compute(with: [:], mode: .simplify)
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
