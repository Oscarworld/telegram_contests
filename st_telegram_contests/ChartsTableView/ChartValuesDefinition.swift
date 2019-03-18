//
//  ChartValuesDefinition.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 17/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit
import QuartzCore

class ChartValuesDefinitionControl: UIControl {
    
    var chart: OptimizedChart!
    
    var definitionValuePoint: CGFloat!
    
    lazy var definitionLayer: DefenitionPointLayer = {
        var layer = DefenitionPointLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    var previousLocation = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("add layers")
        layer.addSublayer(definitionLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        definitionLayer.frame = rect
        definitionLayer.setNeedsDisplay()
    }
    
    func configure(chart: OptimizedChart) {
        self.chart = chart
        self.definitionLayer.chart = chart
    }
}


//// MARK: Handler
//extension ChartValuesDefinitionControl {
//    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        previousLocation = touch.location(in: self)
//
//        return CGRect(x: rectLayer.frame.minX, y: 0, width: rectLayer.frame.width, height: frame.height).contains(previousLocation)
//    }
//
//    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        let location = touch.location(in: self)
//
//        let deltaLocation = CGFloat(location.x - previousLocation.x)
//        let deltaValue = deltaLocation / bounds.width
//
//        previousLocation = location
//
//        definitionValuePoint += deltaValue
//        definitionValuePoint = boundValue(value: definitionValuePoint, toLowerValue: 0.0, upperValue: 1.0)
//
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//
//        setNeedsDisplay()
//
//        CATransaction.commit()
//
//        return true
//    }
//
//    func boundValue(value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
//        return min(max(value, lowerValue), upperValue)
//    }
//}
