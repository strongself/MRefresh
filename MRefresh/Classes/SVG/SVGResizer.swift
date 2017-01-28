//
//  SVGResizer.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 25.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class SVGResizer {
    var offset: CGPoint = CGPoint.zero
    var scale: CGFloat = 0.0
    
    func resize(_ nodes: [SVGNode], to newFrame: CGRect) -> [SVGNode] {
        offset = offset == CGPoint.zero ? calculateOffset(nodes) : offset
        
        let normalized = normalize(nodes, offset: offset)
        
        if scale == 0.0 {
            let size = calculateSize(for: normalized)
            scale = calcualteScale(first: newFrame.size, second: size)
        }
        
        let rescaled = rescale(normalized, scale: scale)
        let moved = move(to: newFrame.origin, nodes: rescaled)
        
        return moved
    }
    
    private func calculateOffset(_ nodes: [SVGNode]) -> CGPoint {
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = minX
        
        for node in nodes {
            for point in node.points {
                minX = min(point.x, minX)
                minY = min(point.y, minY)
            }
        }
        
        return CGPoint(x: minX, y: minY)
    }
    
    private func normalize(_ nodes: [SVGNode], offset: CGPoint) -> [SVGNode] {
        return nodes.map { node in
            return SVGNode(instruction: node.instruction,
                           points: node.points.map { CGPoint(x: $0.x - offset.x, y: $0.y - offset.y) })
        }
    }
    
    private func rescale(_ nodes: [SVGNode], scale: CGFloat) -> [SVGNode] {
        return nodes.map { node in
            return SVGNode(instruction: node.instruction,
                           points: node.points.map { CGPoint(x: $0.x * scale, y: $0.y * scale) })
        }
    }
    
    private func calculateSize(for nodes: [SVGNode]) -> CGSize {
        var maxX: CGFloat = 0.0
        var maxY = maxX
        
        for node in nodes {
            for point in node.points {
                maxX = max(point.x, maxX)
                maxY = max(point.y, maxY)
            }
        }
        
        return CGSize(width: maxX, height: maxY)
    }
    
    private func calcualteScale(first: CGSize, second: CGSize) -> CGFloat {
        return min(first.width / second.width, first.height / second.height)
    }
    
    private func move(to point: CGPoint, nodes: [SVGNode]) -> [SVGNode] {
        return nodes.map { node in
            return SVGNode(instruction: node.instruction,
                           points: node.points.map { CGPoint(x: $0.x + point.x, y: $0.y + point.y) })
        }
    }
}
