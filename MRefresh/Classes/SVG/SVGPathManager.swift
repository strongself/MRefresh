//
//  SVGPathManager.swift
//  MRefreshSVG
//
//  Created by m.rakhmanov on 01.01.17.
//  Copyright © 2017 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

public typealias ConfigurationTime = (time: CGFloat, configuration: SVGPathConfiguration)
typealias ContainerTime = (time: CGFloat, container: SVGPathContainer)

enum SVGPathManagerError: Error {
    case cannotInstantiatePathManager
}

public class SVGPathManager {
    
    fileprivate var containerTimes: [ContainerTime] = []
    
    public init(configurationTimes: [ConfigurationTime], shouldScaleAsFirstElement: Bool = false) throws {
        guard configurationTimes.count > 0 else {
            throw SVGPathManagerError.cannotInstantiatePathManager
        }
        
        if shouldScaleAsFirstElement && configurationTimes.count > 1 {
            let firstContainer = try SVGPathContainer(svg: configurationTimes[0].configuration.path,
                                                      smooth: configurationTimes[0].configuration.timesSmooth,
                                                      drawableFrame: configurationTimes[0].configuration.drawableFrame)
            var containers: [ContainerTime] = [(time: configurationTimes[0].time, container: firstContainer)]
            
            let otherContainers: [ContainerTime] =
                try configurationTimes
                    .dropFirst()
                    .map {
                        (time: $0.time,
                         container: try SVGPathContainer(svg: $0.configuration.path,
                                                         smooth: $0.configuration.timesSmooth,
                                                         drawableFrame: $0.configuration.drawableFrame,
                                                         offset: firstContainer.offset,
                                                         scale: firstContainer.scale))
                    }
            containers += otherContainers
            
            containerTimes = containers
        } else {
            containerTimes = try configurationTimes.map {
                (timeframe: $0.time,
                 container: try SVGPathContainer(svg: $0.configuration.path,
                                                 smooth: $0.configuration.timesSmooth,
                                                 drawableFrame: $0.configuration.drawableFrame))
            }
        }
    }
    
    func toPath(proportion: CGFloat? = nil) throws -> UIBezierPath {
        let currentTime = proportion ?? 1.0
        let currentPaths = containerTimes.filter { $0.time < currentTime }
        
        guard currentPaths.count > 0 else {
            return UIBezierPath()
        }
        
        let paths: [UIBezierPath] = try currentPaths.map { path in
            let time = calculateRelativeTime(currentTime: currentTime, startTime: path.time)
            return try path.container.toPath(proportion: time)
        }
        
        let totalPath = UIBezierPath()
        paths.forEach { totalPath.append($0) }
        
        return totalPath
    }
    
    private func calculateRelativeTime(currentTime: CGFloat, startTime: CGFloat) -> CGFloat {
        return max((currentTime - startTime) / (1.0 - startTime), 0)
    }
}
