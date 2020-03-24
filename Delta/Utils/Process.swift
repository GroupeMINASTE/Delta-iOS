//
//  Process.swift
//  Delta
//
//  Created by Nathan FALLET on 06/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import UIKit

class Process {
    
    var inputs = [(String, String)]()
    var variables = [String: Token]()
    var outputs = [Any]()
    var semaphore = DispatchSemaphore(value: 0)
    var quiz: Quiz?
    
    init(inputs: [(String, String)]) {
        self.inputs = inputs
    }
    
    func set(identifier: String, to value: Token) {
        let trimmed = identifier.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let f = trimmed.groups(for: "([\(TokenParser.variables)])\\( *([\(TokenParser.variables)]) *\\)")
        
        if !f.isEmpty {
            // Take it as a function
            variables[f[0][1]] = FunctionDeclaration(variable: f[0][2], token: value)
        } else {
            // Set it as a variable
            variables[trimmed] = value.compute(with: variables, format: false)
        }
    }
    
    func unset(identifier: String) {
        let trimmed = identifier.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        let f = trimmed.groups(for: "([\(TokenParser.variables)])\\( *([\(TokenParser.variables)]) *\\)")
        
        if !f.isEmpty {
            // Take it as a function
            variables.removeValue(forKey: f[0][1])
        } else {
            // Unset it as a variable
            variables.removeValue(forKey: trimmed)
        }
    }
    
}
