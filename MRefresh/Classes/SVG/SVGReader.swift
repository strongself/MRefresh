//
//  SVGReader.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 10.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum SVGReaderError: Error {
    case cannotRead
}

class SVGReader {
    
    func read(_ svg: String) throws -> [SVGNode] {
        let scanner = Scanner(string: svg)
        
        var skippedCharacters = CharacterSet(charactersIn: ",")
        skippedCharacters.formUnion(CharacterSet.whitespacesAndNewlines)
        
        scanner.charactersToBeSkipped = skippedCharacters
        
        let allInstructions = SVGInstruction.allValues.map { $0.rawValue }.reduce("", +)
        let instructionSet = CharacterSet(charactersIn: allInstructions)
        
        var nsStringInstruction: NSString?
        var nodes: [SVGNode] = []
        let instructionStack = Stack<SVGInstruction>()
        
        while scanner.scanCharacters(from: instructionSet, into: &nsStringInstruction) {
            var x = 0.0
            var y = 0.0
            var points: [CGPoint] = []
            
            while scanner.scanDouble(&x) {
                scanner.scanDouble(&y)
                points.append(CGPoint(x: x, y: y))
            }
            
            guard let stringInstruction = nsStringInstruction as? String else {
                throw SVGReaderError.cannotRead
            }
            
            for character in stringInstruction.characters.reversed() {
                guard let instruction = SVGInstruction(rawValue: String(character)) else {
                    throw SVGReaderError.cannotRead
                }
                
                instructionStack.push(instruction)
            }
            
            while let instruction = instructionStack.pop() {
                if instruction == .vertical || instruction == .verticalRelative {
                    points[0].y = points[0].x
                    points[0].x = 0.0
                }
                
                let node = SVGNode(instruction: instruction, points: points)
                nodes.append(node)
            }
        }
        
        return nodes
    }

}

