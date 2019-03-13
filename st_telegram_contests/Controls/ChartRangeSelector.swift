//
//  RangeControl.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class RangeSliderThumbLayer: CALayer {
    var highlighted = false
    weak var rangeSelector: ChartRangeSelector?
}

class ChartRangeSelector: UIControl {
    var lowerValue: CGFloat = 0.3
    var upperValue: CGFloat = 0.7
    
    var mainColor: UIColor = Theme.shared.mainColor
    var controlColor: UIColor = Theme.shared.controlColor
    
    var chart: Chart?
    
    var previousLocation = CGPoint()
    
    lazy var trackLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = mainColor.cgColor
        return layer
    }()
    
    lazy var leftBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.1
        return layer
    }()
    
    lazy var rightBackgroundLayer: CALayer = {
        var layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor
        layer.opacity = 0.1
        return layer
    }()
    
    lazy var lowerThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return layer
    }()
    
    lazy var upperThumbLayer: RangeSliderThumbLayer = {
        var layer = RangeSliderThumbLayer()
        layer.rangeSelector = self
        layer.cornerRadius = 3.0
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        return layer
    }()
    
    lazy var topBorderLayer: CALayer = {
        var layer = CALayer()
        return layer
    }()
    
    lazy var bottomBorderLayer: CALayer = {
        var layer = CALayer()
        return layer
    }()
    
    var thumbWidth: CGFloat = 15.0
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
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
        
        previousLocation = location
        
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: 0.0, upperValue: upperValue - 0.2)
            print("lower", lowerValue)
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue + 0.2, upperValue: 1.0)
            print("upper", upperValue)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(trackLayer)
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
        updateLayerFrames()
    }
    
    func updateColors() {
        trackLayer.backgroundColor = mainColor.cgColor
        lowerThumbLayer.backgroundColor = controlColor.withAlphaComponent(0.9).cgColor
        upperThumbLayer.backgroundColor = controlColor.withAlphaComponent(0.9).cgColor
        topBorderLayer.backgroundColor = controlColor.withAlphaComponent(0.9).cgColor
        bottomBorderLayer.backgroundColor = controlColor.withAlphaComponent(0.9).cgColor
    }
    
    func updateLayerFrames() {
        updateColors()
        drawMainLayer()
        drawGrapth()
        drawLeftThumb()
        drawRightThumb()
        drawBorder()
        drawBackgroundLayer()
    }
}

extension ChartRangeSelector {
    func drawMainLayer() {
        trackLayer.frame = CGRect(x: 0.0, y: 3.0,
                                  width: bounds.width, height: bounds.height - 6)
    }
    
    func drawBackgroundLayer() {
        leftBackgroundLayer.frame = CGRect(x: trackLayer.frame.origin.x, y: trackLayer.frame.origin.y,
                                           width: lowerThumbLayer.frame.origin.x + 1, height: trackLayer.frame.height)
        rightBackgroundLayer.frame = CGRect(x: upperThumbLayer.frame.origin.x + thumbWidth, y: trackLayer.frame.origin.y,
                                            width: trackLayer.frame.width - upperThumbLayer.frame.origin.x - thumbWidth, height: trackLayer.frame.height)
    }
    
    func drawLeftThumb() {
        let lowerThumbX = bounds.width * lowerValue
        lowerThumbLayer.frame = CGRect(x: lowerThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        lowerThumbLayer.sublayers?.removeAll()
        drawLine(onLayer: lowerThumbLayer,
                 fromPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2 - 7),
                 toPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2))
        drawLine(onLayer: lowerThumbLayer,
                 fromPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2),
                 toPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2 + 7))
    }
    
    func drawRightThumb() {
        let upperThumbX = bounds.width * upperValue - thumbWidth
        upperThumbLayer.frame = CGRect(x: upperThumbX, y: 0.0,
                                       width: thumbWidth, height: bounds.height)
        upperThumbLayer.sublayers?.removeAll()
        drawLine(onLayer: upperThumbLayer,
                 fromPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2 - 7),
                 toPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2))
        drawLine(onLayer: upperThumbLayer,
                 fromPoint: CGPoint(x: thumbWidth / 2 + 3, y: bounds.height / 2),
                 toPoint: CGPoint(x: thumbWidth / 2 - 3, y: bounds.height / 2 + 7))
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
        guard let chart = chart else {
            fatalError("Chart don't exist")
        }
        trackLayer.sublayers?.removeAll()
        drawChart(chart, onLayer: trackLayer, lineWidth: 1.0, insets: UIEdgeInsets(top: 2.0, left: 0, bottom: 2.0, right: 0))
    }
}
