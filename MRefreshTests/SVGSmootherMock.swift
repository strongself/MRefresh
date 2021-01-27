@testable import MRefresh

class SVGSmootherMock: SVGSmoother {
    var returnValue: [SVGNode] = []
    var parameters: (times: Int, nodes: [SVGNode])?

    func smooth(times: Int, nodes: [SVGNode]) -> [SVGNode] {
        parameters = (times: times, nodes: nodes)

        return returnValue
    }
}
