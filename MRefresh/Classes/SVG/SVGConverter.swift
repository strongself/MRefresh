//
//  SVGConverter.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 25.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

enum SVGConverterError: Error {
    case invalidArgs
    case noStartingPoint
}

class SVGConverter {
    
    func convert(_ nodes: [SVGNode], amount: Int? = nil) throws -> UIBezierPath {
        guard nodes.count > 1 else {
            throw SVGConverterError.invalidArgs
        }
        
        let concreteAmount = amount ?? nodes.count
        let path = UIBezierPath()
        
        let subpathPointsStack = Stack<CGPoint>()
        
        if nodes[0].instruction != .move {
            throw SVGConverterError.noStartingPoint
        }
        
        path.move(to: nodes[0].points[0])
        
        for index in 1 ..< concreteAmount {
            addNode(nodes[index], path: path, stack: subpathPointsStack)
        }
        
        return path
    }
    
    private func addNode(_ currentNode: SVGNode, path: UIBezierPath, stack: Stack<CGPoint>) {
        switch currentNode.instruction {
        case .line:
            path.addLine(to: currentNode.points[0])
            
        case .cubic:
            path.addCurve(to: currentNode.points[2], controlPoint1: currentNode.points[0], controlPoint2: currentNode.points[1])
            
        case .quadratic:
            path.addQuadCurve(to: currentNode.points[1], controlPoint: currentNode.points[0])
            
        case .horizontal:
            path.addLine(to: currentNode.points[0])
            
        case .vertical:
            path.addLine(to: currentNode.points[0])
            
        case .move:
            path.move(to: currentNode.points[0])
            stack.push(currentNode.points[0])
            
        case .closePathSmall, .closePath:
            if let point = stack.pop() {
                path.move(to: point)
            }
            
        default:
            break
        }
    }
}
