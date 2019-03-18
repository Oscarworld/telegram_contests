//
//  ChartTableViewCell.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {
    
    var chart: OptimizedChart!
    var rangeChanged: ((CGFloat, CGFloat) -> Void)!
    var definitionChanged: ((CGFloat) -> Void)!
    
    lazy var chartLayer: ChatLayer = {
        var layer = ChatLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.lineWidth = 2.0
        layer.drawsAsynchronously = true
        return layer
    }()
    
    lazy var chartSelectorControl: ChartRangeControl = {
        var control = ChartRangeControl()
        control.addTarget(self,
                           action: #selector(rangeSliderValueChanged(_:)),
                           for: .valueChanged)
        return control
    }()
    
    lazy var chartDefinitionControl: ChartValuesDefinitionControl = {
        var control = ChartValuesDefinitionControl()
        control.addTarget(self,
                           action: #selector(rangeDefinitionValueChanged(_:)),
                           for: .valueChanged)
        return control
    }()
    
    
    private var searchTimer: Timer?
    private let ratio: CGFloat = 0.15 // Ratio for chartLayer and chartSelector
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layer.addSublayer(chartLayer)
        addSubview(chartSelectorControl)
        addSubview(chartDefinitionControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        chartLayer.frame = CGRect(x: 15.0,
                                  y: 15.0,
                                  width: rect.width - 30,
                                  height: (rect.height - 30) * (1 - ratio))
        chartDefinitionControl.frame = CGRect(x: 15.0,
                                              y: 15.0,
                                              width: rect.width - 30,
                                              height: (rect.height - 30) * (1 - ratio))
        chartSelectorControl.frame = CGRect(x: 15.0,
                                     y: chartLayer.frame.maxY + 10.0,
                                     width: rect.width - 30,
                                     height: (rect.height - 30) * ratio)
        
        chartLayer.setNeedsDisplay()
        chartSelectorControl.setNeedsDisplay()
        chartDefinitionControl.setNeedsDisplay()
    }
    
    func updateTheme() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        backgroundColor = Theme.shared.mainColor
        chartLayer.backgroundColor = Theme.shared.mainColor.cgColor
        chartSelectorControl.updateTheme()
        
        CATransaction.commit()
    }
    
    func configure(chart: OptimizedChart) {
        self.chart = chart
        chartLayer.chart = chart
        chartSelectorControl.configure(chart: chart)
        chartDefinitionControl.configure(chart: chart)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        chartLayer.setNeedsDisplay()
        chartSelectorControl.setNeedsDisplay()
        chartDefinitionControl.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: ChartRangeControl) {
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
        
        rangeChanged(rangeSlider.lowerValue, rangeSlider.upperValue)
        rangeDidChange()
//        searchTimer = Timer.scheduledTimer(timeInterval: 0.01,
//                                           target: self,
//                                           selector: #selector(valueDidChange),
//                                           userInfo: nil,
//                                           repeats: false)
    }
    
    @objc func rangeDefinitionValueChanged(_ control: ChartValuesDefinitionControl) {
        definitionChanged(control.definitionValuePoint)
        definitionDidChange()
    }
    
    @objc func rangeDidChange() {
        chartLayer.chart = chart
        chartDefinitionControl.configure(chart: chart)
        chartLayer.setNeedsDisplay()
        chartDefinitionControl.setNeedsDisplay()
    }
    
    @objc func definitionDidChange() {
        chartLayer.chart = chart
    }
}
