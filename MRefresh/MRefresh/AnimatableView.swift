import UIKit

public typealias ActionHandler = () -> Void

/// Conform your custom view to this protocol to provide your own custom animations
public protocol AnimatableView {
    /// When this function is called your view should draw some proportion of the picture/path etc
    func drawPullToRefresh(proportion: CGFloat)
    /// This function is called when the scroll view has been pulled far enough, so the animation should start
    /// Most of the time it is the moment when you want to start loading some data
    func startAnimation()
    /// This function is called when the user requests the scroll view to stop animating (e.g. when the data is loaded)
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

// Using this construction (with ugly HasView) to avoid providing base class for the view
public protocol AnimatableViewConforming: AnimatableView, HasView {}
