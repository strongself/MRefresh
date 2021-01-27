@testable import MRefresh

enum MockError: Error {
    case somethingHappened
}

class SVGReaderMock: SVGReader {
    var returnValue: [SVGNode]? = []
    var svg: String?

    func read(_ svg: String) throws -> [SVGNode] {
        self.svg = svg

        if let returnValue = returnValue {
            return returnValue
        }
        throw MockError.somethingHappened
    }
}
