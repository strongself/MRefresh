@testable import MRefresh

class SVGSimplifierMock: SVGSimplifier {
    var returnValue: [SVGNode] = []
    var nodes: [SVGNode]?

    func simplify(_ nodes: [SVGNode]) -> [SVGNode] {
        self.nodes = nodes

        return returnValue
    }
}
