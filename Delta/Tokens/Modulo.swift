//
//  Modulo.swift
//  Delta
//
//  Created by Nathan FALLET on 23/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Modulo: Token {
    
    var dividend: Token
    var divisor: Token
    
    func toString() -> String {
        return "\(dividend.needBrackets(for: .division) ? "(\(dividend.toString()))" : dividend.toString()) % \(divisor.needBrackets(for: .division) ? "(\(divisor.toString()))" : divisor.toString())"
    }
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        let dividend = self.dividend.compute(with: inputs, mode: mode)
        let divisor = self.divisor.compute(with: inputs, mode: mode)
        
        // Check dividend
        if let number = dividend as? Number {
            // 0 % x is 0
            if number.value == 0 {
                return number
            }
        }
        
        // Check divisor
        if let number = divisor as? Number {
            // x % 0 is calcul error
            if number.value == 0 {
                return CalculError()
            }
        }
        
        // Apply to simplify
        return dividend.apply(operation: .modulo, right: divisor, with: inputs, mode: mode)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        return defaultApply(operation: operation, right: right, with: inputs, mode: mode)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return operation.getPrecedence() >= Operation.modulo.getPrecedence()
    }
    
    func getMultiplicationPriority() -> Int {
        return 1
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
        if let dividend = dividend.asDouble(), let divisor = divisor.asDouble() {
            return dividend.truncatingRemainder(dividingBy: divisor)
        }
        
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }
    
}
