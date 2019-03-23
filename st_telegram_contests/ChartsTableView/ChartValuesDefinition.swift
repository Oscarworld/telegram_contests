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
        layer.isHidden = true
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(definitionLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        definitionLayer.frame = rect
        definitionLayer.chart = chart
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        definitionLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func configure(chart: OptimizedChart) {
        self.chart = chart
        self.definitionValuePoint = chart.definitionValuePoint
        self.definitionLayer.chart = chart
        self.definitionLayer.isHidden = true
    }
}


// MARK: Handler
extension ChartValuesDefinitionControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        definitionValuePoint = boundValue(value: touch.location(in: self).x / bounds.width, toLowerValue: 0.0, upperValue: 1.0)
        updateLayer()

        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        definitionLayer.isHidden = true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        definitionValuePoint = boundValue(value: touch.location(in: self).x / bounds.width, toLowerValue: 0.0, upperValue: 1.0)
        
        let lsIndex = chart.lsIndex
        let numberSegment = chart.segments
        
        let indexPoint = max((Int(definitionValuePoint * CGFloat(numberSegment)) + lsIndex) / Int(chart.smoothFactor), lsIndex == 0 ? 0 : 1)
        let oldIndexPoint = max((Int(chart.definitionValuePoint * CGFloat(numberSegment)) + lsIndex) / Int(chart.smoothFactor), lsIndex == 0 ? 0 : 1)
        
        if indexPoint != oldIndexPoint {
            updateLayer()
        }

        return true
    }
    
    func updateLayer() {
        chart.definitionValuePoint = definitionValuePoint
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        setNeedsDisplay()
        definitionLayer.isHidden = false
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
    }

    func boundValue(value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
}
