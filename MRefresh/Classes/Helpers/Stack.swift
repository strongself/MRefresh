//
//  Helpers.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 25.12.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

class Node<T> {
    var element: T
    var nextNode: Node<T>?
    
    init (element: T) {
        self.element = element
    }
}

class Stack<T> {
    var node: Node<T>?
    var empty: Bool {
        return node == nil
    }
    
    func pop() -> T? {
        if node != nil {
            let element = node?.element
            node = node?.nextNode
            
            return element
        } else {
            return nil
        }
    }
    
    func push(_ element: T) {
        let newNode	= Node<T>(element: element)
        newNode.nextNode = node
        node = newNode
    }
}
