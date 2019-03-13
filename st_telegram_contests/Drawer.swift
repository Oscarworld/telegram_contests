//
//  Drawer.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint, color: UIColor = .white, lineWidth: CGFloat = 1.0) {
    let line = CAShapeLayer()
    let linePath = UIBezierPath()
    linePath.move(to: start)
    linePath.addLine(to: end)
    line.path = linePath.cgPath
    line.fillColor = nil
    line.opacity = 1.0
    line.lineWidth = lineWidth
    line.strokeColor = color.cgColor
    layer.addSublayer(line)
}

func drawChart(_ chart: Chart, onLayer: CALayer, lineWidth: CGFloat, insets: UIEdgeInsets = .zero, lowerValue: CGFloat = 0.0, upperValue: CGFloat = 1.0) {
    guard onLayer.frame != .zero else {
        return
    }
    
    let width = onLayer.frame.width - insets.left - insets.right
    let height = onLayer.frame.height - insets.top - insets.bottom
    
    let lowerNum = Int(CGFloat(chart.x.count) * lowerValue)
    let upperNum = Int(CGFloat(chart.x.count) * upperValue)
    let x = Array(chart.x[lowerNum..<upperNum])
    
    let graphs = chart.graphs.filter{ !$0.isHidden }
    let elements = graphs.flatMap{ $0.column[lowerNum..<upperNum] }
    let minY = CGFloat(elements.min() ?? 0)
    let maxY = CGFloat(elements.max() ?? 0)
    
    let stepX = width / CGFloat(x.count - 1)
    let rangeY = maxY - minY
    
    for graph in graphs {
        let layer = CAShapeLayer()
        let path = UIBezierPath()
        let column = Array(graph.column[lowerNum..<upperNum])
        
        path.move(to:
            CGPoint(x: insets.left + 0,
                    y: insets.top + height * (maxY - column[0]) / rangeY)
        )
        
        for i in 1..<column.count {
            let point = CGPoint(x: insets.left +  CGFloat(i) * stepX,
                                y: insets.top + height * (maxY - column[i]) / rangeY)
            path.addLine(to: point)
        }
        
        layer.path = path.cgPath
        layer.fillColor = nil
        layer.opacity = 1.0
        layer.lineWidth = lineWidth
        layer.strokeColor = graph.color.cgColor
        onLayer.addSublayer(layer)
    }
}
