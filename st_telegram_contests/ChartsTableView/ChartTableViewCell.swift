//
//  ChartTableViewCell.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {
    
    var chart: Chart!
    var callback: ((CGFloat, CGFloat) -> Void)!
    
    lazy var chartLayer: ChatLayer = {
        var layer = ChatLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.insets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0)
        layer.lineWidth = 2.0
        layer.needDrawCoordinates = true
        layer.drawsAsynchronously = true
        return layer
    }()
    var chartSelector = ChartRangeSelector()
    
    private var searchTimer: Timer?
    private let ratio: CGFloat = 0.15 // Ratio for chartLayer and chartSelector
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layer.addSublayer(chartLayer)
        addSubview(chartSelector)
        
        chartSelector.addTarget(self,
                                action: #selector(rangeSliderValueChanged(_:)),
                                for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        chartLayer.frame = CGRect(x: 15.0, y: 15.0,
                                  width: rect.width - 30, height: (rect.height - 30) * (1 - ratio))
        chartSelector.frame = CGRect(x: 15.0, y: chartLayer.frame.maxY + 10.0,
                                     width: rect.width - 30, height: (rect.height - 30) * ratio)
        chartLayer.setNeedsDisplay()
        chartSelector.setNeedsDisplay()
    }
    
    func updateTheme() {
        alpha = 1.0
        backgroundColor = Theme.shared.mainColor
        chartLayer.backgroundColor = Theme.shared.mainColor.cgColor
        chartSelector.updateTheme()
    }
    
    func configure(chart: Chart) {
        self.chart = chart
        chartLayer.chart = chart
        chartSelector.configure(chart: chart)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        chartLayer.setNeedsDisplay()
        chartSelector.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: ChartRangeSelector) {
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
        
        chart.lowerValue = rangeSlider.lowerValue
        chart.upperValue = rangeSlider.upperValue
        
        callback(rangeSlider.lowerValue, rangeSlider.upperValue)
        
        searchTimer = Timer.scheduledTimer(timeInterval: 0.01,
                                           target: self,
                                           selector: #selector(valueDidChange),
                                           userInfo: nil,
                                           repeats: false)
    }
    
    @objc func valueDidChange() {
        chartLayer.chart = chart
        chartLayer.setNeedsDisplay()
    }
}
