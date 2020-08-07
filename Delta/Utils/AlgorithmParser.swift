//
//  AlgorithmParser.swift
//  Delta
//
//  Created by Nathan FALLET on 21/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

class AlgorithmParser {
    
    // Constants
    static let characters = "abcdefghijklmnopqrstuvwxyz_"
    
    // Parsing vars
    private var lines: String
    private var keywords: [String]
    private var tokens: [String]
    private var i: Int
    
    // Algorithm vars
    private var local_id: Int64
    private var remote_id: Int64?
    private var owner: Bool
    private var name: String
    private var last_update: Date
    private var icon: AlgorithmIcon
    private var actions: [Action]
    
    init(_ local_id: Int64, remote_id: Int64?, owned owner: Bool, named name: String, last_update: Date, icon: AlgorithmIcon, with lines: String?) {
        self.lines = lines ?? ""
        self.keywords = [String]()
        self.tokens = [String]()
        self.i = 0
        
        self.local_id = local_id
        self.remote_id = remote_id
        self.name = name
        self.owner = owner
        self.last_update = last_update
        self.icon = icon
        self.actions = [Action]()
    }
    
    // Parse an algorithm
    func execute() -> Algorithm {
        // For each character of the string
        while i < lines.count {
            let current = lines[i]
            
            // Opening brace
            if current == "{" {
                // Some vars
                i += 1
                var content = ""
                var count = 0
                
                // Get text until its closing brace
                while lines[i] != "}" || count != 0 {
                    // Add current
                    content += lines[i]
                    
                    // Check for another opening brace
                    if lines[i] == "{" {
                        count += 1
                    }
                    
                    // Closing
                    if lines[i] == "}" {
                        count -= 1
                    }
                    
                    // Increment i
                    i += 1
                }
                
                // Parse block
                let block = AlgorithmParser(0, remote_id: nil, owned: false, named: "", last_update: Date(), icon: AlgorithmIcon(), with: content).execute().root.actions
                
                // Create an action from the line
                if let action = createAction() as? ActionBlock {
                    // Add braces actions
                    action.append(actions: block)
                    
                    // If it is an ElseAction
                    if let elseAction = action as? ElseAction {
                        // Check for IfAction
                        if let ifAction = actions.first as? IfAction {
                            // Set elseAction
                            ifAction.elseAction = elseAction
                        }
                    } else {
                        // Add it to the list
                        insertAction(action)
                    }
                }
            }
            
            // Characters
            else if AlgorithmParser.characters.contains(current) {
                var keyword = ""
                
                // Get all the characters
                while i < lines.count && AlgorithmParser.characters.contains(lines[i]) {
                    keyword += lines[i]
                    i += 1
                }
                
                // Insert into keywords
                keywords.insert(keyword, at: 0)
                
                // Remove one, else current caracter is skept
                i -= 1
            }
            
            // Tokens
            else if current == "\"" {
                var token = ""
                i += 1
                
                // Get all the characters
                while i < lines.count && lines[i] != "\"" {
                    // Check for \
                    if lines[i] == "\\" && i < lines.count-1 {
                        // Skip it and get next character
                        i += 1
                    }
                    
                    // Add chararcter to string
                    token += lines[i]
                    i += 1
                }
                
                // Insert into tokens
                tokens.insert(token, at: 0)
            }
            
            // New line
            else if current == "\n" {
                // Create an action from the line
                if let action = createAction() {
                    // Add it to the list
                    insertAction(action)
                }
            }
            
            // Increment i
            i += 1
        }
        
        // If something left, add it
        while !keywords.isEmpty {
            // Create an action from the line
            if let action = createAction() {
                // Add it to the list
                insertAction(action)
            }
        }
        
        // Create an algorithm with parsed data
        return Algorithm(local_id: local_id, remote_id: remote_id, owner: owner, name: name, last_update: last_update, icon: icon, root: RootAction(actions.reversed()))
    }
    
    func insertAction(_ action: Action) {
        // Insert into actions
        actions.insert(action, at: 0)
    }
    
