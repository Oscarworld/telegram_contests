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
    var changeYAxis: ((CGFloat, CGFloat) -> Void)!
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
    
    private var rangeTimer: Timer?
    private var loopTimer: Timer?
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
        
        self.chartLayer.setNeedsDisplay()
        self.chartSelectorControl.setNeedsDisplay()
        self.chartDefinitionControl.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: ChartRangeControl) {
        if !(rangeTimer?.isValid ?? false) {
            rangeTimer = Timer.scheduledTimer(timeInterval: 0.3,
                                              target: self,
                                              selector: #selector(updateYAxis),
                                              userInfo: nil,
                                              repeats: false)
        }
        
        rangeChanged(rangeSlider.lowerValue, rangeSlider.upperValue)
        rangeDidChange()
    }
    
    @objc func rangeDefinitionValueChanged(_ control: ChartValuesDefinitionControl) {
        definitionChanged(control.definitionValuePoint)
        definitionDidChange()
    }
    
    @objc func rangeDidChange() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        chartLayer.chart = chart
        chartDefinitionControl.configure(chart: chart)
        chartLayer.setNeedsDisplay()
        chartDefinitionControl.setNeedsDisplay()
        CATransaction.commit()
    }
    
    @objc func updateYAxis() {
        var counter = 0
        let allCounter = 10
        let oldMinMax = chart.yAxisFrameRange
        
        let i = 0
        let upLowerXAxis = max(Int(chart.lowerXAxis.rounded(.up)) - i, 0)
        let downLowerXAxis = max(Int(chart.lowerXAxis) - i, 0)
        
        let upUpperXAxis = min(Int(chart.upperXAxis.rounded(.up)) + i, chart.x.count - 1)
        let downUpperXAxis = min(Int(chart.upperXAxis) + i, chart.x.count - 1)
        
        let visibleFrameGraphs: [Graph] = chart.visibleGraphs.map {
            var smoothGraph = $0
            
            smoothGraph.column = Array($0.column[Int(upLowerXAxis)..<Int(downUpperXAxis)])
            
            var dif = ($0.column[upLowerXAxis] - $0.column[downLowerXAxis]) / chart.smoothingFactor
            var j = CGFloat(Int(max(0, chart.lowerXAxis - CGFloat(i)) * chart.smoothingFactor) % Int(chart.smoothingFactor))
            smoothGraph.column.append($0.column[downLowerXAxis] + dif * CGFloat(j))
            
            dif = ($0.column[upUpperXAxis] - $0.column[downUpperXAxis]) / chart.smoothingFactor
            j = CGFloat(Int(min(CGFloat(chart.x.count - 1), chart.upperXAxis + CGFloat(i)) * chart.smoothingFactor) % Int(chart.smoothingFactor))
            smoothGraph.column.append($0.column[downUpperXAxis] + dif * CGFloat(j))
            
            return smoothGraph
        }
        
        let minMaxYAxisFrameValue = visibleFrameGraphs.flatMap { $0.column }.minMax() ?? (0, 0)
        
        let newMinMax = chart.getYAxisRange(minValue: minMaxYAxisFrameValue.min, maxValue: minMaxYAxisFrameValue.max, stretching: chart.stretchingYAxis)
        
        let minStep = (newMinMax.min - oldMinMax.min) / CGFloat(allCounter)
        let maxStep = (newMinMax.max - oldMinMax.max) / CGFloat(allCounter)
        
        if minStep == 0 && maxStep == 0 {
            counter = allCounter
        }
        
        loopTimer?.invalidate()
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] timer in
            guard let aSelf = self else {
                timer.invalidate()
                return
            }
            
            counter += 1
            if counter >= allCounter {
                aSelf.changeYAxis(newMinMax.min, newMinMax.max)
                timer.invalidate()
            }
            
            let _min = oldMinMax.min + minStep * CGFloat(counter)
            let _max = oldMinMax.max + maxStep * CGFloat(counter)
            
            aSelf.changeYAxis(_min, _max)
            
            aSelf.rangeDidChange()
        }
    }
    
    @objc func definitionDidChange() {
        chartLayer.chart = chart
    }
}
