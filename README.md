# MRefresh

[![CI Status](http://img.shields.io/travis/Mikhail Rakhmanov/MRefresh.svg?style=flat)](https://travis-ci.org/Mikhail Rakhmanov/MRefresh)
[![Version](https://img.shields.io/cocoapods/v/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)
[![License](https://img.shields.io/cocoapods/l/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)
[![Platform](https://img.shields.io/cocoapods/p/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)

## What is MRefresh and why you may find it useful?

So basically MRefresh is a pull-to-refresh with a clear separation of concerns which consits of several independent components:
- a pull-to-refresh mechanism which adds a container view to a scrollview. This container view uses an animatable view conforming to *MRefreshAnimatableViewConforming* which receives messages from such container view during each of the pull-to-refresh stages (see description below). It does not know anything about the layers of such animatable view, its animations etc,
- a path drawing mechanism which can read SVG paths (*SVGPathManager* object), convert them to UIBezierPath objects, add additional points to such paths, so the drawing would be more smooth (using De Castelaju's Algorithm - https://en.wikipedia.org/wiki/De_Casteljau's_algorithm). Also you can combine many SVG paths, which may be drawn simultaneously,
- a default implementation of the animatable view which calls *SVGPathManager* and asks it to provide the UIBezierPath object which will be drawn inside of animatable view's layer

To sum up, you can:
- take *most* SVG paths (though as of today arc command have not been implemented) and draw them in any combination when user pulls the scrollview,
- provide your custom animations when e.g. the files are loading and when the loading is completed (see below)

So here's a quick demo of what this library can do:

![Alt Text](https://github.com/mcrakhman/FilesRepository/blob/master/pull-to-refresh.gif)

### Pull-to-refresh mechanism

Below see brief description of the pull-to-refresh mechanism. First of all, there is an extension to UIScrollView which enables you to add a view which conforms to a specific protocol *MRefreshAnimatableViewConforming*. This view will receive certain messages from the UIScrollView when users pulls it and releases it. 

We can think of a pull-to-refresh as a 4 stage process.

#### First stage

The content offset of the scrollview hasn't reached some starting value (*startValue*) when the animatable view becomes visible.

#### Second stage

The content offset of the scrollview has reached the starting value, and the MRefreshView (which is a container view used under the hood) tells your view to *drawIndicatorView(proportion: CGFloat)*. The proportion will be a CGFloat value from 0 to 1 depending on whether the contentoffset has reached some other value, let's call it the *endValue*.

In case of *MRefreshAnimatableView* which is a view conforming to  *MRefreshAnimatableViewConforming* and is provided in the library, the proportion value will tell your view how many points in a path should be displayed on screen. Please note that you can use any view which can respond to the messages being sent to the view, not only *MRefreshAnimatableView*.

#### Third stage

The content offset of the scrollview has reached the *endValue*. Now:
- the view receives the *startAnimation* message,
- the scrollview's inset is increased to fit the animatable view with some additional space,
- the actionHandler closure is called (e.g. some services shall start downloading something etc)

In case of *MRefreshAnimatableView* it calls a *processingAnimationClosure(CALayer)*. This closure has a default implementation, though you can define your own animations on a layer.  

#### Fourth stage

The scrollview receives *stopAnimating* message (you should send the message when e.g. the data/error is received). After that if user is not holding the view with his finger, the view will receive *stopAnimation* message. Again if we're talking about the *MRefreshAnimatableView* it calls the *endAnimationClosure(CALayer, completion: () -> ())*. So you should either use a default implementation or you can provide your own animation on the layer and call completion when it is finished. Please bear in mind the respective timing, because after user releases its finger the scrollview changes its insets to initial value.  

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

MRefresh is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MRefresh"
```
## Author

Mikhail Rakhmanov, rakhmanov.m@gmail.com

## License

MRefresh is available under the MIT license. See the LICENSE file for more info.
