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
    
    func compute(with inputs: [String : Token], format: Bool) -> Token {
        // Compute all values
        var values = self.values.map{ $0.compute(with: inputs, format: format) }
        
        // TODO: check if one of them is a sum to add it to values
        
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
                        let sum = value.apply(operation: .addition, right: otherValue, with: inputs, format: format)
                        
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
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], format: Bool) -> Token {
        // Compute right
        let right = right.compute(with: inputs, format: format)
        
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
            // Add token to product
            return Product(values: [self, right])
        }
        
        // If fraction
        if operation == .division {
            // Add token to fraction
            return Fraction(numerator: self, denominator: right)
        }
        
        // Power
        if operation == .power {
            return Power(token: self, power: right)
        }
        
        // Root
        if operation == .root {
            return Root(token: self, power: right)
        }
        
        // Unknown, return a calcul error
        return CalculError()
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
    
    func getSign() -> FloatingPointSign {
        // To be done
        return .plus
    }
    
}
