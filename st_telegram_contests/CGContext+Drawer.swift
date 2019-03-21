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
        
        let width = frame.width
        let height = frame.height
        
        let stepXAxis = width / CGFloat(chart.x.count - 1)
        
        let rangeYAxis = chart.yAxisRange.max - chart.yAxisRange.min
        
        saveGState()
        
        for graph in chart.visibleGraphs {
            setStrokeColor(graph.color.cgColor)
            setLineWidth(lineWidth)
            setLineJoin(.round)
            setLineCap(.round)
            
            let points = (0..<graph.column.count).map{
                getPoint(at: $0,
                         column: graph.column,
                         insets: .zero,
                         stepXAxis: stepXAxis,
                         height: height,
                         yAxisMax: chart.yAxisRange.max,
                         stretchRangeYAxis: rangeYAxis)
            }
            
            addLines(between: points)
            
            drawPath(using: .stroke)
        }
        
        restoreGState()
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
                        minY: chart.yAxisFrameRange.min, maxY: chart.yAxisFrameRange.max,
                        insets: chart.insets,
                        spaceBetweenAxes: chart.spaceBetweenAxes)
        
        drawGraphs(chart: chart,
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
        numberSegmentYAxis: Int = 5,
        minY: CGFloat,
        maxY: CGFloat,
        insets: UIEdgeInsets,
        spaceBetweenAxes: CGFloat
        ) {
        guard chart.x.count > 1 else {
            return
        }
        
        let lastValueWidth = chart.xMonthDayWidth.last ?? 0
        
        let resizedWidth = (frame.width - insets.left - insets.right - lastValueWidth) / (chart.upperValue - chart.lowerValue)
        let xAxisSegmentIndexWidth = CGFloat(chart.x.count - 1) / CGFloat(chart.numberSegmentXAxis)
        let xAxisSegmentWidth = resizedWidth / CGFloat(chart.numberSegmentXAxis)
        let yAxisSegmentWidth = (frame.height - insets.top - insets.bottom - xAxisFont.lineHeight * 2 - spaceBetweenAxes) / CGFloat(numberSegmentYAxis)
        
        //TODO: replace y
        let y = (maxY - minY) / CGFloat(numberSegmentYAxis)
        saveGState()
        
        for i in 0..<(chart.numberSegmentXAxis + 1) {
            let alpha = i % 2 == 0 ? 1.0 : chart.xAxisFontAlpha * 6
            let i = CGFloat(i)
            let index = Int(i * xAxisSegmentIndexWidth)
            let width = chart.xMonthDayWidth[index]
            let x = insets.left + xAxisSegmentWidth * i - resizedWidth * chart.lowerValue
            
            if x < -width || x > frame.width - insets.left - insets.right {
                continue
            }
            
            drawText(
                text: chart.xMonthDay[index],
                font: xAxisFont,
                color: xAxisColor.withAlphaComponent(alpha),
                frame: frame,
                x: x,
                y: insets.bottom)
        }
        
        for i in 0..<(numberSegmentYAxis + 1) {
            let i = CGFloat(i)
            let linePosition = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisSegmentWidth * i
            
            drawLine(fromPoint: CGPoint(x: 0, y: linePosition),
                     toPoint: CGPoint(x: frame.width, y: linePosition),
                     color: axisColor.withAlphaComponent(1.0 - i * 0.1).cgColor,
                     lineWidth: 1.2)
            
            let value = Int(minY + i * y)
            
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
    
    func drawGraphs(chart: OptimizedChart,
                    frame: CGRect,
                    insets: UIEdgeInsets,
                    lineWidth: CGFloat
        ) {
        
        let width = frame.width - insets.left - insets.right
        let height = frame.height - insets.top - insets.bottom
        
        let lj = chart.lj
        
        let numberSegment = chart.numberSegment
        
        let stepXAxis = width / CGFloat(numberSegment)
        let rangeYAxis = chart.yAxisFrameRange.max - chart.yAxisFrameRange.min
        let yAxisMax = chart.yAxisFrameRange.max
        
        saveGState()
        
        for graph in chart.visibleFrameGraphs {
            setStrokeColor(graph.color.cgColor)
            setLineWidth(lineWidth)
            setLineJoin(.round)
            setLineCap(.round)
            
            let point = getPointSmooth(at: 0,
                                       j: lj,
                                       smoothingFactor: chart.smoothingFactor,
                                       column: graph.column,
                                       insets: insets,
                                       stepXAxis: stepXAxis,
                                       height: height,
                                       yAxisMax: yAxisMax,
                                       rangeYAxis: rangeYAxis)
            
            move(to: point)
            
            for i in 1..<Int(numberSegment + 1) {
                let point = getPointSmooth(at: i,
                                           j: lj + i,
                                           smoothingFactor: chart.smoothingFactor,
                                           column: graph.column,
                                           insets: insets,
                                           stepXAxis: stepXAxis,
                                           height: height,
                                           yAxisMax: yAxisMax,
                                           rangeYAxis: rangeYAxis)
                addLine(to: point)
            }
            
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
        
        let lj = chart.lj
        let numberSegment = chart.numberSegment
        
        let indexPoint = max((Int(chart.definitionValuePoint * CGFloat(numberSegment)) + lj) / Int(chart.smoothingFactor), lj == 0 ? 0 : 1)
        
        let stepXAxis = width / CGFloat(numberSegment)
        let i = Int(CGFloat(indexPoint) * chart.smoothingFactor - CGFloat(lj))
        let x = chart.insetsWithAxes.left + CGFloat(i) * stepXAxis
        
        let rangeYAxis = chart.yAxisFrameRange.max - chart.yAxisFrameRange.min
        let yAxisMax = chart.yAxisFrameRange.max
        
        let lineFromPoint = CGPoint(x: x, y: chart.insetsWithAxes.top)
        let lineToPoint = CGPoint(x: x, y: frame.height - chart.insetsWithAxes.bottom)
        
        saveGState()
        
        drawLine(fromPoint: lineFromPoint,
                 toPoint: lineToPoint,
                 color: Theme.shared.axisColor.cgColor)
        
        for graph in chart.visibleFrameGraphs {
            setStrokeColor(graph.color.cgColor)
            setFillColor(Theme.shared.mainColor.cgColor)
            setLineWidth(lineWidth)
            
            let point = getPointSmooth(at: i,
                                       j: lj + i,
                                       smoothingFactor: chart.smoothingFactor,
                                       column: graph.column,
                                       insets: chart.insetsWithAxes,
                                       stepXAxis: stepXAxis,
                                       height: height,
                                       yAxisMax: yAxisMax,
                                       rangeYAxis: rangeYAxis)
            let pointRect = CGRect(x: point.x - pointSize.width * 0.5,
                                   y: point.y - pointSize.height * 0.5,
                                   width: pointSize.width,
                                   height: pointSize.height)
            
            addEllipse(in: pointRect)
            drawPath(using: .fillStroke)
        }
        
        let maxValue = chart.visibleFrameGraphs.max { $0.column[indexPoint] > $1.column[indexPoint] }?.column[indexPoint]
        
        drawValuesDefinition(frame: frame,
                             graphs: chart.visibleFrameGraphs.map { ("\(Int($0.column[indexPoint]))", $0.color) },
                             maxValue: maxValue,
                             dateYear: chart.xAxisYear[indexPoint],
                             dateMonthDay: chart.xAxisMonthDay[indexPoint],
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
        maxValue: CGFloat?,
        dateYear: String,
        dateMonthDay: String,
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
        
        let firstColumnWidth = dateMonthDay.boundingRect(font: monthDayFont).width
        var secondColumnWidth: CGFloat = 0
        if let value = maxValue {
            secondColumnWidth = "\(value)".boundingRect(font: valueFont).width
        }
        
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
        
        drawText(text: dateMonthDay,
                 font: monthDayFont,
                 color: Theme.shared.definitionDateTextColor,
                 frame: frame,
                 x: monthDayPoint.x,
                 y: monthDayPoint.y)
        drawText(text: dateYear,
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
    
    func getPointSmooth(at index: Int, j: Int, smoothingFactor: CGFloat, column: [CGFloat], insets: UIEdgeInsets, stepXAxis: CGFloat, height: CGFloat, yAxisMax: CGFloat, rangeYAxis: CGFloat) -> CGPoint {
        let x = insets.left + CGFloat(index) * stepXAxis
        let newIndex = j / Int(smoothingFactor)
        let j = CGFloat(j % Int(smoothingFactor))
        let dif = newIndex + 1 == column.count ? 0 : (column[newIndex + 1] - column[newIndex]) / smoothingFactor
        let y = insets.top + height * (yAxisMax - column[newIndex] - dif * j) / rangeYAxis
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
                      font: UIFont) -> CGRect {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: height),
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [.font: font],
                                                   context: nil)
    }
}
