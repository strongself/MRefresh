//
//  ViewController.swift
//  MRefresh
//
//  Created by Mikhail Rakhmanov on 01/28/2017.
//  Copyright (c) 2017 Mikhail Rakhmanov. All rights reserved.
//

import UIKit
import MRefresh

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        let size = CGSize(width: 40.0, height: 40.0)
        let pathManager = defaultPathManager(size: size)
        let pathConfiguration = PathConfiguration(lineWidth: 2.0,
                                                  strokeColor: UIColor.black)
        let view = MRefreshAnimatableView(frame: CGRect(origin: CGPoint.zero,
                                                        size: size),
                                          pathManager: pathManager,
                                          pathConfiguration: pathConfiguration)
        
        let refreshConfiguration = MRefreshConfiguration(heightIncrease: 40.0,
                                                         animationEndDistanceOffset: 20.0,
                                                         animationStartDistance: 20.0,
                                                         contentInsetChangeAnimationDuration: 0.3)
        
        tableView.addPullToRefresh(animatable: view,
                                   configuration: refreshConfiguration) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                self.tableView.stopAnimating()
            })
        }
    }
    
    func defaultPathManager(size: CGSize) -> SVGPathManager {
        let svg1 = "M512 256q0 53 -37.5 90.5t-90.5 37.5t-90.5 -37.5t-37.5 -90.5t37.5 -90.5t90.5 -37.5t90.5 37.5t37.5 90.5zM863 162q-13 232 -177 396t-396 177q-14 1 -24 -9t-10 -23v-128q0 -13 8.5 -22t21.5 -10q154 -11 264 -121t121 -264q1 -13 10 -21.5t22 -8.5h128q13 0 23 10 t9 24zz"
        let svg2 = "M1247 161q-5 154 -56 297.5t-139.5 260t-205 205t-260 139.5t-297.5 56q-14 1 -23 -9q-10 -10 -10 -23v-128q0 -13 9 -22t22 -10q204 -7 378 -111.5t278.5 -278.5t111.5 -378q1 -13 10 -22t22 -9h128q13 0 23 10q11 9 9 23"
        let svg3 = "M1536 1120v-960q0 -119 -84.5 -203.5 t-203.5 -84.5h-960q-119 0 -203.5 84.5t-84.5 203.5v960q0 119 84.5 203.5t203.5 84.5h960q119 0 203.5 -84.5t84.5 -203.5z"
        
        let firstConfiguration: ConfigurationTime = (time: 0.0,
                                                     configuration: SVGPathConfiguration(path: svg1,
                                                                                         timesSmooth: 3,
                                                                                         drawableFrame: CGRect(origin: CGPoint.zero, size: size)))
        let secondConfiguration: ConfigurationTime = (time: 0.3,
                                                      configuration: SVGPathConfiguration(path: svg2,
                                                                                          timesSmooth: 3,
                                                                                          drawableFrame: CGRect(origin: CGPoint.zero, size: size)))
        let thirdConfiguration: ConfigurationTime = (time: 0.4,
                                                     configuration: SVGPathConfiguration(path: svg3,
                                                                                         timesSmooth: 3,
                                                                                         drawableFrame: CGRect(origin: CGPoint.zero, size: size)))
        
        let pathManager = try! SVGPathManager(configurationTimes: [thirdConfiguration, secondConfiguration, firstConfiguration],
                                              shouldScaleAsFirstElement: true)
        
        return pathManager
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TestCell")!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
