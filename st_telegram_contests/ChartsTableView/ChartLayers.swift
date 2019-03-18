//
//  ChartLayer.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 14/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import QuartzCore
import UIKit

class PlainChatLayer: CALayer {
    
    var chart: OptimizedChart!
    var lineWidth: CGFloat = 1.0
    
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
        ctx.drawPlainChart(chart,
                           frame: frame,
                           lineWidth: lineWidth)
    }
}

class ChatLayer: CALayer {
    
    var chart: OptimizedChart!
    var lineWidth: CGFloat = 2.0
    
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
        ctx.drawChart(chart,
                      frame: frame,
                      lineWidth: lineWidth)
    }
}

class RangeSliderThumbLayer: CALayer {
    static let thumbWidth: CGFloat = 15.0
    
    var highlighted = false
    var isLowerThumb = true
    weak var rangeSelector: ChartRangeControl?
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        contentsScale = UIScreen.main.scale
        cornerRadius = 3.0
        masksToBounds = false
        shouldRasterize = true
        maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let thumbWidth = RangeSliderThumbLayer.thumbWidth
        if isLowerThumb {
            ctx.drawLine(
                fromPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2 - 7),
                toPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2),
                color: UIColor.white.cgColor, lineWidth: 1.0)
            ctx.drawLine(
                fromPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2),
                toPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2 + 7),
                color: UIColor.white.cgColor, lineWidth: 1.0)
        } else {
            ctx.drawLine(
                fromPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2 - 7),
                toPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2),
                color: UIColor.white.cgColor, lineWidth: 1.0)
            ctx.drawLine(
                fromPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2),
                toPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2 + 7),
                color: UIColor.white.cgColor, lineWidth: 1.0)
        }
    }
}

class DefenitionPointLayer: CALayer {
    
    var chart: OptimizedChart!
    var pointSize = CGSize(width: 7, height: 7)
    var lineWidth: CGFloat = 2.0
    
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
        ctx.drawDefinition(chart: chart,
                           frame: frame,
                           pointSize: pointSize,
                           lineWidth: lineWidth)
    }
}
