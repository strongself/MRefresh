import Foundation
import UIKit

public struct SVGPath {
    public let nodes: [SVGNode]
}

/// Converts one path to nodes without resizing it
protocol SVGPathFactory {
    func make(svg: String, smoothDepth: Int) throws -> SVGPath
}

final class SVGPathFactoryImpl: SVGPathFactory {
    private let reader: SVGReader
    private let simplifier: SVGSimplifier
    private let smoother: SVGSmoother
    
    init(reader: SVGReader = SVGReaderImpl(),
         simplifier: SVGSimplifier = SVGSimplifierImpl(),
         smoother: SVGSmoother = SVGSmootherImpl()) {
        self.reader = reader
        self.simplifier = simplifier
        self.smoother = smoother
    }
    
    func make(svg: String, smoothDepth: Int) throws -> SVGPath {
        let readResult = try reader.read(svg)
        let simplified = simplifier.simplify(readResult)
        let smoothed = smoother.smooth(times: smoothDepth, nodes: simplified)
        
        return SVGPath(nodes: smoothed)
    }
}

