//
//  Operation.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

enum Operation: String {
    
    // Values
    case addition = "+", subtraction = "-", multiplication = "*", division = "/", modulo = "%", power = "^", root = "√", equals = "=", unequals = "!=", greaterThan = ">", lessThan = "<", greaterOrEquals = ">=", lessOrEquals = "<=", list1 = ",", list2 = ";", function = "f"
    
    // Get precedence
    func getPrecedence() -> Int {
        if self == .function {
            return 4
        }
        if self == .power || self == .root {
            return 3
        }
        if self == .multiplication || self == .division || self == .modulo {
            return 2
        }
        return 1
    }
    
    // Join with two tokens
    func join(left: Token, right: Token, ops: [String], with inputs: [String: Token]) -> Token {
        // Check for equations
        if self == .equals || self == .unequals || self == .greaterThan || self == .lessThan || self == .greaterOrEquals || self == .lessOrEquals {
            return Equation(left: left, right: right, operation: self)
        }
        
        // Check for function
        if self == .function {
            if let function = left as? Variable {
                // From left
                return Function(name: function.name, parameter: right)
            }
        }
        
        // Check for lists
        if ops.contains("{") && (self == .list1 || self == .list2) {
            if let list = left as? List {
                // From left
                return List(values: list.values + [right])
            } else if let list = right as? List {
                // From right
                return List(values: list.values + [left])
            } else {
                // From new tokens
                return List(values: [left, right])
            }
        }
        
        // Check for vectors
        if ops.contains("(") && (self == .list1 || self == .list2) {
            if let vector = left as? Vector {
                // From left
                return Vector(values: vector.values + [right])
            } else if let vector = right as? Vector {
                // From right
                return Vector(values: vector.values + [left])
            } else {
                // From new tokens
                return Vector(values: [left, right])
            }
        }
        
        // Simple expression
        return left.apply(operation: self, right: right, with: inputs, mode: .formatted)
    }
    
}
