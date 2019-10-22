//
//  EditorLineCategory.swift
//  Delta
//
//  Created by Nathan FALLET on 22/10/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation

enum EditorLineCategory: String {
    
    case variable = "variable", structure = "structure", output = "output", add = "add"
    
    static let list: [EditorLineCategory] = [.variable, .structure, .output]
    
    func catalog() -> [Action] {
        switch self {
        case .variable:
            return [InputAction("a", default: TokenParser("0").execute()), SetAction("a", to: TokenParser("0").execute()), SetAction("f(x)", to: TokenParser("ax+b").execute(), format: true)]
        case .structure:
            return [IfAction(TokenParser("a=b").execute(), do: []), ElseAction(do: []), WhileAction(TokenParser("a=b").execute(), do: []), ForAction("a", in: TokenParser("b").execute(), do: [])]
        case .output:
            return [PrintAction("a")]
        default:
            return []
        }
    }
    
}