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
    
    func drawPlainChart(
        _ chart: OptimizedChart,
        frame: CGRect,
        lineWidth: CGFloat
    ) {
        guard chart.xAxisValues.count > 1 else {
            return
        }
        
        drawGraps(chart: chart, frame: frame, insets: .zero, lineWidth: lineWidth)
    }
    
    func drawChart(
        _ chart: OptimizedChart,
        frame: CGRect,
        lineWidth: CGFloat
    ) {
        guard chart.xAxisValues.count > 1 else {
            return
        }
        
        drawCoordinates(frame: frame,
                        chart: chart,
                        xAxisFont: chart.xAxisFont, yAxisFont: chart.yAxisFont,
                        axisColor: chart.axisColor,
                        xAxisColor: chart.xAxisTextColor, yAxisColor: chart.yAxisTextColor,
                        xAxisValues: chart.xAxisValues,
                        minY: chart.yAxisRange.min, maxY: chart.yAxisRange.max,
                        insets: chart.insets,
                        spaceBetweenAxes: chart.spaceBetweenAxes)
        
        drawGraps(chart: chart,
                  frame: frame,
                  insets: chart.insetsWithAxes,
                  lineWidth: lineWidth)
    }
    
    func drawCoordinates(
        frame: CGRect,
        chart: OptimizedChart,
        xAxisFont: UIFont,
        yAxisFont: UIFont,
        axisColor: UIColor,
        xAxisColor: UIColor,
        yAxisColor: UIColor,
        xAxisValues: [Date],
        numberSegmentXAxis: Int = 4,
        numberSegmentYAxis: Int = 5,
        minY: CGFloat,
        maxY: CGFloat,
        insets: UIEdgeInsets,
        spaceBetweenAxes: CGFloat
    ) {
        guard chart.x.count > 1 else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        
        let numberSegmentXAxis = min(numberSegmentXAxis, chart.x.count)
        
        let lastValue = chart.x[chart.x.count - 1]
        let lastValueWidth = formatter.string(from: lastValue).boundingRect(font: xAxisFont).width
        
        let resizedWidth = (frame.width - insets.left - insets.right - lastValueWidth) / (chart.upperValue - chart.lowerValue)
        let allNumberSegmentXAxis = Int((CGFloat(numberSegmentXAxis) / (chart.upperValue - chart.lowerValue)).rounded(.down))
        
        let xAxisSegmentIndexWidth = CGFloat(chart.x.count - 1) / CGFloat(allNumberSegmentXAxis)
        
        let xAxisSegmentWidth = resizedWidth / CGFloat(allNumberSegmentXAxis)
        let yAxisSegmentWidth = (frame.height - insets.top - insets.bottom - xAxisFont.lineHeight * 2 - spaceBetweenAxes) / CGFloat(numberSegmentYAxis)
        
        //TODO: replace y
        let y = (maxY - minY) / CGFloat(numberSegmentYAxis)
        
        saveGState()
        
        for i in 0..<(allNumberSegmentXAxis + 1) {
            let index = Int(CGFloat(i) * xAxisSegmentIndexWidth)
            
            drawText(
                text: formatter.string(from: chart.x[index]),
                font: xAxisFont,
                color: xAxisColor,
                frame: frame,
                x: insets.left + xAxisSegmentWidth * CGFloat(i) - resizedWidth * chart.lowerValue,
                y: insets.bottom)
        }
        
        for i in 0..<(numberSegmentYAxis + 1) {
            let linePosition = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisSegmentWidth * CGFloat(i)
            
            drawLine(fromPoint: CGPoint(x: 0, y: linePosition),
                     toPoint: CGPoint(x: frame.width, y: linePosition),
                     color: axisColor.withAlphaComponent(1.0 - CGFloat(i) * 0.1).cgColor,
                     lineWidth: 1.2)
            
            let value = Int(minY + CGFloat(i) * y)
            
            drawText(
                text: "\(value)",
                font: xAxisFont,
                color: yAxisColor,
                frame: frame,
                x: insets.left,
                y: insets.bottom + xAxisFont.lineHeight + yAxisSegmentWidth * CGFloat(i) + spaceBetweenAxes)
        }
        
        restoreGState()
    }
    
    func drawGraps(chart: OptimizedChart,
                   frame: CGRect,
                   insets: UIEdgeInsets,
                   lineWidth: CGFloat
        ) {
        let width = frame.width - insets.left - insets.right
        let height = frame.height - insets.top - insets.bottom
        
        let stepXAxis = width / CGFloat(chart.xAxisValues.count - 1)
        let stretchRangeYAxis = chart.yAxisRange.max - chart.yAxisRange.min
        let yAxisMax = chart.yAxisRange.max
        
        saveGState()
        
        for graph in chart.visibleGraphs {
            setStrokeColor(graph.color.cgColor)
            setLineWidth(lineWidth)
            setLineJoin(.round)
            setLineCap(.round)
            
            let points = (0..<graph.column.count).map{
                getPoint(at: $0,
                         column: graph.column,
                         insets: insets,
                         stepXAxis: stepXAxis,
                         height: height,
                         yAxisMax: yAxisMax,
                         stretchRangeYAxis: stretchRangeYAxis)
            }
            
            addLines(between: points)
            
            drawPath(using: .stroke)
        }
        
        restoreGState()
    }
    
    func drawDefinition(
        chart: OptimizedChart,
        frame: CGRect,
        pointSize: CGSize,
        lineWidth: CGFloat,
        valueFont: UIFont,
        monthDayFont: UIFont,
        yearFont: UIFont,
        rectInsets: UIEdgeInsets,
        insetColumn: CGFloat,
        insetRow: CGFloat
    ) {
        guard chart.xAxisValues.count > 1 else {
            return
        }
        
        let width = frame.width - chart.insetsWithAxes.left - chart.insetsWithAxes.right
        let height = frame.height - chart.insetsWithAxes.top - chart.insetsWithAxes.bottom
        
        let stepXAxis = width / CGFloat(chart.xAxisValues.count - 1)
        let yAxisMax = chart.yAxisRange.max
        let stretchRangeYAxis = chart.yAxisRange.max - chart.yAxisRange.min
        let indexPoint = Int(chart.definitionValuePoint * CGFloat(chart.xAxisValues.count - 1))
        
        let lineFromPoint = CGPoint(x: CGFloat(indexPoint) * stepXAxis, y: chart.insetsWithAxes.top)
        let lineToPoint = CGPoint(x: CGFloat(indexPoint) * stepXAxis, y: frame.height - chart.insetsWithAxes.bottom)
        
        saveGState()
        
        drawLine(fromPoint: lineFromPoint, toPoint: lineToPoint, color: Theme.shared.axisColor.cgColor)
        
        for graph in chart.visibleGraphs {
            setStrokeColor(graph.color.cgColor)
            setFillColor(Theme.shared.mainColor.cgColor)
            setLineWidth(lineWidth)
            
            let point = getPoint(at: indexPoint,
                                 column: graph.column,
                                 insets: chart.insetsWithAxes,
                                 stepXAxis: stepXAxis,
                                 height: height,
                                 yAxisMax: yAxisMax,
                                 stretchRangeYAxis: stretchRangeYAxis)
            let pointRect = CGRect(x: point.x - pointSize.width * 0.5,
                                   y: point.y - pointSize.height * 0.5,
                                   width: pointSize.width,
                                   height: pointSize.height)
            
            addEllipse(in: pointRect)
            drawPath(using: .fillStroke)
        }
        
        drawValuesDefinition(frame: frame,
                             graphs: chart.visibleGraphs.map { ("\(Int($0.column[indexPoint]))", $0.color) },
                             date: chart.xAxisValues[indexPoint],
                             index: indexPoint,
                             lineX: lineFromPoint.x,
                             insets: rectInsets,
                             insetColumn: insetColumn,
                             insetRow: insetRow,
                             yearFont: yearFont,
                             monthDayFont: monthDayFont,
                             valueFont: valueFont)
        
        restoreGState()
    }
    
    func drawValuesDefinition(
        frame: CGRect,
        graphs: [(value: String, color: UIColor)],
        date: Date,
        index: Int,
        lineX: CGFloat,
        insets: UIEdgeInsets,
        insetColumn: CGFloat,
        insetRow: CGFloat,
        yearFont: UIFont,
        monthDayFont: UIFont,
        valueFont: UIFont
    ) {
        let countLine = max(2, graphs.count)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        
        let monthDay = formatter.string(from: date)
        
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        
        let firstColumnWidth = max(year.boundingRect(font: yearFont).width,
                                   monthDay.boundingRect(font: monthDayFont).width)
        let secondColumnWidth = graphs.map { $0.value.boundingRect(font: valueFont).width }.max() ?? 0
        
        let rectWidth = insets.left + firstColumnWidth + insetColumn + secondColumnWidth + insets.right
        let rectHeight = insets.top + CGFloat(countLine) * valueFont.lineHeight + CGFloat(countLine - 1) * insetRow + insets.bottom
        
        let rectPoint = CGPoint(x: max(min(lineX - rectWidth * 0.5, frame.width - rectWidth), 0),
                                y: 0)
        
        let rect = CGRect(origin: rectPoint, size: CGSize(width: rectWidth, height: rectHeight))
        
        let monthDayPoint = CGPoint(x: rectPoint.x + insets.left,
                                    y: frame.height - (rectPoint.y + insets.top + monthDayFont.lineHeight))
        
        saveGState()
        
        setFillColor(Theme.shared.additionalColor.withAlphaComponent(0.9).cgColor)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4.0).cgPath
        addPath(path)
        drawPath(using: .fill)
        
        drawText(text: monthDay,
                 font: monthDayFont,
                 color: Theme.shared.definitionDateTextColor,
                 frame: frame,
                 x: monthDayPoint.x,
                 y: monthDayPoint.y)
        drawText(text: year,
                 font: yearFont,
                 color: Theme.shared.definitionDateTextColor,
                 frame: frame,
                 x: monthDayPoint.x,
                 y: monthDayPoint.y - (insetRow + yearFont.lineHeight))
        
        for i in 0..<graphs.count {
            let graph = graphs[i]
            let valueWidth = graph.value.boundingRect(font: valueFont).width
            let indent = secondColumnWidth - valueWidth
            
            drawText(text: graph.value,
                     font: valueFont,
                     color: graph.color,
                     frame: frame,
                     x: rectPoint.x + insets.left + firstColumnWidth + insetColumn + indent,
                     y: frame.height - (rectPoint.y + insets.top) - valueFont.lineHeight - CGFloat(i) * (valueFont.lineHeight + insetRow))
        }
        
        restoreGState()
    }
    
    func getPoint(at index: Int, column: [CGFloat], insets: UIEdgeInsets, stepXAxis: CGFloat, height: CGFloat, yAxisMax: CGFloat, stretchRangeYAxis: CGFloat) -> CGPoint {
        let x = insets.left + CGFloat(index) * stepXAxis
        let y = insets.top + height * (yAxisMax - column[index]) / stretchRangeYAxis
        return CGPoint(x: x, y: y)
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
            : ceil(font.lineHeight * CGFloat(countLine))
        
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: height),
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font: font],
                                                   context: nil)
    }
}
