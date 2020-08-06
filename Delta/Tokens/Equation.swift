//
//  Equation.swift
//  Delta
//
//  Created by Nathan FALLET on 08/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Equation: Token {
    
    var left: Token
    var right: Token
    var operation: Operation
    
    func isTrue(with inputs: [String: Token]) -> Bool {
        let left = self.left.compute(with: inputs, mode: .simplify)
        let right = self.right.compute(with: inputs, mode: .simplify)
        
        // Equals
        if operation == .equals {
            return left.equals(right)
        }
        // Unequals
        else if operation == .unequals {
            return !left.equals(right)
        }
        
        // Other operations with value
        if let left = left.asDouble(), let right = right.asDouble() {
            if operation == .greaterThan {
                return left > right
            } else if operation == .lessThan {
                return left < right
            } else if operation == .greaterOrEquals {
                return left >= right
            } else if operation == .lessOrEquals {
                return left <= right
            }
        }
        
        return false
    }
    
    func toString() -> String {
        return "\(left.toString()) \(operation.rawValue) \(right.toString())"
    }
    
    func compute(with inputs: [String: Token], mode: ComputeMode) -> Token {
        let left = self.left.compute(with: inputs, mode: mode)
        let right = self.right.compute(with: inputs, mode: mode)
        
        return Equation(left: left, right: right, operation: operation)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], mode: ComputeMode) -> Token {
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
        return Equation(left: left.opposite(), right: right.opposite(), operation: operation)
    }
    
    func inverse() -> Token {
        return Equation(left: left.inverse(), right: right.inverse(), operation: operation)
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
