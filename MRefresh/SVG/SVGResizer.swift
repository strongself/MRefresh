import Foundation
import UIKit

struct ResizingParameters {
    let scale: CGFloat
    let offset: CGPoint
}

/// Class that converts the original svg points into points inside the specific size
final class SVGResizer {
    /// resizing svg to fit the new frame
    func getResizingParameters(_ nodes: [SVGNode], for newSize: CGSize) -> ResizingParameters {
        let minCoordinate = calculateLimitPoint(
            nodes,
            limit: min,
            start: .greatestFiniteMagnitude
        )
        
        // shifting all points using minCoordinate
        let normalized = normalize(nodes, offset: minCoordinate)
        
        // calculating max coordinate to get the size of the path
        let maxCoordinate = calculateLimitPoint(
            normalized,
            limit: max,
            start: 0.0
        )
        let size = CGSize(width: maxCoordinate.x, height: maxCoordinate.y)
        // calculating the scale between svg points and the frame
        let scale = calcualteScale(first: newSize, second: size)
        // getting the offset to center the path inside size
        let offset = CGPoint(x: abs(newSize.width - size.width * scale) / 2.0, y: abs(newSize.height - size.height * scale) / 2.0)
        return ResizingParameters(
            scale: scale,
            offset: offset
        )
    }
    
    private func normalize(_ nodes: [SVGNode], offset: CGPoint) -> [SVGNode] {
        return nodes.map { node in
            return SVGNode(instruction: node.instruction,
                           points: node.points.map { CGPoint(x: $0.x - offset.x, y: $0.y - offset.y) })
        }
    }
    
    func rescaled(_ nodes: [SVGNode], scale: CGFloat) -> [SVGNode] {
        nodes.map { node in
            SVGNode(instruction: node.instruction,
                    points: node.points.map { CGPoint(x: $0.x * scale, y: $0.y * scale) })
        }
    }
    
    func moved(_ nodes: [SVGNode], offset: CGPoint) -> [SVGNode] {
        nodes.map { node in
            SVGNode(instruction: node.instruction,
                    points: node.points.map { $0.offset(offset) })
        }
    }
    
    private func calcualteScale(first: CGSize, second: CGSize) -> CGFloat {
        return min(first.width / second.width, first.height / second.height)
    }
    
    private func calculateLimitPoint(_ nodes: [SVGNode], limit: (CGFloat, CGFloat) -> CGFloat, start: CGFloat) -> CGPoint {
        var x = start
        var y = x
        
        for node in nodes {
            for point in node.points {
                x = limit(point.x, x)
                y = limit(point.y, y)
            }
        }
        
        return CGPoint(x: x, y: y)
    }
}

