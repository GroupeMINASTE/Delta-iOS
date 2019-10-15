//
//  SetAction.swift
//  Delta
//
//  Created by Nathan FALLET on 06/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class SetAction: Action {
    
    var identifier: String
    var value: Token
    
    init(_ identifier: String, to value: Token) {
        self.identifier = identifier
        self.value = value
    }
    
    func execute(in process: Process) {
        // Check if variable is not a constant
        if Parser.constants.contains(identifier) {
            process.outputs.append("error_constant".localized().format(identifier))
            return
        }
        
        // Set value with process environment
        process.variables[identifier] = value.compute(with: process.variables)
    }
    
}
