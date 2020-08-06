//
//  FunctionDeclaration.swift
//  Delta
//
//  Created by Nathan FALLET on 18/11/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct FunctionDeclaration: Token {
    
    var variable: String
    var token: Token
    
    func toString() -> String {
        return token.toString()
    }
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        return FunctionDeclaration(variable: variable, token: token.apply(operation: operation, right: right, with: inputs, mode: .formatted))
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return token.getMultiplicationPriority()
    }
    
    func opposite() -> Token {
        return FunctionDeclaration(variable: variable, token: token.opposite())
    }
    
    func inverse() -> Token {
        return FunctionDeclaration(variable: variable, token: token.inverse())
    }
    
    func equals(_ right: Token) -> Bool {
        return defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        return token.asDouble()
    }
    
    func getSign() -> FloatingPointSign {
        return token.getSign()
    }
    
}
