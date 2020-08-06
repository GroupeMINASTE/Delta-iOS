//
//  StringExtension.swift
//  Delta
//
//  Created by Nathan FALLET on 07/09/2019.
//  Copyright © 2019 Nathan FALLET. All rights reserved.
//

import Foundation
import UIKit

extension String {

    // Localization
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }

    func format(_ args : CVarArg...) -> String {
        return String(format: self, locale: .current, arguments: args)
    }

    func format(_ args : [String]) -> String {
        return String(format: self, locale: .current, arguments: args)
    }
    
    func groups(for regexPattern: String) -> [[String]] {
        do {
            let text = self
            let regex = try NSRegularExpression(pattern: regexPattern)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return matches.map { match in
                return (0 ..< match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func cutEditorLine() -> [String] {
        var parts = [String]()
        var current = ""

        for char in self {
            current += String(char)
            
            if current.hasSuffix("%@") {
                let previous = current[0 ..< current.count-2]
                if !previous.isEmpty {
                    parts.append(previous)
                }
                parts.append("%@")
                current = ""
            }
        }

        if !current.isEmpty {
            parts.append(current)
        }
        
        return parts
    }
    
    func capitalizeFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    // Operation
    
    func toOperation() -> Operation? {
        // Iterate values
        for value in [Operation.addition, Operation.subtraction, Operation.multiplication, Operation.division, Operation.modulo, Operation.power, Operation.root, Operation.equals, Operation.unequals, Operation.greaterThan, Operation.lessThan, Operation.greaterOrEquals, Operation.lessOrEquals, Operation.list1, Operation.list2, Operation.function] {
            // If it's the value we want
            if self == value.rawValue {
                return value
            }
        }
        
        // Nothing found
        return nil
    }
    
    // Colors
    
    func toColor() -> UIColor {
        switch self {
        case "emerald":
            return .emerald
        case "river":
            return .river
        case "amethyst":
            return .amethyst
        case "asphalt":
            return .asphalt
        case "carrot":
            return .carrot
        case "alizarin":
            return .alizarin
        default:
            return AlgorithmIcon.defaultColor.toColor()
        }
    }
    
    // Icons
    
    func toIcon() -> UIImage? {
        return UIImage(named: "Icon\(capitalizeFirstLetter())") ?? AlgorithmIcon.defaultIcon.toIcon()
    }
    
    // Tokens
    
    func replaceTokens(in process: Process) -> String {
        var output = self
        
        // Get "" to interprete them
        for group in output.groups(for: "\"[^\"]*\"") {
            // Get token based on string
            let token = TokenParser(group[0][1 ..< group[0].count-1], in: process).execute()
            
            // Replace with tokens
            if let range = output.range(of: group[0]) {
                output = output.replacingCharacters(in: range, with: token.compute(with: process.variables, mode: .formatted).toString())
            }
        }
        
        return output
    }
    
    func attributedMath() -> NSAttributedString {
        let workspace = NSMutableAttributedString(string: self)
        let power: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .baselineOffset: 8]
        let index: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10), .baselineOffset: -5]
        
        // Powers (numbers)
        let numbers = String(workspace.mutableString).groups(for: " ?\\^ ?([0-9a-zA-Z]+)")
        for group in numbers {
            let range = workspace.mutableString.range(of: group[0])
            workspace.addAttributes(power, range: range)
            workspace.replaceCharacters(in: range, with: group[1])
        }
        
        // Powers (expressions)
        let expressions = String(workspace.mutableString).groups(for: " ?\\^ ?\\(([0-9a-zA-Z*\\+\\-/ ]+)\\)")
        for group in expressions {
            let range = workspace.mutableString.range(of: group[0])
            workspace.addAttributes(power, range: range)
            workspace.replaceCharacters(in: range, with: group[1])
        }
        
        // Indexes (variables)
        let variables = String(workspace.mutableString).groups(for: "_([0-9a-zA-Z])")
        for group in variables {
            let range = workspace.mutableString.range(of: group[0])
            workspace.addAttributes(index, range: range)
            workspace.replaceCharacters(in: range, with: group[1])
        }
        
        // Indexes (expressions)
        let expressions2 = String(workspace.mutableString).groups(for: "_\\(([0-9a-zA-Z*\\+\\-/ ]+)\\)")
        for group in expressions2 {
            let range = workspace.mutableString.range(of: group[0])
            workspace.addAttributes(index, range: range)
            workspace.replaceCharacters(in: range, with: group[1])
        }
        
        return workspace
    }
    
    func indentLines() -> String {
        return self.split(separator: "\n").map{ "    \($0)" }.joined(separator: "\n")
    }
    
    // Subscript
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)), upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Paris")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: self)
    }

}
