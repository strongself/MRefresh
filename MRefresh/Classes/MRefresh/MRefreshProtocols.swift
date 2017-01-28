//
//  MRefreshProtocols.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 08.01.17.
//  Copyright © 2017 m.rakhmanov. All rights reserved.
//

import UIKit

public typealias ActionHandler = () -> ()

public protocol MRefreshAnimatable {
    func drawIndicatorView(proportion: CGFloat)
    func startAnimation()
    func stopAnimation()
}

public protocol HasView {
    var getView: UIView { get }
}

extension UIView: HasView {
    public var getView: UIView {
        return self
    }
}

public protocol MRefreshAnimatableViewConforming: MRefreshAnimatable, HasView {}
