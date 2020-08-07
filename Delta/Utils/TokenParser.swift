//
//  TokenParser.swift
//  Delta
//
//  Created by Nathan FALLET on 09/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class TokenParser {
    
    static let variables = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZΑαΒβΓγΔδΕεΖζΗηΘθΙιΚκΛλΜμΝνΞξΟοΠπΣσςϹϲΤτΥυΦφΧχΨψΩω"
    static let variablesAndNumber = "\(variables)0123456789"
    static let productCoefficients = "\(variablesAndNumber))"
    static let constants = "ieπ"
    static let input = " \(variablesAndNumber)_+-*/%^√,;(){}=<>!"
    static let funcs = ["sin", "cos", "tan", "sqrt", "exp", "log", "ln", "random"]
    
    private var tokens: String
    private var ops: [String]
    private var i: Int
    
    private var values: [Token]
    
    private var process: Process?
    
    init(_ tokens: String?, in process: Process? = nil) {
        self.tokens = tokens ?? ""
        self.ops = [String]()
        self.i = 0
        
        self.values = [Token]()
        
        self.process = process
    }
    
    // Parse an expression
    func execute() -> Token {
        // Remove whitespaces
        tokens = tokens.replacingOccurrences(of: " ", with: "")
        
        // Check if empty
        if tokens.isEmpty {
            return Number(value: 0)
        }
        
        do {
            // For each character of the string
            while i < tokens.count {
                let current = tokens[i]
                let previous = i > 0 ? tokens[i-1] : ""
                
                // Opening brace
                if current == "(" {
                    // Check if we have a token before without operator
                    if values.count > 0 && TokenParser.productCoefficients.contains(previous) {
                        // Check if last token is a function
                        if let prevar = values.first as? Variable, (process?.variables[prevar.name] as? FunctionDeclaration != nil || TokenParser.funcs.contains(prevar.name)) {
                            // Add a function operator
                            try insertOperation("f")
                        } else {
                            // Add a multiplication operator
                            try insertOperation("*")
                        }
                    }
                    
                    // Add it to operations
                    ops.insert(current, at: 0)
                }
                
                // Other opening brace
                else if current == "{" {
                    // Add it to operations
                    ops.insert(current, at: 0)
                }
                
                // Number
                else if Int(current) != nil {
                    var val: Int64 = 0
                    var powerOfTen: Int64 = 0
                    
                    // Get other digits
                    while i < tokens.count, let t = Int64(tokens[i]) {
                        val = (val * 10) + t
                        i += 1
                    }
                    
                    // If we have a dot
                    if i < tokens.count-1 && tokens[i] == "." {
                        // Pass the dot
                        i += 1
                        
                        // And start getting numbers after the dot
                        while i < tokens.count, let t = Int64(tokens[i]) {
                            val = (val * 10) + t
                            i += 1
                            powerOfTen += 1
                        }
                    }
                    
                    // Check if we have a token before without operator
                    if values.count > 0 && TokenParser.productCoefficients.contains(previous) {
                        // Add a multiplication operator
                        try insertOperation("*")
                    }
                    
                    // Insert into values
                    if powerOfTen > 0 {
                        insertValue(Fraction(numerator: Number(value: val), denominator: Power(token: Number(value: 10), power: Number(value: powerOfTen))))
                    } else {
                        insertValue(Number(value: val))
                    }
                    
                    // Remove one, else current caracter is skept
                    i -= 1
                }
                
                // Variable
                else if TokenParser.variables.contains(current) {
                    // Check name
                    var name = current
                    
                    // Check for a function name
                    var function = name
                    var j = i
                    while j < tokens.count-1 && TokenParser.variablesAndNumber.contains(tokens[j+1]) {
                        // Add character to function name
                        function += tokens[j+1]
                        
                        // Increment j to continue
                        j += 1
                    }
                    
                    // Check if a function is recognized
                    if TokenParser.funcs.contains(function.lowercased()) {
                        // We have a function
                        name = function.lowercased()
                        
                        // Set i to j to skip function name
                        i = j
                    } else {
                        // It is a classic variable, continue
                        
                        // Check for an index
                        if i < tokens.count-2 && tokens[i+1] == "_" {
                            if tokens[i+2] == "(" {
                                // Get everything until closing brace
                                var index = ""
                                var j = i+2
                                while j < tokens.count-1 && TokenParser.input.contains(tokens[j+1]) && tokens[j+1] != ")" {
                                    // Add character to index
                                    index += tokens[j+1]
                                    
                                    // Increment j to continue
                                    j += 1
                                }
                                
                                // Increment i to skip brace
                                i = j+1
                                
                                // Trim
                                index = index.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                                
                                if !index.isEmpty {
                                    // Add index to variable
                                    if index.count == 1 {
                                        name += "_\(index)"
                                    } else {
                                        name += "_(\(index))"
                                    }
                                }
                            } else if TokenParser.variablesAndNumber.contains(tokens[i+2]) {
                                // Add index to variable
                                let index = tokens[i+2]
                                name += "_\(index)"
                                
                                // Increment i 2 times to skip index
                                i += 2
                            }
                        }
                    }

                    // Check if we have a token before without operator
                    if values.count > 0 && TokenParser.productCoefficients.contains(previous) {
                        // Add a multiplication operator
                        try insertOperation("*")
                    }
                    
                    // Insert into values
                    insertValue(Variable(name: name))
                }
                
                // Closing brace
                else if current == ")" {
                    // Create the token
                    while !ops.isEmpty && ops.first != "(" {
                        // Create a token
                        if let value = try createValue() {
                            // Insert it into the list
                            insertValue(value)
                        }
                    }
                    
                    // Remove opening brace
                    if !ops.isEmpty {
                        ops.removeFirst()
                    }
                }
                
                // Closing brace
                else if current == "}" {
                    // Check for an empty set
                    if ops.first == "{" {
                        // Check for a possible value
                        if !values.isEmpty, let value = try? values.getFirstTokenAndRemove() {
                            // Create a set with this value
                            insertValue(List(values: [value]))
                        } else {
                            // Create an empty set
                            insertValue(List(values: []))
                        }
                    }
                    
                    // Create the token
                    while !ops.isEmpty && ops.first != "{" {
                        // Create a token
                        if let value = try createValue() {
                            // Insert it into the list
                            insertValue(value)
                        }
                    }
                    
                    // Remove opening brace
                    if !ops.isEmpty {
                        ops.removeFirst()
                    }
                }
                    
                // Root
                else if current == "√" {
                    // Check if we have a token before without operator
                    if values.count > 0 && TokenParser.productCoefficients.contains(previous) {
                        // Add a multiplication operator
                        try insertOperation("*")
                    }
                    
                    // Insert the 2nd power
                    insertValue(Number(value: 2))
                    
                    // Add current operation
                    try insertOperation(current)
                }
                
                // Operation
                else {
                    // Insert operation
                    try insertOperation(current)
                }
                
                // Increment i
                i += 1
            }
            
            // Entire expression parsed, apply remaining values
            while !ops.isEmpty {
                // Create a token
                if let value = try createValue() {
                    // Insert it into the list
                    insertValue(value)
                }
            }
            
            // Return token
            if let token = values.first {
                return token
            }
        } catch {
            // We have a syntax error, do nothing
        }
        
        // If the token is not valid
        return SyntaxError()
    }
    
    func insertValue(_ value: Token) {
        // Insert the value in the list
        values.insert(value, at: 0)
    }
    
    func insertOperation(_ op: String) throws {
        // While first operation has same or greater precendence to current, apply to two first values
        while !ops.isEmpty, let p1 = ops.first?.toOperation()?.getPrecedence(), let p2 = op.toOperation()?.getPrecedence(), p1 >= p2 {
            // Create a token
            if let value = try createValue() {
                // Insert it into the list
                insertValue(value)
            }
        }
        
        // If subtraction with no number before
        if op == "-" && (values.count == 0 || (i > 0 && tokens[i-1] == "(")) {
            insertValue(Number(value: 0))
        }
        
        // If next if "="
        if i < tokens.count-1 && tokens[i+1] == "=" {
            // Add it
            ops.insert("\(op)=", at: 0)
            
            // Increment i
            i += 1
        } else {
            // Add current operation
            ops.insert(op, at: 0)
        }
    }
    
    func createValue() throws -> Token? {
        // Get tokens
        let right = try values.getFirstTokenAndRemove()
        let left = try values.getFirstTokenAndRemove()
        
        // Get operator and apply
        if let op = ops.getFirstOperationAndRemove() {
            if op == .root {
                return op.join(left: right, right: left, ops: ops, with: process?.variables ?? [:])
            } else {
                return op.join(left: left, right: right, ops: ops, with: process?.variables ?? [:])
            }
        }
        
        // Nothing found
        return nil
    }
    
}
