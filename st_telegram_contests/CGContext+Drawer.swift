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
            
            let points = (0..<graph.column.count).map {
                getPoint(at: $0,
                         column: graph.column,
                         insets: .zero,
                         stepXAxis: stepXAxis,
                         height: height,
                         yAxisMax: chart.yAxisRange.max,
                         rangeYAxis: rangeYAxis)
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
                        axisColor: Theme.shared.axisLineColor,
                        xAxisColor: Theme.shared.axisTextColor, yAxisColor: Theme.shared.axisTextColor,
                        xAxisValues: chart.xAxisValues,
                        minY: chart.yAxisFrameRange.min, maxY: chart.yAxisFrameRange.max,
                        insets: chart.insets,
                        spaceBetweenAxes: chart.spaceBetweenAxes)
        
        drawGraphs(chart: chart,
                   frame: frame,
                   insets: chart.graphInsets,
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
        minY: CGFloat,
        maxY: CGFloat,
        insets: UIEdgeInsets,
        spaceBetweenAxes: CGFloat
        ) {
        guard chart.x.count > 1, minY != maxY else {
            return
        }
        
        let width = (frame.width - insets.left - insets.right) / (chart.upperValue - chart.lowerValue)
        let height = frame.height - insets.top - insets.bottom - xAxisFont.lineHeight * 2 - spaceBetweenAxes

        let xAxisDif = CGFloat(chart.x.count - 1) / CGFloat(chart.segmentsXAxis)
        let xAxisWidth = width / CGFloat(chart.segmentsXAxis)
        let yAxisWidth = height / CGFloat(chart.segmentsYAxis)
        
        saveGState()
        
        // MARK: Draw Y Axis
        
        let oldMin = chart.oldYRange.min
        let oldMax = chart.oldYRange.max
        let newMin = chart.newYRange.min
        let newMax = chart.newYRange.max
        
        let difMax = newMax - oldMax
        let difMin = newMin - oldMin
        
        let y = (maxY - minY) / CGFloat(chart.segmentsYAxis)
        let oldY = (oldMax - oldMin) / CGFloat(chart.segmentsYAxis)
        let newY = (newMax - newMin) / CGFloat(chart.segmentsYAxis)
        
        var stepX: CGFloat = 0
            
        if difMax != 0 {
            stepX = abs((maxY - chart.oldYRange.max) / difMax)
        } else if difMin != 0 {
            stepX = abs((minY - chart.oldYRange.min) / difMin)
        } else {
            stepX = 0
        }
        
        for i in 0..<(chart.segmentsYAxis + 1) {
            let i = CGFloat(i)
            
            let lineColor = i == 0 ? Theme.shared.axisColor : Theme.shared.axisLineColor
            
            if stepX != 0, difMax != 0 || difMin != 0 {
                // Line drawing under compression
                let k1 = yAxisWidth * i  - (yAxisWidth * i - ((newMin - oldMin) / (oldMax - oldMin)) * height) * ((oldMax - oldMin) / (newMax - newMin))
                var linePosition = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisWidth * i + k1 * stepX
                if frame.minY...frame.maxY ~= linePosition {
                    drawLine(fromPoint: CGPoint(x: 0, y: linePosition),
                             toPoint: CGPoint(x: frame.width, y: linePosition),
                             color: lineColor.withAlphaComponent(1.0 - stepX).cgColor,
                             lineWidth: 1.2)
                    drawText(
                        text: "\(Int(oldMin + i * oldY))",
                        font: xAxisFont,
                        color: yAxisColor.withAlphaComponent(1.0 - stepX),
                        frame: frame,
                        x: insets.left,
                        y: frame.height - linePosition)
                }
                
                // Drawing lines when stretching
                let k2 = yAxisWidth * i  - (yAxisWidth * i * ((newMax - newMin) / (oldMax - oldMin)) + ((newMin - oldMin) / (oldMax - oldMin)) * height)
                linePosition = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisWidth * i + k2 * (1.0 - stepX)
                if frame.minY...frame.maxY ~= linePosition {
                    drawLine(fromPoint: CGPoint(x: 0, y: linePosition),
                             toPoint: CGPoint(x: frame.width, y: linePosition),
                             color: lineColor.withAlphaComponent(stepX).cgColor,
                             lineWidth: 1.2)
                    
                    drawText(
                        text: "\(Int(newMin + i * newY))",
                        font: xAxisFont,
                        color: yAxisColor.withAlphaComponent(stepX),
                        frame: frame,
                        x: insets.left,
                        y: frame.height - linePosition)
                }
            } else {
                let linePosition = frame.height - insets.bottom - xAxisFont.lineHeight - spaceBetweenAxes - yAxisWidth * i
                
                drawLine(fromPoint: CGPoint(x: 0, y: linePosition),
                         toPoint: CGPoint(x: frame.width, y: linePosition),
                         color: lineColor.withAlphaComponent(1.0).cgColor,
                         lineWidth: 1.2)
                
                let value = Int(minY + i * y)
                
                drawText(
                    text: "\(value)",
                    font: xAxisFont,
                    color: yAxisColor,
                    frame: frame,
                    x: insets.left,
                    y: insets.bottom + xAxisFont.lineHeight + yAxisWidth * CGFloat(i) + spaceBetweenAxes)
            }
        }
        
        // MARK: Draw X Axis
        
        for i in 0..<chart.segmentsXAxis + 1 {
            let alpha = i % 2 == 0 ? 1.0 : chart.xAxisFontAlpha * 6
            let index = Int((CGFloat(i) * xAxisDif).rounded())
            let textWidth = chart.daysRect[index].width
            var x = insets.left + xAxisWidth * CGFloat(i) - textWidth * chart.lowerValue
            
            if i > 0 && i < chart.segmentsXAxis {
                x -= textWidth / 2
            }
            
            if i == chart.segmentsXAxis {
                x -= textWidth
            }
            
            if x < -textWidth || x > frame.width - insets.left - insets.right {
                continue
            }
            
            drawText(
                text: chart.days[index],
                font: xAxisFont,
                color: xAxisColor.withAlphaComponent(alpha),
                frame: frame,
                textRect: chart.daysRect[index],
                x: x,
                y: insets.bottom)
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
        
        let stepXAxis = width / CGFloat(chart.segments)
        let rangeYAxis = chart.yAxisFrameRange.max - chart.yAxisFrameRange.min
        let yAxisMax = chart.yAxisFrameRange.max
        
        saveGState()
        
        for graph in chart.visibleFrameGraphs {
            setStrokeColor(graph.color.cgColor)
            setLineWidth(lineWidth)
            setLineJoin(.round)
            setLineCap(.round)
            
            let point = getPointSmooth(at: 0,
                                       j: chart.lsIndex,
                                       smoothFactor: chart.smoothFactor,
                                       column: graph.column,
                                       insets: insets,
                                       stepXAxis: stepXAxis,
                                       height: height,
                                       yAxisMax: yAxisMax,
                                       rangeYAxis: rangeYAxis)
            
            move(to: point)
            
            for i in 1..<Int(chart.segments + 1) {
                let point = getPointSmooth(at: i,
                                           j: chart.lsIndex + i,
                                           smoothFactor: chart.smoothFactor,
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
        
        let width = frame.width - chart.graphInsets.left - chart.graphInsets.right
        let height = frame.height - chart.graphInsets.top - chart.graphInsets.bottom
        
        let lsIndex = chart.lsIndex
        let numberSegment = CGFloat(chart.segments)
        
        let indexPoint = max((Int(chart.definitionValuePoint * numberSegment) + lsIndex) / Int(chart.smoothFactor), lsIndex == 0 ? 0 : 1)
        
        let stepXAxis = width / numberSegment
        let i = Int(CGFloat(indexPoint) * chart.smoothFactor - CGFloat(lsIndex))
        let x = chart.graphInsets.left + CGFloat(i) * stepXAxis
        
        let rangeYAxis = chart.yAxisFrameRange.max - chart.yAxisFrameRange.min
        let yAxisMax = chart.yAxisFrameRange.max
        
        let lineFromPoint = CGPoint(x: x, y: chart.graphInsets.top)
        let lineToPoint = CGPoint(x: x, y: frame.height - chart.graphInsets.bottom)
        
        saveGState()
        
        drawLine(fromPoint: lineFromPoint,
                 toPoint: lineToPoint,
                 color: Theme.shared.definitionLineColor.cgColor)
        
        for graph in chart.visibleFrameGraphs {
            setStrokeColor(graph.color.cgColor)
            setFillColor(Theme.shared.mainColor.cgColor)
            setLineWidth(lineWidth)
            
            let point = getPointSmooth(at: i,
                                       j: lsIndex + i,
                                       smoothFactor: chart.smoothFactor,
                                       column: graph.column,
                                       insets: chart.graphInsets,
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
                             dateYear: chart.rangeYears[indexPoint],
                             dateMonthDay: chart.rangeDays[indexPoint],
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
    
    func getPoint(at index: Int, column: [CGFloat], insets: UIEdgeInsets, stepXAxis: CGFloat, height: CGFloat, yAxisMax: CGFloat, rangeYAxis: CGFloat) -> CGPoint {
        let x = insets.left + CGFloat(index) * stepXAxis
        let y = insets.top + height * (yAxisMax - column[index]) / rangeYAxis
        return CGPoint(x: x, y: y)
    }
    
    func getPointSmooth(at index: Int, j: Int, smoothFactor: CGFloat, column: [CGFloat], insets: UIEdgeInsets, stepXAxis: CGFloat, height: CGFloat, yAxisMax: CGFloat, rangeYAxis: CGFloat) -> CGPoint {
        let x = insets.left + CGFloat(index) * stepXAxis
        let newIndex = j / Int(smoothFactor)
        let j = CGFloat(j % Int(smoothFactor))
        let dif = newIndex + 1 == column.count ? 0 : (column[newIndex + 1] - column[newIndex]) / smoothFactor
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
        textRect: CGSize? = nil,
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
        
        var width: CGFloat
        var height: CGFloat
        
        if let textRect = textRect {
            width = textRect.width
            height = textRect.height
        } else {
            let attributedStringRect = text.boundingRect(font: font)
            width = attributedStringRect.width
            height = attributedStringRect.height
        }
        
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
                      font: UIFont) -> CGSize {
        return NSString(string: self).boundingRect(with: CGSize(width: width, height: height),
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [.font: font],
                                                   context: nil).size
    }
}
