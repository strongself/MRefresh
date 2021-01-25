import Foundation
import UIKit

enum SVGReaderError: Error {
    case cannotRead
    case arcNotSupported
}

/// This class provides for reading svg string and converting it to nodes
class SVGReader {
    
    /// Convert string into nodes
    func read(_ svg: String) throws -> [SVGNode] {
        let scanner = Scanner(string: svg)
        
        var skippedCharacters = CharacterSet(charactersIn: ",")
        skippedCharacters.formUnion(CharacterSet.whitespacesAndNewlines)
        
        scanner.charactersToBeSkipped = skippedCharacters
        
        let allInstructions = SVGInstruction.allCases.map { $0.rawValue }.reduce("", +)
        let instructionSet = CharacterSet(charactersIn: allInstructions)
        
        var nsStringInstruction: NSString?
        var nodes: [SVGNode] = []
        
        while scanner.scanCharacters(from: instructionSet, into: &nsStringInstruction) {
            guard let stringInstruction = nsStringInstruction as String? else {
                throw SVGReaderError.cannotRead
            }
            let instructions = stringInstruction.compactMap { SVGInstruction(rawValue: String($0)) }
            if instructions.isEmpty {
                throw SVGReaderError.cannotRead
            }
            if instructions[0] == .closePath || instructions[0] == .closePathSmall {
                nodes.append(SVGNode(instruction: instructions[0], points: []))
                if instructions.count == 1 {
                    break
                }
            }
            let instruction = instructions.last!
            if instruction == .arc || instruction == .arcRelative {
                throw SVGReaderError.arcNotSupported
            }
            
            nodes += scanValues(scanner: scanner, instruction: instruction)
        }
        
        return nodes
    }
    
    private func scanValues(scanner: Scanner, instruction: SVGInstruction) -> [SVGNode] {
        var value: Double = 0.0
        var values: [CGFloat] = []
        
        while scanner.scanDouble(&value) {
            values.append(CGFloat(value))
        }
        // different commands provide for different points count
        // so we chunk them
        // also some commands can be repeated (e.g. we can have hundreds of values which we need to split)
        let chunkedValues = values.chunked(into: instruction.valuesCount)
        return chunkedValues.map { group in
            switch instruction {
            case .horizontal, .horizontalRelative:
                return SVGNode(instruction: instruction, points: [CGPoint(x: group[0], y: 0.0)])
            case .vertical, .verticalRelative:
                return SVGNode(instruction: instruction, points: [CGPoint(x: 0.0, y: group[0])])
            default:
                let points = group.chunked(into: 2).map {
                    CGPoint(x: $0[0], y: $0[1])
                }
                return SVGNode(instruction: instruction, points: points)
            }
        }
    }
}

fileprivate extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
