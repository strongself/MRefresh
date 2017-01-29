//
//  MRefreshViewConfiguration.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 07.01.17.
//  Copyright © 2017 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

struct MRefreshViewConfiguration {
    let frame: CGRect
    let animatable: MRefreshAnimatableViewConforming
    let scrollView: UIScrollView
    let animationEndDistanceOffset: CGFloat
    let animationStartDistance: CGFloat
    let handler: ActionHandler
    let contentInsetChangeAnimationDuration: Double
}

public struct MRefreshConfiguration {
    let heightIncrease: CGFloat
    let animationEndDistanceOffset: CGFloat
    let animationStartDistance: CGFloat
    let contentInsetChangeAnimationDuration: Double
    
    public init(heightIncrease: CGFloat,
         animationEndDistanceOffset: CGFloat,
         animationStartDistance: CGFloat,
         contentInsetChangeAnimationDuration: Double) {
        self.heightIncrease = heightIncrease
        self.animationEndDistanceOffset = animationEndDistanceOffset
        self.animationStartDistance = animationStartDistance
        self.contentInsetChangeAnimationDuration = contentInsetChangeAnimationDuration
    }
}
