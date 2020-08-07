//
//  ListRemoveAction.swift
//  Delta
//
//  Created by Nathan FALLET on 07/08/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation

class ListRemoveAction: Action {
    
    var value: String
    var identifier: String
    
    init(_ value: String, to identifier: String) {
        self.value = value
        self.identifier = identifier
    }
    
    func execute(in process: Process) {
        // Try to get list
        if let list = process.get(identifier: identifier) as? List {
            // Remove value from list
            let removal = TokenParser(value, in: process).execute().compute(with: process.variables, mode: .simplify)
            var newList = List(values: list.values)
            newList.values.removeAll(where: { $0.equals(removal) })
            
            // Set new value with process environment
            process.set(identifier: identifier, to: newList)
        }
    }
    
    func toString() -> String {
        return "list_remove \"\(value)\" from \"\(identifier)\""
    }
    
    func toEditorLines() -> [EditorLine] {
        return [EditorLine(format: "action_list_remove", category: .list, values: [value, identifier], movable: true)]
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
