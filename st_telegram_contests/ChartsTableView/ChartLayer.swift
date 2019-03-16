//
//  ChartLayer.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 14/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import QuartzCore
import UIKit

class ChatLayer: CALayer {
    
    var chart: Chart!
    var lineWidth: CGFloat = 2.0
    var insets: UIEdgeInsets = .zero
    var needDrawCoordinates: Bool = false
    var percentStretchingYAxis: CGFloat = 0.15
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let time1 = CACurrentMediaTime()
        ctx.drawChart(chart,
                      frame: frame,
                      lineWidth: lineWidth,
                      insets: insets,
                      lowerValue: chart.lowerValue,
                      upperValue: chart.upperValue,
                      needDrawCoordinates: needDrawCoordinates,
                      percentStretchingYAxis: percentStretchingYAxis)
         let time2 = CACurrentMediaTime()
    }
}
