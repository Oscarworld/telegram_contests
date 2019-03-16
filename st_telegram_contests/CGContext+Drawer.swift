//
//  Drawer.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import QuartzCore
import UIKit

extension CGContext {
    
    func drawChart(
        _ chart: Chart,
        frame: CGRect,
        lineWidth: CGFloat,
        insets: UIEdgeInsets = .zero,
        lowerValue: CGFloat = 0.0,
        upperValue: CGFloat = 1.0,
        needDrawCoordinates: Bool = false,
        spaceBetweenAxes: CGFloat = 12.0,
        axisFont: UIFont = .systemFont(ofSize: 12.0),
        axisColor: UIColor = Theme.shared.axisColor,
        axisTextColor: UIColor = Theme.shared.axisTextColor,
        percentStretchingYAxis: CGFloat
    ) {
        let lowerXAxis = Int(CGFloat(chart.x.count) * lowerValue)
        let upperXAxis = Int(CGFloat(chart.x.count) * upperValue)
        
        guard lowerXAxis < upperXAxis else {
            return
        }
        
        let visibleGraphs = chart.graphs.filter { !$0.isHidden }
        
        let yAxisValues = visibleGraphs.flatMap{ $0.column[lowerXAxis..<upperXAxis] }
        let xAxisValues = Array(chart.x[lowerXAxis..<upperXAxis])
        
        guard !xAxisValues.isEmpty else {
            return
        }
        
        guard var minYAxisValue = yAxisValues.min(), var maxYAxisValue = yAxisValues.max() else {
            return
        }
        
        let rangeYAxis = maxYAxisValue - minYAxisValue
        if minYAxisValue >= 0 {
            minYAxisValue = max(minYAxisValue - rangeYAxis * percentStretchingYAxis, 0)
        } else {
            minYAxisValue -= minYAxisValue - rangeYAxis * percentStretchingYAxis
        }
        
        maxYAxisValue += rangeYAxis * percentStretchingYAxis
        
        var newInsets = insets
        
        if needDrawCoordinates {
            drawCoordinates(frame: frame,
                            xAxisFont: axisFont, yAxisFont: axisFont,
                            axisColor: axisColor,
                            xAxisColor: axisTextColor, yAxisColor: axisTextColor,
                            xAxisValues: xAxisValues,
                            minY: minYAxisValue, maxY: maxYAxisValue,
                            insets: insets,
                            spaceBetweenAxes: spaceBetweenAxes)
            
            newInsets = UIEdgeInsets(top: insets.top + axisFont.lineHeight,
                                     left: insets.left,
                                     bottom: insets.bottom + axisFont.lineHeight + spaceBetweenAxes,
                                     right: insets.right)
        }
        
        let width = frame.width - newInsets.left - newInsets.right
        let height = frame.height - newInsets.top - newInsets.bottom
        
        let stepXAxis = width / CGFloat(xAxisValues.count - 1)
        let stretchRangeYAxis = maxYAxisValue - minYAxisValue
        
        let point = { (column: [CGFloat], i: Int) -> CGPoint in
            let x = newInsets.left + CGFloat(i) * stepXAxis
            let y = newInsets.top + height * (maxYAxisValue - column[i]) / stretchRangeYAxis
            return CGPoint(x: x, y: y)
        }
        
        saveGState()
        
        for graph in visibleGraphs {
            let column = Array(graph.column[lowerXAxis..<upperXAxis])
            
            setStrokeColor(graph.color.cgColor)
            setLineWidth(lineWidth)
            
            move(to: point(column, 0))
            
            for i in 1..<column.count {
                addLine(to: point(column, i))
            }
            
            drawPath(using: .stroke)
        }
        
        restoreGState()
    }
    
    func drawCoordinates(
        frame: CGRect,
        xAxisFont: UIFont,
        yAxisFont: UIFont,
        axisColor: UIColor,
        xAxisColor: UIColor,
        yAxisColor: UIColor,
        xAxisValues: [Date],
        minY: CGFloat,
        maxY: CGFloat,
        countStep: CGFloat = 6.0,
        insets: UIEdgeInsets,
        spaceBetweenAxes: CGFloat
    ) {
        guard let lowerXAxisValue = xAxisValues.first, let upperXAxisValue = xAxisValues.last else {
            return
        }
        
        saveGState()
        
        let xAxisStep = (frame.width - insets.left - insets.right) / countStep
        let yAxisStep = (frame.height - insets.top - insets.bottom - xAxisFont.lineHeight * 2 - spaceBetweenAxes) / (countStep - 1)
        
        //TODO: replace x and y
        let x = (lowerXAxisValue.timeIntervalSince1970 - upperXAxisValue.timeIntervalSince1970) / Double(countStep)
        let y = (maxY - minY) / countStep
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        
        let xAxisOffset = (xAxisStep - "May 31".boundingRect(font: xAxisFont).width) * 0.5
        
        for i in 0..<Int(countStep) {
            let _x = Date(timeIntervalSince1970: lowerXAxisValue.timeIntervalSince1970 + Double(i) * x)
            let _y = Int(minY + CGFloat(i) * y)
            
            let lineY = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisStep * CGFloat(i)
            
            drawLine(fromPoint: CGPoint(x: 0, y: lineY),
                     toPoint: CGPoint(x: frame.width, y: lineY),
                     color: axisColor.withAlphaComponent(1.0 - CGFloat(i) * 0.1).cgColor,
                     lineWidth: 1.2)
            
            drawText(
                text: "\(formatter.string(from: _x))",
                font: xAxisFont,
                color: xAxisColor,
                frame: frame,
                x: insets.left + xAxisStep * CGFloat(i) + xAxisOffset,
                y: insets.bottom)
            
            drawText(
                text: "\(_y)",
                font: xAxisFont,
                color: yAxisColor,
                frame: frame,
                x: insets.left,
                y: insets.bottom + xAxisFont.lineHeight + yAxisStep * CGFloat(i) + spaceBetweenAxes)
        }
        
        restoreGState()
    }
    
    func drawLine(
        fromPoint start: CGPoint,
        toPoint end: CGPoint,
        color: CGColor,
        lineWidth: CGFloat = 1.0
    ) {
        saveGState()
        
        setStrokeColor(color)
        setLineWidth(lineWidth)
        move(to: start)
        addLine(to: end)
        drawPath(using: .stroke)
        
        restoreGState()
    }
    
    func drawText(
        text: String,
        font: UIFont,
        color: UIColor,
        frame: CGRect,
        x: CGFloat,
        y: CGFloat
    ) {
        saveGState()
        
        textMatrix = .identity
        translateBy(x: 0, y: frame.height)
        scaleBy(x: 1.0, y: -1.0)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedString)
        
        let attributedStringRect = text.boundingRect(font: font)
        let width = attributedStringRect.width
        let height = attributedStringRect.height
        
        let path = CGMutablePath()
        let rect = CGRect(x: x, y: y - height + font.lineHeight, width: width, height: height)
        path.addRect(rect)
        
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedString.length), path, nil)
        
        CTFrameDraw(ctFrame, self)
        
        restoreGState()
    }
}

extension String {
    func boundingRect(width: CGFloat = .greatestFiniteMagnitude,
                      height: CGFloat = .greatestFiniteMagnitude,
                      options: NSStringDrawingOptions = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),
                      font: UIFont,
                      countLine: Int = 0) -> CGRect {
        let height: CGFloat = countLine == 0
            ? height
            : (font.lineHeight * CGFloat(countLine)).rounded(.up)
        
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: height),
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font: font],
                                                   context: nil)
    }
}