//
//  ListAddAction.swift
//  Delta
//
//  Created by Nathan FALLET on 06/08/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation

class ListAddAction: Action {
    
    var value: String
    var identifier: String
    
    init(_ value: String, to identifier: String) {
        self.value = value
        self.identifier = identifier
    }
    
    func execute(in process: Process) {
        // Try to get list
        if let list = process.get(identifier: identifier) as? List {
            // Add value to list
            let newList = List(values: list.values + [TokenParser(value, in: process).execute().compute(with: process.variables, mode: .simplify)])
            
            // Set new value with process environment
            process.set(identifier: identifier, to: newList)
        }
    }
    
    func toString() -> String {
        return "list_add \"\(value)\" to \"\(identifier)\""
    }
    
    func toEditorLines() -> [EditorLine] {
        return [EditorLine(format: "action_list_add", category: .list, values: [value, identifier], movable: true)]
    }
    
    func editorLinesCount() -> Int {
        return 1
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        return (self, parent, parentIndex)
    }
    
    func update(line: EditorLine) {
        if line.values.count == 2 {
            self.value = line.values[0]
            self.identifier = line.values[1]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return []
    }
    
}

