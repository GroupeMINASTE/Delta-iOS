//
//  PrintAction.swift
//  Delta
//
//  Created by Nathan FALLET on 06/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class PrintAction: Action {
    
    var identifier: String
    var approximated: Bool
    
    init(_ identifier: String, approximated: Bool = false) {
        self.identifier = identifier
        self.approximated = approximated
    }
    
    func execute(in process: Process) {
        // Get the value
        let value = TokenParser(identifier, in: process).execute()
        
        // Print it (add it to output)
        if approximated, let asDouble = value.compute(with: process.variables, mode: .simplify).asDouble() {
            if floor(asDouble) == asDouble {
                process.outputs.append("\(identifier) = \(Int(asDouble))")
            } else {
                process.outputs.append("\(identifier) = \(asDouble)")
            }
        } else {
            process.outputs.append("\(identifier) = \(value.compute(with: process.variables, mode: .formatted).toString())")
        }
    }
    
    func toString() -> String {
        return "\(approximated ? "print_approximated" : "print") \"\(identifier)\""
    }
    
    func toEditorLines() -> [EditorLine] {
        return [EditorLine(format: approximated ? "action_print_approximated" : "action_print", category: .output, values: [identifier], movable: true)]
    }
    
    func editorLinesCount() -> Int {
        return 1
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        return (self, parent, parentIndex)
    }
    
    func update(line: EditorLine) {
        if line.values.count == 1 {
            self.identifier = line.values[0]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return []
    }
    
}
