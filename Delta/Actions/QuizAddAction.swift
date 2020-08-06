//
//  QuizAddAction.swift
//  Delta
//
//  Created by Nathan FALLET on 17/03/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import Foundation

class QuizAddAction: Action {
    
    var text: String
    var correct: String?
    
    init(_ text: String, correct: String? = nil) {
        self.text = text
        self.correct = correct
    }
    
    func execute(in process: Process) {
        if let quiz = process.quiz {
            if let correct = correct {
                quiz.addQuestion(text.replaceTokens(in: process), correct: TokenParser(correct, in: process).execute().compute(with: process.variables, mode: .simplify))
            } else {
                quiz.addParagraph(text.replaceTokens(in: process))
            }
        }
    }
    
    func toString() -> String {
        if let correct = correct {
            return "quiz_add \"\(text.replacingOccurrences(of: "\"", with: "\\\""))\" correct \"\(correct)\""
        }
        return "quiz_add \"\(text.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
    
    func toEditorLines() -> [EditorLine] {
        if let correct = correct {
            return [EditorLine(format: "action_quiz_add_question", category: .quiz, values: [text, correct], movable: true)]
        }
        return [EditorLine(format: "action_quiz_add_paragraph", category: .quiz, values: [text], movable: true)]
    }
    
    func editorLinesCount() -> Int {
        return 1
    }
    
    func action(at index: Int, parent: Action, parentIndex: Int) -> (Action, Action, Int) {
        return (self, parent, parentIndex)
    }
    
    func update(line: EditorLine) {
        if line.values.count == 2 {
            self.text = line.values[0]
            self.correct = line.values[1]
        } else if line.values.count == 1 {
            self.text = line.values[0]
        }
    }
    
    func extractInputs() -> [(String, String)] {
        return []
    }
    
}
