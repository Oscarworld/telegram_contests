//
//  RangeControl.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartRangeControl: UIControl {
    
    var chart: OptimizedChart!
    
    var lowerValue: CGFloat!
    var upperValue: CGFloat!
    
    var previousLocation = CGPoint()
    
    var thumbWidth: CGFloat = RangeSliderThumbLayer.thumbWidth
    
    lazy var chartLayer: PlainChatLayer = {
        var layer = PlainChatLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.lineWidth = 1.0
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var leftBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = layer.contentsScale
        layer.shouldRasterize = true
        return layer
    }()
    
    lazy var rightBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = layer.contentsScale
        layer.shouldRasterize = true
        return layer
    }()
    
    lazy var lowerThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.isLowerThumb = true
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var upperThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.isLowerThumb = false
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var topBorderLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = layer.contentsScale
        layer.shouldRasterize = true
        return layer
    }()
    
    lazy var bottomBorderLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = layer.contentsScale
        layer.shouldRasterize = true
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(chartLayer)
        layer.addSublayer(leftBackgroundLayer)
        layer.addSublayer(rightBackgroundLayer)
        layer.addSublayer(lowerThumbLayer)
        layer.addSublayer(upperThumbLayer)
        layer.addSublayer(topBorderLayer)
        layer.addSublayer(bottomBorderLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        drawMainLayer()
        drawGrapth()
        drawLeftThumb()
        drawRightThumb()
        drawBorder()
        drawBackgroundLayer()
        
        CATransaction.commit()
    }
    
    func updateTheme() {
        let mainColor = Theme.shared.mainColor
        let controlColor = Theme.shared.controlColor.cgColor
        backgroundColor = mainColor
        
        chartLayer.backgroundColor = mainColor.cgColor
        topBorderLayer.backgroundColor = controlColor
        bottomBorderLayer.backgroundColor = controlColor
        leftBackgroundLayer.backgroundColor = Theme.shared.backgroundTrackColor.cgColor
        rightBackgroundLayer.backgroundColor = Theme.shared.backgroundTrackColor.cgColor
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lowerThumbLayer.layerColor = controlColor
        upperThumbLayer.layerColor = controlColor
        lowerThumbLayer.setNeedsDisplay()
        upperThumbLayer.setNeedsDisplay()
        CATransaction.commit()
    }
    
    func configure(chart: OptimizedChart) {
        self.chart = chart
        self.lowerValue = chart.lowerValue
        self.upperValue = chart.upperValue
        self.chartLayer.chart = chart
    }
}


// MARK: Handler
extension ChartRangeControl {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        let lowerRect = CGRect(x: lowerThumbLayer.frame.minX - 20, y: lowerThumbLayer.frame.minY,
                               width: lowerThumbLayer.frame.width + 30, height: lowerThumbLayer.frame.height)
        let upperRect = CGRect(x: upperThumbLayer.frame.minX - 10, y: upperThumbLayer.frame.minY,
                               width: upperThumbLayer.frame.width + 30, height: upperThumbLayer.frame.height)
        let midRect = CGRect(x: lowerThumbLayer.frame.maxX + 10, y: lowerThumbLayer.frame.minY,
                             width: upperThumbLayer.frame.minX - 10.0 - lowerThumbLayer.frame.maxX - 10.0, height: lowerThumbLayer.frame.height)
        
        if lowerRect.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperRect.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        } else if midRect.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = CGFloat(location.x - previousLocation.x)
        var deltaValue = deltaLocation / (bounds.width - thumbWidth)
        
        let oldLoweValue = lowerValue
        let oldUperValue = upperValue
        
        previousLocation = location
        
        if lowerThumbLayer.highlighted && upperThumbLayer.highlighted {
            if (deltaValue > 0 && upperValue != 1.0) || (deltaValue < 0 && lowerValue != 0.0) {
                if lowerValue + deltaValue < 0 {
                    deltaValue = -lowerValue
                }
                if upperValue + deltaValue > 1 {
                    deltaValue = 1.0 - upperValue
                }
                lowerValue += deltaValue
                upperValue += deltaValue
                lowerValue = boundValue(value: lowerValue, toLowerValue: 0.0, upperValue: upperValue - 0.2)
                upperValue = boundValue(value: upperValue, toLowerValue: lowerValue + 0.2, upperValue: 1.0)
            }
        } else if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: 0.0, upperValue: upperValue - 0.2)
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue + 0.2, upperValue: 1.0)
        }
        
        if oldLoweValue == lowerValue && oldUperValue == upperValue {
            return true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let lowerThumbX = bounds.width * lowerValue
        let upperThumbX = bounds.width * upperValue - thumbWidth
        lowerThumbLayer.frame = CGRect(x: lowerThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        upperThumbLayer.frame = CGRect(x: upperThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        drawBorder()
        drawBackgroundLayer()
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    func boundValue(value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
}

extension ChartRangeControl {
    func drawMainLayer() {
        chartLayer.frame = CGRect(x: 0.0, y: 3.0,
                                  width: bounds.width, height: bounds.height - 6)
    }
    
    func drawBackgroundLayer() {
        leftBackgroundLayer.frame = CGRect(x: chartLayer.frame.origin.x, y: chartLayer.frame.origin.y,
                                           width: lowerThumbLayer.frame.origin.x + 1, height: chartLayer.frame.height)
        rightBackgroundLayer.frame = CGRect(x: upperThumbLayer.frame.origin.x + thumbWidth, y: chartLayer.frame.origin.y,
                                            width: chartLayer.frame.width - upperThumbLayer.frame.origin.x - thumbWidth, height: chartLayer.frame.height)
    }
    
    func drawLeftThumb() {
        let lowerThumbX = bounds.width * lowerValue
        lowerThumbLayer.frame = CGRect(x: lowerThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        lowerThumbLayer.setNeedsDisplay()
    }
    
    func drawRightThumb() {
        let upperThumbX = bounds.width * upperValue - thumbWidth
        upperThumbLayer.frame = CGRect(x: upperThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        upperThumbLayer.setNeedsDisplay()
    }
    
    func drawBorder() {
        let lowerThumbX = bounds.width * lowerValue
        let upperThumbX = bounds.width * upperValue - thumbWidth
        
        topBorderLayer.frame = CGRect(x: lowerThumbX + thumbWidth, y: 0.0,
                                      width: upperThumbX - lowerThumbX - thumbWidth , height: 2.0)
        bottomBorderLayer.frame = CGRect(x: lowerThumbX + thumbWidth, y: bounds.height - 2.0,
                                         width: upperThumbX - lowerThumbX - thumbWidth, height: 2.0)
    }
    
    func drawGrapth() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        chartLayer.setNeedsDisplay()
        CATransaction.commit()
    }
}

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
