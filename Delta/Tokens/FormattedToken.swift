//
//  FormattedToken.swift
//  Delta
//
//  Created by Nathan FALLET on 23/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct FormattedToken: Token {
    
    var token: Token
    
    func toString() -> String {
        token.toString()
    }
    
    func compute(with inputs: [String : Token], mode: ComputeMode) -> Token {
        token.compute(with: inputs, mode: .formatted)
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String : Token], mode: ComputeMode) -> Token {
        token.apply(operation: operation, right: right, with: inputs, mode: .formatted)
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        token.needBrackets(for: operation)
    }
    
    func getMultiplicationPriority() -> Int {
        token.getMultiplicationPriority()
    }
    
    func opposite() -> Token {
        token.opposite()
    }
    
    func inverse() -> Token {
        token.inverse()
    }
    
    func equals(_ right: Token) -> Bool {
        token.defaultEquals(right)
    }
    
    func asDouble() -> Double? {
        token.asDouble()
    }
    
    func getSign() -> FloatingPointSign {
        token.getSign()
    }
    
}