    func createAction() -> Action? {
        // Check if first is string
        if let first = keywords.first {
            // Remove it
            keywords.removeFirst()
            
            // Keyword list
            let alone = [
                Keyword.If,
                Keyword.Else,
                Keyword.Print,
                Keyword.PrintApproximated,
                Keyword.PrintText,
                Keyword.Unset,
                Keyword.While,
                Keyword.ListCreate,
                Keyword.QuizInit,
                Keyword.QuizAdd,
                Keyword.QuizShow
            ]
            let grouped = [
                Keyword.Default: [
                    Keyword.Input
                ],
                Keyword.In: [
                    Keyword.For
                ],
                Keyword.To: [
                    Keyword.Set,
                    Keyword.ListAdd
                ],
                Keyword.From: [
                    Keyword.ListRemove
                ],
                Keyword.Correct: [
                    Keyword.QuizAdd
                ]
            ]
            
            // Iterate values
            for key in grouped {
                // If it's the keyword we want
                if first == key.key.rawValue {
                    // Get the next one
                    if let second = keywords.first {
                        // Remove it too
                        keywords.removeFirst()
                        
                        // Iterate values
                        for value in key.value {
                            // Check if second is the correct value
                            if second == value.rawValue {
                                // Create action and return it
                                if value == .Input && tokens.count >= 2 {
                                    // Input "identifier" default "token"
                                    let token = tokens.removeFirst()
                                    let identifier = tokens.removeFirst()
                                    return InputAction(identifier, default: token)
                                } else if value == .For && tokens.count >= 2 {
                                    // For "identifier" in "token"
                                    let token = tokens.removeFirst()
                                    let identifier = tokens.removeFirst()
                                    return ForAction(identifier, in: token, do: [])
                                } else if value == .Set && tokens.count >= 2 {
                                    // Set "identifier" to "token"
                                    let token = tokens.removeFirst()
                                    let identifier = tokens.removeFirst()
                                    return SetAction(identifier, to: token)
                                } else if value == .ListAdd && tokens.count >= 2 {
                                    // Add "value" to "identifier"
                                    let identifier = tokens.removeFirst()
                                    let value = tokens.removeFirst()
                                    return ListAddAction(value, to: identifier)
                                } else if value == .ListRemove && tokens.count >= 2 {
                                    // Remove "value" from "identifier"
                                    let identifier = tokens.removeFirst()
                                    let value = tokens.removeFirst()
                                    return ListRemoveAction(value, to: identifier)
                                } else if value == .QuizAdd && tokens.count >= 2 {
                                    // Add input "text" with "correct" as correct answer
                                    let correct = tokens.removeFirst()
                                    let text = tokens.removeFirst()
                                    return QuizAddAction(text, correct: correct)
                                }
                            }
                        }
                    }
                }
            }
            
            // Iterate values
            for value in alone {
                // If it's the keyword we want
                if first == value.rawValue {
                    // Create action and return it
                    if value == .If && tokens.count >= 1 {
                        // If "condition"
                        let condition = tokens.removeFirst()
                        return IfAction(condition, do: [])
                    } else if value == .Else {
                        // Else
                        return ElseAction(do: [])
                    } else if value == .Print && tokens.count >= 1 {
                        // Print variable "identifier"
                        let identifier = tokens.removeFirst()
                        return PrintAction(identifier)
                    } else if value == .PrintApproximated && tokens.count >= 1 {
                        // Print approximated value of "identifier"
                        let identifier = tokens.removeFirst()
                        return PrintAction(identifier, approximated: true)
                    } else if value == .PrintText && tokens.count >= 1 {
                        // Print text "text"
                        let text = tokens.removeFirst()
                        return PrintTextAction(text)
                    }  else if value == .Unset && tokens.count >= 1 {
                        // Unset "identifier"
                        let identifier = tokens.removeFirst()
                        return UnsetAction(identifier)
                    } else if value == .While && tokens.count >= 1 {
                        // While "condition"
                        let condition = tokens.removeFirst()
                        return WhileAction(condition, do: [])
                    } else if value == .ListCreate && tokens.count >= 1 {
                        // Create list "identifier"
                        let identifier = tokens.removeFirst()
                        return ListCreateAction(identifier)
                    } else if value == .QuizInit && tokens.count >= 1 {
                        // Init quiz "text"
                        let text = tokens.removeFirst()
                        return QuizInitAction(text)
                    } else if value == .QuizAdd && tokens.count >= 1 {
                        // Add text "text"
                        let text = tokens.removeFirst()
                        return QuizAddAction(text)
                    } else if value == .QuizShow {
                        // Show quiz
                        return QuizShowAction()
                    }
                }
            }
        }
        
        // Nothing found
        return nil
    }
    
}
