//
//  PrintTextAction.swift
//  Delta
//
//  Created by Nathan FALLET on 23/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class PrintTextAction: Action {
    
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    func execute(in process: Process) {
        // Print text
        process.outputs.append(text.replaceTokens(in: process))
    }
    
    func toString() -> String {
        return "print_text \"\(text.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
    
    func toEditorLines() -> [EditorLine] {
        return [EditorLine(format: "action_print_text", category: .output, values: [text], movable: true)]
    }
    
    func editorLinesCount() -> Int {
        return 1
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        return (self, parent, parentIndex)
    }
    
    func update(line: EditorLine) {
        if line.values.count == 1 {
            self.text = line.values[0]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return []
    }
    
}
