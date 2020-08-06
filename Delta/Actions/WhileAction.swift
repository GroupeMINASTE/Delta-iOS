//
//  WhileAction.swift
//  Delta
//
//  Created by Nathan FALLET on 07/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class WhileAction: ActionBlock {
    
    var condition: String
    var actions: [Action]
    
    init(_ condition: String, do actions: [Action]) {
        self.condition = condition
        self.actions = actions
    }
    
    func append(actions: [Action]) {
        self.actions.append(contentsOf: actions)
    }
    
    func execute(in process: Process) {
        // Counter
        var i = 0
        
        // Check if condition is true
        while checkCondition(in: process) {
            // Execute actions
            for action in actions {
                action.execute(in: process)
            }
            
            // Increment counter
            i += 1
            
            // If we crossed the limit
            if i > 1000 {
                // Show an error
                process.outputs.append("error_while_limit".localized())
                
                // And stop the while
                return
            }
        }
    }
    
    func checkCondition(in process: Process) -> Bool {
        return (TokenParser(self.condition, in: process).execute().compute(with: process.variables, mode: .simplify) as? Equation)?.isTrue(with: process.variables) ?? false
    }
    
    func toString() -> String {
        var string = "while \"\(condition)\" {"
        
        for action in actions {
            string += "\n\(action.toString().indentLines())"
        }
        
        string += "\n}"
        
        return string
    }
    
    func toEditorLines() -> [EditorLine] {
        var lines = [EditorLine(format: "action_while", category: .structure, values: [condition], movable: true)]
        
        for action in actions {
            lines.append(contentsOf: action.toEditorLines().map{ $0.incrementIndentation() })
        }
        
        lines.append(EditorLine(format: "", category: .add, indentation: 1, movable: false))
        lines.append(EditorLine(format: "action_end", category: .structure, movable: false))
        
        return lines
    }
    
    func editorLinesCount() -> Int {
        return actions.map{ $0.editorLinesCount() }.reduce(0, +) + 3
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        if index != 0 && index < editorLinesCount()-2 {
            // Iterate actions
            var i = 1
            for action in actions {
                // Get size
                let size = action.editorLinesCount()
                
                // Check if index is in this action
                if i + size > index {
                    // Delegate to action
                    return action.action(at: index - i, parent: self, parentIndex: index)
                } else {
                    // Continue
                    i += size
                }
            }
        }
        
        return (self, index == 0 ? parent : self, index == 0 ? parentIndex : index)
    }
    
    func insert(action: Action, at index: Int) {
        if index != 0 && index < editorLinesCount()-2 {
            // Iterate actions
            var i = 1
            var ri = 0
            for action1 in actions {
                // Get size
                let size = action1.editorLinesCount()
                
                // Check if index is in this action
                if i + size > index {
                    // Add it here
                    actions.insert(action, at: ri)
                    return
                } else {
                    // Continue
                    i += size
                    ri += 1
                }
            }
        }
        
        // No index found, add it at the end
        actions.append(action)
    }
    
    func delete(at index: Int) {
        if index != 0 && index < editorLinesCount()-2 {
            // Iterate actions
            var i = 1
            var ri = 0
            for action in actions {
                // Get size
                let size = action.editorLinesCount()
                
                // Check if index is in this action
                if i + size > index {
                    // Delete this one
                    actions.remove(at: ri)
                    return
                } else {
                    // Continue
                    i += size
                    ri += 1
                }
            }
        }
    }
    
    func update(line: EditorLine) {
        if line.values.count == 1 {
            // Get "while condition"
            self.condition = line.values[0]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return actions.flatMap{ $0.extractInputs() }
    }
    
}
