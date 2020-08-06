//
//  IfAction.swift
//  Delta
//
//  Created by Nathan FALLET on 06/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class IfAction: ActionBlock {
    
    var condition: String
    var actions: [Action]
    var elseAction: ElseAction?
    
    init(_ condition: String, do actions: [Action], else elseAction: ElseAction? = nil) {
        self.condition = condition
        self.actions = actions
        self.elseAction = elseAction
    }
    
    func append(actions: [Action]) {
        self.actions.append(contentsOf: actions)
    }
    
    func execute(in process: Process) {
        // Get computed condition and check it
        if let condition = TokenParser(self.condition, in: process).execute().compute(with: process.variables, mode: .simplify) as? Equation, condition.isTrue(with: process.variables) {
            // Execute actions
            for action in actions {
                action.execute(in: process)
            }
        } else {
            // Execute else actions
            elseAction?.execute(in: process)
        }
    }
    
    func toString() -> String {
        var string = "if \"\(condition)\" {"
        
        for action in actions {
            string += "\n\(action.toString().indentLines())"
        }
        
        string += "\n}"
        
        if let elseAction = elseAction {
            string += elseAction.toString()
        }
        
        return string
    }
    
    func toEditorLines() -> [EditorLine] {
        var lines = [EditorLine(format: "action_if", category: .structure, values: [condition], movable: true)]
        
        for action in actions {
            lines.append(contentsOf: action.toEditorLines().map{ $0.incrementIndentation() })
        }
        
        lines.append(EditorLine(format: "", category: .add, indentation: 1, movable: false))
        
        if let elseAction = elseAction {
            lines.append(contentsOf: elseAction.toEditorLines())
        }
        
        lines.append(EditorLine(format: "action_end", category: .structure, movable: false))
        
        return lines
    }
    
    func editorLinesCount() -> Int {
        var count = actions.map{ $0.editorLinesCount() }.reduce(0, +) + 3
        
        if let elseAction = elseAction {
            count += elseAction.editorLinesCount()
        }
        
        return count
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        if index != 0 && index < editorLinesCount()-1 {
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
            
            // Check if button
            if index == i {
                return (self, self, parentIndex)
            }
            
            // Increment to skip add button
            i += 1
            
            // Delegate to else actions
            if let elseAction = elseAction {
                return elseAction.action(at: index - i, parent: self, parentIndex: index)
            }
        }
        
        return (self, index == 0 ? parent : self, index == 0 ? parentIndex : index)
    }
    
    func insert(action: Action, at index: Int) {
        if index != 0 && index < editorLinesCount()-1 {
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
        if index != 0 && index < editorLinesCount()-1 {
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
            // Get "if condition"
            self.condition = line.values[0]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return actions.flatMap{ $0.extractInputs() } + (elseAction?.extractInputs() ?? [])
    }
    
}
