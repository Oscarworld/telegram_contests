//
//  RangeControl.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class RangeSliderThumbLayer: CALayer {
    static let thumbWidth: CGFloat = 15.0
    
    var highlighted = false
    var isLowerThumb = true
    weak var rangeSelector: ChartRangeSelector?
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        contentsScale = UIScreen.main.scale
        cornerRadius = 3.0
        masksToBounds = true
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

class ChartRangeSelector: UIControl {
    
    var chart: Chart!
    
    var lowerValue: CGFloat!
    var upperValue: CGFloat!
    
    var previousLocation = CGPoint()
    
    var thumbWidth: CGFloat = RangeSliderThumbLayer.thumbWidth
    
    lazy var chartLayer: ChatLayer = {
        var layer = ChatLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.insets = .zero
        layer.lineWidth = 1.0
        layer.percentStretchingYAxis = 0.05
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var leftBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var rightBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var lowerThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.isLowerThumb = true
        layer.contentsScale = UIScreen.main.scale
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var upperThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.isLowerThumb = false
        layer.contentsScale = UIScreen.main.scale
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var topBorderLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var bottomBorderLayer: CALayer = {
        var layer = CALayer()
        layer.contentsScale = UIScreen.main.scale
        layer.drawsAsynchronously = true
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
        alpha = 1.0
        backgroundColor = mainColor
        chartLayer.backgroundColor = mainColor.cgColor
        lowerThumbLayer.backgroundColor = controlColor
        upperThumbLayer.backgroundColor = controlColor
        topBorderLayer.backgroundColor = controlColor
        bottomBorderLayer.backgroundColor = controlColor
        leftBackgroundLayer.backgroundColor = Theme.shared.backgroundTrackColor.cgColor
        rightBackgroundLayer.backgroundColor = Theme.shared.backgroundTrackColor.cgColor
    }
    
    func configure(chart: Chart) {
        self.chart = chart
        self.lowerValue = chart.lowerValue
        self.upperValue = chart.upperValue
        self.chartLayer.chart = chart
    }
}


// MARK: Handler
extension ChartRangeSelector {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        let lowerRect = CGRect(x: lowerThumbLayer.frame.minX - 20, y: lowerThumbLayer.frame.minY,
                               width: lowerThumbLayer.frame.width + 40, height: lowerThumbLayer.frame.height)
        let upperRect = CGRect(x: upperThumbLayer.frame.minX - 20, y: upperThumbLayer.frame.minY,
                               width: upperThumbLayer.frame.width + 40, height: upperThumbLayer.frame.height)
        let midRect = CGRect(x: lowerThumbLayer.frame.maxX, y: lowerThumbLayer.frame.minY,
                             width: upperThumbLayer.frame.minX - lowerThumbLayer.frame.maxX, height: lowerThumbLayer.frame.height)
        
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
        let deltaValue = deltaLocation / (bounds.width - thumbWidth)
        
        let oldLoweValue = lowerValue
        let oldUperValue = upperValue
        
        previousLocation = location
        
        if lowerThumbLayer.highlighted && upperThumbLayer.highlighted {
            if (deltaValue > 0 && upperValue != 1.0) || (deltaValue < 0 && lowerValue != 0.0) {
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

extension ChartRangeSelector {
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
        chartLayer.setNeedsDisplay()
    }
}