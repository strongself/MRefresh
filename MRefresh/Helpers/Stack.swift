// TODO: Just use plain array instead of Stack
struct Stack<T> {
    private var array: [T] = []
    
    var empty: Bool {
        return array.isEmpty
    }
    
    mutating func push(_ element: T) {
        array.append(element)
    }
    
    mutating func pop() -> T? {
        return array.popLast()
    }
}
