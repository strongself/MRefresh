//
//  SVGPath.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 25.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class SVGPathContainer {
    private var startingNodes: [SVGNode] = []
    private var currentNodes: [SVGNode] = []
    
    private let reader = SVGReader()
    private let simplifier = SVGSimplifier()
    private let resizer = SVGResizer()
    private let converter = SVGConverter()
    private let smoother = SVGSmoother()
    
    var offset: CGPoint {
        return resizer.offset
    }
    
    var scale: CGFloat {
        return resizer.scale
    }
    
    init(svg: String,
         smooth: Int,
         drawableFrame: CGRect,
         offset: CGPoint = CGPoint.zero,
         scale: CGFloat = 0.0) throws {
        resizer.offset = offset
        resizer.scale = scale
        
        let readResult = try reader.read(svg)
        let simplified = simplifier.simplify(readResult)
        let resized = resizer.resize(simplified, to: drawableFrame)
        let smoothed = smoother.smooth(times: smooth, nodes: resized)
        
        startingNodes = smoothed
        currentNodes = startingNodes
    }
    
    func toPath(proportion: CGFloat? = nil) throws -> UIBezierPath {
        let amount = Int(CGFloat(currentNodes.count) * (proportion ?? 1.0))
        
        if amount < 2 {
            return UIBezierPath()
        }
        
        return try converter.convert(currentNodes, amount: amount)
    }
}
