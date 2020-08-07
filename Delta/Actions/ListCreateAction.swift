//
//  ListCreateAction.swift
//  Delta
//
//  Created by Nathan FALLET on 07/08/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation

class ListCreateAction: Action {
    
    var identifier: String
    
    init(_ identifier: String) {
        self.identifier = identifier
    }
    
    func execute(in process: Process) {
        // Check if variable is not a constant
        if TokenParser.constants.contains(identifier) {
            process.outputs.append("error_constant".localized().format(identifier))
            return
        }
        
        // Set value with process environment
        process.set(identifier: identifier, to: List(values: []))
    }
    
    func toString() -> String {
        return "list_create \"\(identifier)\""
    }
    
    func toEditorLines() -> [EditorLine] {
        return [EditorLine(format: "action_list_create", category: .list, values: [identifier], movable: true)]
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
