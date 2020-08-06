//
//  List.swift
//  Delta
//
//  Created by Nathan FALLET on 07/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct List: Token {
    
    var values: [Token]
    
    func toString() -> String {
        return "{\(values.map { $0.toString() }.joined(separator: ", "))}"
    }
    
    func compute(with inputs: [String: Token], mode: ComputeMode) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], mode: ComputeMode) -> Token {
        // Compute right
        //let right = right.compute(with: inputs)
        
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
        // Unknown
        return self
    }
    
    func inverse() -> Token {
        // Unknown
        return self
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
