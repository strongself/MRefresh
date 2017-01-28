//
//  SVGSimplifier.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 25.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class SVGSimplifier {
    
    func simplify(_ nodes: [SVGNode]) -> [SVGNode] {
        guard nodes.count > 1 else {
            return nodes
        }
        
        let subpathPointsStack = Stack<SVGNode>()
        var convertedNodes: [SVGNode] = []
        let firstNode = nodes[0]
        
        convertedNodes.append(firstNode)
        if firstNode.instruction == .moveRelative || firstNode.instruction == .move {
            subpathPointsStack.push(firstNode)
        }
        
        for index in 1 ..< nodes.count {
            var offsetNode = convertedNodes[index - 1]
            if nodes[index - 1].instruction == .closePath || nodes[index - 1].instruction == .closePathSmall {
                if let previousNode = subpathPointsStack.pop() {
                    offsetNode = previousNode
                }
            }

            if nodes[index].instruction.isRelative {
                let convertedNode = convertRelativeNode(nodes[index], lastNode: offsetNode)
                convertedNodes.append(convertedNode)
            } else {
                var newNode = nodes[index]
                if newNode.instruction == .vertical {
                    newNode.points[0].x = offsetNode.points.last?.x ?? 0.0
                } else if newNode.instruction == .horizontal {
                    newNode.points[0].y = offsetNode.points.last?.y ?? 0.0
                }
                
                convertedNodes.append(newNode)
            }
            
            if convertedNodes[index].instruction.isShorthand {
                let lastPointsCount = convertedNodes[index - 1].points.count
                
                let updatedPoint: CGPoint
                if lastPointsCount > 1 {
                    let previousPoint = convertedNodes[index - 1].points[lastPointsCount - 1]
                    let previousControlPoint = convertedNodes[index - 1].points[lastPointsCount - 2]
                    
                    updatedPoint = CGPoint(x: 2.0 * previousPoint.x - previousControlPoint.x,
                                           y: 2.0 * previousPoint.y - previousControlPoint.y)
                } else {
                    updatedPoint = convertedNodes[index - 1].points[0]
                }
                
                convertedNodes[index].points.insert(updatedPoint, at: 0)
                convertedNodes[index].instruction = convertedNodes[index].instruction.nonShorthand
            }
            
            if nodes[index].instruction == .moveRelative || nodes[index].instruction == .move {
                subpathPointsStack.push(convertedNodes[index])
            }
        }
        
        return convertedNodes
    }
    
    private func convertRelativeNode(_ currentNode: SVGNode, lastNode: SVGNode) -> SVGNode {
        return SVGNode(instruction: currentNode.instruction.nonRelative,
                       points: nonRelativePoints(from: lastNode.points.last ?? CGPoint.zero,
                                                 with: currentNode.points))
    }
    
    private func nonRelativePoints(from point: CGPoint, with points: [CGPoint]) -> [CGPoint] {
        return points.map { point.offset($0) }
    }
    
}
