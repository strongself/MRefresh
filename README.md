# MRefresh

[![CI Status](http://img.shields.io/travis/Mikhail Rakhmanov/MRefresh.svg?style=flat)](https://travis-ci.org/Mikhail Rakhmanov/MRefresh)
[![Version](https://img.shields.io/cocoapods/v/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)
[![License](https://img.shields.io/cocoapods/l/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)
[![Platform](https://img.shields.io/cocoapods/p/MRefresh.svg?style=flat)](http://cocoapods.org/pods/MRefresh)

## What is MRefresh and why you may find it useful?

So basically MRefresh is a pull-to-refresh with a clear separation of concerns which consits of several independent components:
- a pull-to-refresh mechanism which adds a container view to a scrollview. This container view uses an animatable view conforming to *MRefreshAnimatableViewConforming* protocol. The view receives messages during each of the pull-to-refresh stages (see description below),
- a path drawing mechanism which can read SVG paths (*SVGPathManager* object), convert them to UIBezierPath objects, add additional points to such paths, so the drawing would be more smooth (using De Castelaju's Algorithm - https://en.wikipedia.org/wiki/De_Casteljau's_algorithm). Also you can combine many SVG paths, which may be drawn simultaneously,
- a default implementation of the animatable view which calls *SVGPathManager* and asks it to provide the UIBezierPath object which will be drawn inside of animatable view's layer

To sum up, you can:
- take *most* SVG paths (though as of today arc command have not been implemented) and draw them in any combination when user pulls the scrollview,
- provide your own custom animations to the pull-to-refresh view

So here's a quick demo of what this library can do (we are drawing one of the FontAwesome SVG paths):

![Alt Text](https://github.com/mcrakhman/FilesRepository/blob/master/pull-to-refresh.gif)

### Example

Below see the steps needed to configure the pull-to-refresh view. Of course, if you don't want to read the long description, you can download the example and see everything for yourself.

#### SVGPathManager

The library was made in a way that enables you to configure all parameters of the pull-to-refresh process.

Firstly, you need and SVG Path, let it be something like this (it is a path that was taken from one of the FontAwesome icons, no copyrights infringed I hope): 

```swift
let path = "M1247 161q-5 154 -56 297.5t-139.5 260t-205 205t-260 139.5t-297.5 56q-14 1 -23 -9q-10 -10 -10 -23v-128q0 -13 9 -22t22 -10q204 -7 378 -111.5t278.5 -278.5t111.5 -378q1 -13 10 -22t22 -9h128q13 0 23 10q11 9 9 23"
```
Secondly, you need to create a path configuration:

```swift
let configuration = SVGPathConfiguration(path: svg, // path string
                                         timesSmooth: 3, // amount of points = initialSvgPoints * 2 ^ 3
                                         drawableFrame: frame) // frame to which the svg should be resized
```

Thirdly, you should provide timing for the path to be drawn. Such timing should be a value from 0.0 to 1.0, where 0.0 tells that the animatable view should appear on screen. So if you set it to for example 0.95 the path will start to appear when the content offset reaches somewhat near the endValue (i.e. near the stage when the actionHandler is called), so the path will be drawn very fast.

```swift
let configurationTime: ConfigurationTime = (time: 0.0,
                                            configuration: configuration)
```
To avoid any doubts, you can use many svg's and configurations to configure complex paths as seen in the gif above:

```swift
let configurationTimes = [firstConfigurationTime, secondConfigurationTime]
```

Then it is time to create the *SVGPathManager* which will do all the hard work converting and resizing your SVG's.

```swift
let pathManager = try! SVGPathManager(configurationTimes: [secondConfigurationTime, firstConfigurationTime],
                                      shouldScaleAsFirstElement: true)
```

The *shouldScaleAsFirstElement* tells the manager that you should use the same scale for all your paths (namely the scale of the first configuration). In practice it means that when you split your path into several components which are drawn simultaneously, you obviously want to use the same scale, otherwise you wouldn't get the expected path in the end.

#### MRefreshAnimatableView

When you've done creating the path manager it is time to create the animatable view. You can do it like so:
```swift
let pathManager = ... // see above
let frame = CGRect(origin: CGPoint.zero,
                   size: size)
let pathConfiguration = PathConfiguration(lineWidth: 1.0,
                                          strokeColor: UIColor.black)
let view = MRefreshAnimatableView(frame: frame,
                                  pathManager: pathManager,
                                  pathConfiguration: pathConfiguration)
```
So *frame* is obviously the frame in which the view is drawn (actually the origin here doesn't matter because it is calculated under the hood). And the *pathConfiguration* is the info we need to know to draw the UIBezierPath.

#### MRefreshConfiguration

Finally, you need to provide some additional data (*MRefreshConfiguration*) to describe how you want the scroll view to behave.

```swift
let refreshConfiguration = MRefreshConfiguration(heightIncrease: 40.0,
                                                 animationEndDistanceOffset: 30.0,
                                                 animationStartDistance: 30.0,
                                                 contentInsetChangeAnimationDuration: 0.2)
```

- heightIncrease is actually some space at the top and the bottom of the animatable view when it is drawn on screen, i.e the height of the container view (== MRefreshView) = animatableView.frame.height + heightIncrease. 
- *animationStartDistance* is a content offset value when the path drawing should begin.
- *animationEndDistanceOffset* is a content offset value which when added to container view height constitute the threshold when the path drawing should end and the loading should begin.
- *contentInsetChangeAnimationDuration* is basically what the name tells us about, i.e. animation duration of a view changing its inset from starting state to loading state and backwards (to starting state).

#### Adding handler to a scroll view 

```swift
tableView.addPullToRefresh(animatable: view, // MRefreshAnimatableView
                           configuration: refreshConfiguration) { [weak self] in // MRefreshConfiguration
    self?.somePresenter.didAskToRefreshAView()
}
        
...
// when the data was loaded
tableView.stopAnimating()
```

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

## Installation

MRefresh is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MRefresh', '~> 0.1.1'
```
## Author

Mikhail Rakhmanov, rakhmanov.m@gmail.com

## License

MRefresh is available under the MIT license. See the LICENSE file for more info.
