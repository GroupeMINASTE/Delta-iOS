//
//  Sum.swift
//  Delta
//
//  Created by Nathan FALLET on 09/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Sum: Token {
    
    var values: [Token]
    
    func toString() -> String {
        var string = ""
        
        for value in values {
            // Initialization
            var asString = value.toString()
            var op = false
            var minus = false
            
            // Check if not empty
            if !string.isEmpty {
                op = true
            }
            
            // Check if we need to keep operator
            if op && asString.starts(with: "-") {
                // Remove minus from string to have it instead of plus
                minus = true
                asString = asString[1 ..< asString.count]
            }
            
            // Add operator if required
            if op {
                if minus {
                    string += " - "
                } else {
                    string += " + "
                }
            }
            
            // Check for brackets
            string += asString
        }
        
        return string
    }
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        // Compute all values
        var values = self.values.map{ $0.compute(with: inputs, mode: mode) }
        
        // Some required vars
        var index = 0
        
        // Iterate values
        while index < values.count {
            // Get value
            var value = values[index]
            
            // Check if value is a sum
            if let product = value as? Sum {
                // Add values to self
                values += product.values
                
                // Remove current value
                values.remove(at: index)
                index -= 1
            } else {
                // Iterate to add it to another value
                var i = 0
                while i < values.count {
                    // Check if it's not the same index
                    if i != index {
                        // Get another value
                        let otherValue = values[i]
                        
                        // Sum them
                        let sum = value.apply(operation: .addition, right: otherValue, with: inputs, mode: mode)
                        
                        // If it is simpler than a sum
                        if sum as? Sum == nil {
                            // Update values
                            value = sum
                            values[index] = value
                            
                            // Remove otherValue
                            values.remove(at: i)
                            
                            // Update indexes
                            index -= index >= i ? 1 : 0
                            i -= 1
                        }
                    }
                    
                    // Increment i
                    i += 1
                }
                
                // Check for zero (0 + x is x)
                if let number = value as? Number, number.value == 0 {
                    // Remove zero
                    values.remove(at: index)
                    index -= 1
                }
            }
            
            // Increment index
            index += 1
        }
        
        // If only one value left
        if values.count == 1 {
            return values[0]
        }
        
        // If empty
        if values.isEmpty {
            return Number(value: 0)
        }
        
        // Return the simplified sum
        return Sum(values: values)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        // Compute right
        let right = right.compute(with: inputs, mode: mode)
        
        // If addition
        if operation == .addition {
            // Add token to sum
            return Sum(values: values + [right])
        }
        
        // If subtraction
        if operation == .subtraction {
            // Add token to sum
            return Sum(values: values + [right.opposite()])
        }
        
        // If product
        if operation == .multiplication {
            // If we keep format
            if mode == .formatted {
                return Product(values: [self, right])
            }
            
            // Right is a sum
            if let right = right as? Sum {
                return Sum(values: values.map { $0.apply(operation: .multiplication, right: right, with: inputs, mode: mode) }).compute(with: inputs, mode: mode)
            }
            
            // Return the product
            return Product(values: [self, right])
        }
        
        // Delegate to default
        return defaultApply(operation: operation, right: right, with: inputs, mode: mode)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return operation.getPrecedence() > Operation.addition.getPrecedence()
    }
    
    func getMultiplicationPriority() -> Int {
        1
    }
    
    func opposite() -> Token {
        return Sum(values: values.map{ $0.opposite() })
    }
    
    func inverse() -> Token {
        return Fraction(numerator: Number(value: 1), denominator: self)
    }
    
    func equals(_ right: Token) -> Bool {
        return defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        var val = 0.0
        
        for token in values {
            if let asDouble = token.asDouble() {
                val += asDouble
            } else {
                return nil
            }
        }
        
        return val
    }
    
    func getSign() -> FloatingPointSign {
        // To be done
        return .plus
    }
    
}
