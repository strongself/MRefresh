//
//  SVGSmoother.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 30.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class SVGSmoother {
    
    func smooth(times: Int, nodes: [SVGNode]) -> [SVGNode] {
        var newNodes = [nodes[0]]
        
        for index in 1 ... nodes.count - 1 {
            let previousNode = nodes[index - 1]
            let currentNode = nodes[index]
            
            switch currentNode.instruction {
            case .quadratic, .cubic, .line, .horizontal, .vertical:
                let currentNodes = splitCurveHalf(firstNode: previousNode, secondNode: currentNode, times: times)
                newNodes += currentNodes
            default:
                newNodes.append(currentNode)
            }
        }
        
        return newNodes
    }
    
    private func splitCurveHalf(firstNode: SVGNode, secondNode: SVGNode, times: Int) -> [SVGNode] {
        let firstPoint = firstNode.points.last ?? CGPoint.zero
        let lastPoint = secondNode.points.last ?? CGPoint.zero
        let points: [CGPoint] = [firstPoint] + secondNode.points
        
        var firstControlPoints: [CGPoint] = []
        var secondControlPoints: [CGPoint] = [lastPoint]
        
        splitCurveHelper(points: points, firstControlPoints: &firstControlPoints, secondControlPoints: &secondControlPoints)
        let newFirstNode = SVGNode(instruction: secondNode.instruction,
                                   points: firstControlPoints)
        
        let newSecondNode = SVGNode(instruction: secondNode.instruction,
                                    points: secondControlPoints.reversed())
        
        if times > 0 {
            let firstHalf = splitCurveHalf(firstNode: firstNode, secondNode: newFirstNode, times: times - 1)
            let secondHalf = splitCurveHalf(firstNode: newFirstNode, secondNode: newSecondNode, times: times - 1)
            
            return firstHalf + secondHalf
        } else {
            return [newFirstNode, newSecondNode]
        }
    }
    
    private func splitCurveHelper(points: [CGPoint], firstControlPoints: inout [CGPoint], secondControlPoints: inout [CGPoint]) {
        
        guard points.count > 1 else { return }
        
        var newPoints: [CGPoint] = []
        let firstNewPoint = midpoint(points[0], points[1])
        
        newPoints.append(firstNewPoint)
        firstControlPoints.append(firstNewPoint)
        
        for index in 1 ..< points.count - 1 {
            let newPoint = midpoint(points[index], points[index + 1])
            newPoints.append(newPoint)
            
            if index == points.count - 2 {
                secondControlPoints.append(newPoint)
            }
        }
        
        splitCurveHelper(points: newPoints,
                         firstControlPoints: &firstControlPoints,
                         secondControlPoints: &secondControlPoints)
    }
    
    private func midpoint(_ firstPoint: CGPoint, _ secondPoint: CGPoint) -> CGPoint {
        let x = firstPoint.x * 0.5 + secondPoint.x * 0.5
        let y = firstPoint.y * 0.5 + secondPoint.y * 0.5
        return CGPoint(x: x, y: y)
    }
}
