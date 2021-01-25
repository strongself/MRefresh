import Foundation
import UIKit

typealias Constraint = (_ view: UIView) -> NSLayoutConstraint

protocol AnchorLayoutable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: AnchorLayoutable {}
extension UILayoutGuide: AnchorLayoutable {}

// MARK: ==

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                         _ to: KeyPath<UIView, Anchor>,
                         of secondView: UIView,
                         constant: CGFloat = 0,
                         priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        let constraint = firstView[keyPath: keyPath].constraint(equalTo: secondView[keyPath: to],
                                                                constant: constant)
        constraint.priority = priority
        return constraint
    }
}

func equalSafeArea<Axis, Anchor>(_ keyPath: KeyPath<AnchorLayoutable, Anchor>,
                                 to: KeyPath<AnchorLayoutable, Anchor>,
                                 of secondView: UIView,
                                 constant: CGFloat = 0,
                                 priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        let constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            constraint = firstView[keyPath: keyPath].constraint(
                equalTo: secondView.safeAreaLayoutGuide[keyPath: to],
                constant: constant
            )
        } else {
            constraint = firstView[keyPath: keyPath].constraint(
                equalTo: secondView[keyPath: to],
                constant: constant
            )
        }

        constraint.priority = priority
        return constraint
    }
}

func equalSafeArea<Axis, Anchor>(_ keyPath: KeyPath<AnchorLayoutable, Anchor>,
                                 of secondView: UIView,
                                 constant: CGFloat = 0,
                                 priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equalSafeArea(keyPath, to: keyPath, of: secondView, constant: constant, priority: priority)
}

func equalLayoutGuide<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                                    to: KeyPath<UIView, Anchor>,
                                    orLayoutGuide layoutGuide: KeyPath<UILayoutGuide, Anchor>,
                                    of secondView: UIView,
                                    constant: CGFloat = 0,
                                    priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        let constraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            constraint = firstView[keyPath: keyPath].constraint(
                equalTo: secondView.safeAreaLayoutGuide[keyPath: layoutGuide],
                constant: constant
            )
        } else {
            constraint = firstView[keyPath: keyPath].constraint(
                equalTo: secondView[keyPath: to],
                constant: constant
            )
        }

        constraint.priority = priority
        return constraint
    }
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                         of secondView: UIView,
                         constant: CGFloat = 0,
                         priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, keyPath, of: secondView, constant: constant, priority: priority)
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                         _ to: KeyPath<UILayoutGuide, Anchor>,
                         of secondView: UILayoutGuide,
                         constant: CGFloat = 0,
                         priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        let constraint = firstView[keyPath: keyPath].constraint(equalTo: secondView[keyPath: to],
                                                                constant: constant)
        constraint.priority = priority
        return constraint
    }
}

func equal<Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                   constant: CGFloat = 0,
                   priority: UILayoutPriority = .required) -> Constraint where Anchor: NSLayoutDimension {
    return { view in
        let constraint = view[keyPath: keyPath].constraint(equalToConstant: constant)
        constraint.priority = priority
        return constraint
    }
}

func equal<Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                    _ to: KeyPath<UIView, Anchor>,
                    of secondView: UIView,
                    constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutDimension {
    return { view in
        view[keyPath: keyPath].constraint(
            equalTo: secondView[keyPath: to],
            multiplier: 1.0,
            constant: constant
        )
    }
}

func lessThan<Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                      _ to: KeyPath<UIView, Anchor>,
                       of secondView: UIView,
                      constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutDimension {
    return { view in
        view[keyPath: keyPath].constraint(
            lessThanOrEqualTo: secondView[keyPath: to],
            multiplier: 1.0,
            constant: constant
        )
    }
}

// MARK: >=

func greaterThan<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                               _ to: KeyPath<UIView, Anchor>,
                               of secondView: UIView,
                               constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        firstView[keyPath: keyPath].constraint(greaterThanOrEqualTo: secondView[keyPath: to],
                                               constant: constant)
    }
}

func greaterThan<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                               of secondView: UIView,
                               constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return greaterThan(keyPath, keyPath, of: secondView, constant: constant)
}

func greaterThan<Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                         constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutDimension {
    return { view in
        view[keyPath: keyPath].constraint(greaterThanOrEqualToConstant: constant)
    }
}

// MARK: <=

func lessThan<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                            _ to: KeyPath<UIView, Anchor>,
                            of secondView: UIView,
                            constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return { firstView in
        firstView[keyPath: keyPath].constraint(lessThanOrEqualTo: secondView[keyPath: to],
                                               constant: constant)
    }
}

func lessThan<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                            of secondView: UIView,
                            constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutAnchor<Axis> {
    return lessThan(keyPath, keyPath, of: secondView, constant: constant)
}

func lessThan<Anchor>(_ keyPath: KeyPath<UIView, Anchor>,
                      constant: CGFloat = 0) -> Constraint where Anchor: NSLayoutDimension {
    return { view in
        view[keyPath: keyPath].constraint(lessThanOrEqualToConstant: constant)
    }
}

// MARK: UIView helpers

extension UIView {

    func addSubview(_ child: UIView, constraints: [Constraint]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.map { $0(child) })
    }

    func addSubview(_ child: UIView, insets: UIEdgeInsets) {
        let constraints = [
            equal(\.topAnchor, of: self, constant: insets.top),
            equal(\.bottomAnchor, of: self, constant: -insets.bottom),
            equal(\.leadingAnchor, of: self, constant: insets.left),
            equal(\.trailingAnchor, of: self, constant: -insets.right)
        ]
        addSubview(child, constraints: constraints)
    }
}
