//
//  Power.swift
//  Delta
//
//  Created by Nathan FALLET on 13/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Power: Token {
    
    var token: Token
    var power: Token
    
    func toString() -> String {
        return "\(token.needBrackets(for: .power) ? "(\(token.toString()))" : token.toString()) ^ \(power.needBrackets(for: .power) ? "(\(power.toString()))" : power.toString())"
    }
    
    func compute(with inputs: [String : Token], format: Bool) -> Token {
        let token = self.token.compute(with: inputs, format: format)
        let power = self.power.compute(with: inputs, format: format)
        
        // Check power
        if let number = power as? Number {
            // x^1 is x
            if number.value == 1 {
                return token
            }
        }
        if let fraction = power as? Fraction {
            // x^1/y is ^y√(x)
            if let number = fraction.inverse().compute(with: inputs, format: format) as? Number {
                return Root(token: token, power: number).compute(with: inputs, format: format)
            }
        }
        
        return token.apply(operation: .power, right: power, with: inputs, format: format)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], format: Bool) -> Token {
        // Product
        if operation == .multiplication {
            // Token and right are the same
            if token.toString() == right.toString() {
                return Power(token: token, power: Sum(values: [power, Number(value: 1)])).compute(with: inputs, format: format)
            }
        }
        
        // Delegate to default
        return defaultApply(operation: operation, right: right, with: inputs, format: format)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return operation.getPrecedence() >= Operation.power.getPrecedence()
    }
    
    func getMultiplicationPriority() -> Int {
        1
    }
    
    func opposite() -> Token {
        return Product(values: [self, Number(value: -1)])
    }
    
    func inverse() -> Token {
        return Fraction(numerator: Number(value: 1), denominator: self)
    }
    
    func asDouble() -> Double? {
        if let token = token.asDouble(), let power = power.asDouble() {
            return pow(token, power)
        }
        
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }
    
}
