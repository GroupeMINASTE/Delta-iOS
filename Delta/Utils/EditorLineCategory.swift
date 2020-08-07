//
//  EditorLineCategory.swift
//  Delta
//
//  Created by Nathan FALLET on 22/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

enum EditorLineCategory: String {
    
    case variable = "variable"
    case structure = "structure"
    case output = "output"
    case list = "list"
    case quiz = "quiz"
    case settings = "settings"
    case add = "add"
    
    static let values: [EditorLineCategory] = [
        .variable,
        .structure,
        .output,
        .list,
        .quiz
    ]
    
    func catalog() -> [Action] {
        switch self {
        case .variable:
            return [
                InputAction("a", default: "0"),
                SetAction("a", to: "0"),
                UnsetAction("a")
            ]
        case .structure:
            return [
                IfAction("a = b", do: [], else: ElseAction(do: [])),
                WhileAction("a = b", do: []),
                ForAction("a", in: "b", do: [])
            ]
        case .output:
            return [
                PrintAction("a"),
                PrintAction("a", approximated: true),
                PrintTextAction("Hello world!")
            ]
        case .list:
            return [
                ListCreateAction("l"),
                ListAddAction("x", to: "l"),
                ListRemoveAction("x", to: "l")
            ]
        case .quiz:
            return [
                QuizInitAction("Solve equations:"),
                QuizAddAction("2x + 1 = 0"),
                QuizAddAction("x", correct: "x"),
                QuizShowAction()
            ]
        default:
            return []
        }
    }
    
}
