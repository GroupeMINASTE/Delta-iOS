//
//  CalculError.swift
//  Delta
//
//  Created by Nathan FALLET on 08/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct CalculError: Token, Error {
    
    func toString() -> String {
        return "error_calcul".localized()
    }
    
    func compute(with inputs: [String: Token], format: Bool) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], format: Bool) -> Token {
        return self
    }
    
    func needBrackets(for operation: Operation) -> Bool {
        return false
    }
    
    func getMultiplicationPriority() -> Int {
        return 1
    }
    
    func opposite() -> Token {
        return self
    }
    
    func inverse() -> Token {
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
