//
//  ChartTableViewCell.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {
    
    var chart: Chart?
    
    var changeSelectorCallback: (_ lowerValue: CGFloat, _ upperValue: CGFloat) -> Void = { _,_ in }
    
    lazy var chartView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var chartSelector: ChartRangeSelector = {
        var selector = ChartRangeSelector()
        selector.translatesAutoresizingMaskIntoConstraints = false
        selector.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        return selector
    }()
    
    private var searchTimer: Timer?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(chartView)
        addSubview(chartSelector)
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            chartView.bottomAnchor.constraint(equalTo: chartSelector.topAnchor, constant: -5)
        ])
        NSLayoutConstraint.activate([
            chartSelector.heightAnchor.constraint(equalToConstant: 50),
            chartSelector.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            chartSelector.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            chartSelector.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        redrawChart()
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: ChartRangeSelector) {
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
        chart?.lowerValue = rangeSlider.lowerValue
        chart?.upperValue = rangeSlider.upperValue
        changeSelectorCallback(rangeSlider.lowerValue, rangeSlider.upperValue)
        searchTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(valueDidChange), userInfo: nil, repeats: false)
    }
    
    @objc func valueDidChange() {
        redrawChart()
    }
    
    func redrawChart() {
        guard let chart = chart else {
            fatalError("Chart don't exist")
        }
        
        guard chartView.frame != .zero else {
            return
        }
        
        chartView.layer.sublayers?.removeAll()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        drawChart(chart, onLayer: chartView.layer, lineWidth: 2.0, insets: UIEdgeInsets(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0), lowerValue: chart.lowerValue, upperValue: chart.upperValue)
        
        CATransaction.commit()
    }
    
    func setChart(_ chart: Chart) {
        self.chart = chart
        self.chartSelector.chart = chart
        self.chartSelector.lowerValue = chart.lowerValue
        self.chartSelector.upperValue = chart.upperValue
        self.redrawChart()
        self.chartSelector.updateLayerFrames()
    }
}
