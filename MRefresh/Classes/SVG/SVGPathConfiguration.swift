//
//  SVGPathConfiguration.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 01.01.17.
//  Copyright © 2017 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

public struct SVGPathConfiguration {
    let path: String
    let timesSmooth: Int
    let drawableFrame: CGRect
    
    public init(path: String, timesSmooth: Int, drawableFrame: CGRect) {
        self.path = path
        self.timesSmooth = timesSmooth
        self.drawableFrame = drawableFrame
    }
}
