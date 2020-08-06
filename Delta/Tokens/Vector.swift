//
//  Vector.swift
//  Delta
//
//  Created by Nathan FALLET on 08/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

struct Vector: Token {
    
    var values: [Token]
    
    func toString() -> String {
        return "(\(values.map { $0.toString() }.joined(separator: " , ")))"
    }
    
    func compute(with inputs: [String: Token], format: Bool) -> Token {
        return self
    }
    
    func apply(operation: Operation, right: Token, with inputs: [String: Token], format: Bool) -> Token {
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
        return Vector(values: values.map{ $0.opposite() })
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
    
    func multiply(by number: Number) -> Vector {
        var new = Vector(values: [])
        
        for i in values {
            new.values += [number.apply(operation: .multiplication, right: i, with: [:], format: false)]
        }
        
        return new
    }
    
    func multiply(by set: Vector) -> Token {
        if values.count != set.values.count {
            return CalculError()
        }
        
        var news = [Token]()
        
        for i in 0 ..< values.count {
            news.insert(Product(values: [values[i], set.values[i]]), at: 0)
        }
        
        do {
            while news.count > 1 {
                let left = try news.getFirstTokenAndRemove()
                let right = try news.getFirstTokenAndRemove()
                
                news.insert(Sum(values: [left, right]), at: 0)
            }
            
            return news.first!.compute(with: [:], format: false)
        } catch {
            // Error, do nothing
        }
        
        return SyntaxError()
    }
    
}
