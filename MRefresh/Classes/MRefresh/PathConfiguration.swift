//
//  PathConfiguration.swift
//  Pods
//
//  Created by m.rakhmanov on 29.01.17.
//
//

import Foundation

public struct PathConfiguration {
    let lineWidth: CGFloat
    let strokeColor: UIColor
    
    public init(lineWidth: CGFloat, strokeColor: UIColor) {
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
    }
}
