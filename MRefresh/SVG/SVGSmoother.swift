import Foundation
import UIKit

final class SVGSmoother {
    
    func smooth(times: Int, nodes: [SVGNode]) -> [SVGNode] {
        guard !nodes.isEmpty && times >= 1 else {
            return nodes
        }
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
        // we split only the nodes that have more than one point
        let lastPointOfFirstNode = firstNode.points.last!
        let lastPointOfSecondNode = secondNode.points.last!
        let points: [CGPoint] = [lastPointOfFirstNode] + secondNode.points
        
        var firstControlPoints: [CGPoint] = []
        var secondControlPoints: [CGPoint] = [lastPointOfSecondNode]
        
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
