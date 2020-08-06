//
//  Function.swift
//  Delta
//
//  Created by Nathan FALLET on 18/11/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Function: Token {
    
    var name: String
    var parameter: Token
    
    func toString() -> String {
        return "\(name)(\(parameter.toString()))"
    }
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        // Prepare func handling
        let parameter = self.parameter.compute(with: inputs, mode: mode)
        var expression: Token
        var variable: String
        
        // Chech if an input corresponds to this variable
        if TokenParser.funcs.contains(name) {
            // Universal func
            
            // Sin
            
            // Cos
            
            // Tan
            
            // Sqrt
            if name == "sqrt" {
                expression = Root(token: Variable(name: "x"), power: Number(value: 2))
                variable = "x"
            }
            
            // Exp
            else if name == "exp" {
                expression = Power(token: Variable(name: "e"), power: Variable(name: "x"))
                variable = "x"
            }
            
            // Log
            
            // Ln
            
            // Random
            else if name == "random", let number = parameter as? Number, number.value > 0 {
                return Number(value: Int64.random(in: 0 ..< number.value))
            }
            
            // Cannot be simplified
            else {
                return self
            }
        } else if let value = inputs[name] as? FunctionDeclaration {
            // Custom func
            expression = value.token
            variable = value.variable.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        } else {
            // Unknown func
            return CalculError()
        }
        
        // Get inputs and current parameter of function
        var values = inputs
        if (parameter as? Variable)?.name ?? "" != variable {
            values[variable] = parameter
        }
        
        // Return computed expression
        return expression.compute(with: values, mode: mode)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        return defaultApply(operation: operation, right: right, with: inputs, mode: mode)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return 2
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
        // Chech if an input corresponds to this variable
        if TokenParser.funcs.contains(name), let paramDouble = parameter.asDouble() {
            // Universal func
            
            // Sin
            if name == "sin" {
                return sin(paramDouble)
            }
            
            // Cos
            if name == "cos" {
                return cos(paramDouble)
            }
            
            // Tan
            if name == "tan" {
                return tan(paramDouble)
            }
            
            // Log
            if name == "log" {
                return log10(paramDouble)
            }
            
            // Ln
            if name == "ln" {
                return log(paramDouble)
            }
        }
        
        return nil
    }
    
    func getSign() -> FloatingPointSign {
        return .plus
    }
    
}
