import Foundation
import UIKit

public enum SVGReaderError: Error {
    case cannotRead
    case invalidPoints
}

/// Reads SVG strings and converts them to nodes
protocol SVGReader {
    /// Converts the string to nodes
    func read(_ svg: String) throws -> [SVGNode]
}

final class SVGReaderImpl: SVGReader {
    func read(_ svg: String) throws -> [SVGNode] {
        let scanner = Scanner(string: svg)

        var skippedCharacters = CharacterSet(charactersIn: ",")
        skippedCharacters.formUnion(CharacterSet.whitespacesAndNewlines)

        scanner.charactersToBeSkipped = skippedCharacters
        var nsStringInstruction: NSString?
        var nodes: [SVGNode] = []
        // this looks ugly but we can scan by character only after ios 13.0
        while scanner.scanCharacters(from: CharacterSet.letters, into: &nsStringInstruction) {
            // TODO: make better errors and simplify the parsing
            guard let stringInstructions = nsStringInstruction as String? else {
                throw SVGReaderError.cannotRead
            }
            let instructions = stringInstructions.compactMap { SVGInstruction(rawValue: String($0)) }
            // we have unknown symbols
            if instructions.count != stringInstructions.count {
                throw SVGReaderError.cannotRead
            }
            switch instructions.count {
                case 0:
                    throw SVGReaderError.cannotRead
                case 1:
                    let instruction = instructions.first!
                    if instruction == .closePath || instruction == .closePathSmall {
                        nodes.append(SVGNode(instruction: instruction, points: []))
                        continue
                    }
                    nodes += try scanValues(scanner: scanner, instruction: instruction)
                default:
                    let allFirstIsClosePaths = instructions.dropLast().filter {
                        $0 != .closePath && $0 != .closePathSmall
                    }.count == 0
                    if !allFirstIsClosePaths {
                        throw SVGReaderError.cannotRead
                    }
                    instructions.dropLast().forEach {
                        nodes.append(SVGNode(instruction: $0, points: []))
                    }
                    let lastInstruction = instructions.last!
                    if lastInstruction == .closePath || lastInstruction == .closePathSmall {
                        nodes.append(SVGNode(instruction: lastInstruction, points: []))
                        continue
                    }
                    nodes += try scanValues(scanner: scanner, instruction: lastInstruction)
            }
        }
        if !scanner.isAtEnd {
            throw SVGReaderError.cannotRead
        }
        return nodes
    }

    private func scanValues(scanner: Scanner, instruction: SVGInstruction) throws -> [SVGNode] {
        var value: Double = 0.0
        var values: [CGFloat] = []
        
        while scanner.scanDouble(&value) {
            values.append(CGFloat(value))
        }

        if values.count % instruction.valuesCount != 0 {
            throw SVGReaderError.invalidPoints
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
