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
}
