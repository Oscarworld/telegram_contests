//
//  ChartModel.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

enum Column: Decodable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        
        throw DecodingError.typeMismatch(Column.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Column"))
    }
}

enum ColumnType: String {
    case x
    case line
}

struct Graph {
    var column: [CGFloat]
    let color: UIColor
    let name: String
    let type: ColumnType
    var isHidden: Bool
    var minY: CGFloat
    var maxY: CGFloat

    public init(column: [CGFloat], color: UIColor, name: String, type: ColumnType, isHidden: Bool) {
        self.column = column
        self.color = color
        self.name = name
        self.type = type
        self.isHidden = isHidden
        let minMax = column.minMax() ?? (0, 0)
        self.minY = minMax.min
        self.maxY = minMax.max
    }
}

struct OptimizedChart {
    var x: [Date] = []
    var xYear: [String] = []
    var xMonthDay: [String] = []
    var xMonthDayWidth: [CGFloat] = []
    var graphs: [Graph] = []
    
    var insets: UIEdgeInsets = UIEdgeInsets(top: 15.0, left: 0.0, bottom: 0.0, right: 0.0) {
        didSet {
            updateInsets()
        }
    }
    
    var spaceBetweenAxes: CGFloat = 12.0 {
        didSet {
            updateInsets()
        }
    }
    
    var insetsWithAxes: UIEdgeInsets = .zero
    var stretchingYAxis: CGFloat = 0.15
    var smoothingFactor: CGFloat = 4
    
    var xAxisFont = UIFont.systemFont(ofSize: 12.0)
    var xAxisFontAlpha: CGFloat = 0.0
    var xAxisTextColor = Theme.shared.axisTextColor
    var yAxisFont = UIFont.systemFont(ofSize: 12.0)  {
        didSet {
            updateInsets()
        }
    }
    
    var yAxisTextColor = Theme.shared.axisTextColor
    var axisColor = Theme.shared.axisColor
    
    var lowerValue: CGFloat = 0.6
    var upperValue: CGFloat = 1.0
    
    var lowerXAxis: CGFloat = 0
    var upperXAxis: CGFloat = 0
    
    var lj: Int = 0
    var numberSegment: Int = 0
    
    var definitionValuePoint: CGFloat = 0.7
    
    var xAxisValues: [Date] = []
    var xAxisYear: [String] = []
    var xAxisMonthDay: [String] = []
    var yAxisFrameRange: (min: CGFloat, max: CGFloat) = (0, 0)
    var yAxisRange: (min: CGFloat, max: CGFloat) = (0, 0)
    var visibleGraphs: [Graph] = []
    var visibleFrameGraphs: [Graph] = []
    
    var numberSegmentVisibleXAxis = 4
    var numberSegmentXAxis: Int = 0
    
    var timer: Timer?
    
    init(chart: Chart) {
        self.x = chart.x
        self.graphs = chart.graphs
        self.xYear = chart.x.map { Theme.shared.yearFormatter.string(from: $0) }
        self.xMonthDay = chart.x.map { Theme.shared.monthDayFormatter.string(from: $0) }
        self.xMonthDayWidth = self.xMonthDay.map { $0.boundingRect(font: self.xAxisFont).width }
        self.update(refresh: true)
        self.updateYAxis()
        self.updateInsets()
    }
    
    mutating func hideGraph(at index: Int) {
        graphs[index].isHidden = true
        self.update(refresh: true)

    }
    
    mutating func showGraph(at index: Int) {
        graphs[index].isHidden = false
        update(refresh: true)
    }
    
    mutating func changeBoundaries(lowerValue: CGFloat, upperValue: CGFloat) {
        self.lowerValue = lowerValue
        self.upperValue = upperValue
        self.update(refresh: false)
    }
    
    private mutating func update(refresh: Bool) {
        guard x.count > 1 else {
            return
        }
        
        let lowerXAxis = CGFloat(x.count) * lowerValue
        let upperXAxis = CGFloat(x.count) * upperValue
        
        guard lowerXAxis < upperXAxis else {
            return
        }
        
        let visibleGraphs: [Graph] = refresh ? graphs.filter { !$0.isHidden } : self.visibleGraphs
        let visibleFrameGraphs: [Graph] = visibleGraphs.map {
            var graph = $0
            
            graph.column = Array($0.column[Int(lowerXAxis)..<Int(upperXAxis)])
            
            if upperXAxis != upperXAxis.rounded(.down) {
                graph.column.append($0.column[Int(upperXAxis)])
            }
            
            return graph
        }
        
        let xAxisValues = Array(x[Int(lowerXAxis)..<Int(upperXAxis)])
        
        guard xAxisValues.count > 1 else {
            return
        }
        
        let numberSegmentVisibleXAxis = min(self.numberSegmentVisibleXAxis, x.count)
        let allNumberSegmentXAxis = CGFloat(numberSegmentVisibleXAxis) / (upperValue - lowerValue)
        let allNumberSegmentXAxisRounded = allNumberSegmentXAxis.rounded(.down)
        
        let l2 = log2(allNumberSegmentXAxisRounded).rounded(.down)
        let numberSegmentXAxis = Int(pow(2, l2))
        
        if refresh {
            let minMaxValues = visibleGraphs.map { (min: $0.minY, max: $0.maxY) }
            self.yAxisRange = (minMaxValues.map { $0.min }.min() ?? 0 , minMaxValues.map { $0.max }.max() ?? 0)
        }
        
        let lj = Int(lowerXAxis * smoothingFactor) % Int(smoothingFactor)
        let rj = Int(upperXAxis * smoothingFactor) % Int(smoothingFactor)
        let numberSegment = (xAxisValues.count - 1) * Int(smoothingFactor) + rj - lj
        
        self.xAxisYear = Array(xYear[Int(lowerXAxis)..<Int(upperXAxis)])
        self.xAxisMonthDay = Array(xMonthDay[Int(lowerXAxis)..<Int(upperXAxis)])
        
        self.xAxisFontAlpha = log2(allNumberSegmentXAxis) - log2(allNumberSegmentXAxis).rounded(.down)
        self.lj = lj
        self.numberSegment = numberSegment
        self.lowerXAxis = lowerXAxis
        self.upperXAxis = upperXAxis
        self.numberSegmentXAxis = numberSegmentXAxis
        self.xAxisValues = xAxisValues
        self.visibleGraphs = visibleGraphs
        self.visibleFrameGraphs = visibleFrameGraphs.map { $0 }
    }
    
    mutating func updateYAxis() {
        let i = 0
        
        let upLowerXAxis = max(Int(lowerXAxis.rounded(.up)) - i, 0)
        let downLowerXAxis = max(Int(lowerXAxis) - i, 0)
        
        let upUpperXAxis = min(Int(upperXAxis.rounded(.up)) + i, x.count - 1)
        let downUpperXAxis = min(Int(upperXAxis) + i, x.count - 1)
        
        let visibleFrameGraphs: [Graph] = visibleGraphs.map {
            var smoothGraph = $0
            
            smoothGraph.column = Array($0.column[Int(upLowerXAxis)..<Int(downUpperXAxis)])
            
            var dif = ($0.column[upLowerXAxis] - $0.column[downLowerXAxis]) / smoothingFactor
            var j = CGFloat(Int(max(0, lowerXAxis - CGFloat(i)) * smoothingFactor) % Int(smoothingFactor))
            smoothGraph.column.append($0.column[downLowerXAxis] + dif * CGFloat(j))
            
            dif = ($0.column[upUpperXAxis] - $0.column[downUpperXAxis]) / smoothingFactor
            j = CGFloat(Int(min(CGFloat(x.count - 1), upperXAxis + CGFloat(i)) * smoothingFactor) % Int(smoothingFactor))
            smoothGraph.column.append($0.column[downUpperXAxis] + dif * CGFloat(j))
            
            return smoothGraph
        }
        
        let minMaxYAxisFrameValue = visibleFrameGraphs.flatMap { $0.column }.minMax() ?? (0, 0)
        
        let yAxisFrameRange = getYAxisRange(minValue: minMaxYAxisFrameValue.min, maxValue: minMaxYAxisFrameValue.max, stretching: stretchingYAxis)
        
        self.yAxisFrameRange = yAxisFrameRange
    }
    
    private mutating func updateInsets() {
        self.insetsWithAxes = UIEdgeInsets(top: insets.top + yAxisFont.lineHeight,
                                           left: insets.left,
                                           bottom: insets.bottom + yAxisFont.lineHeight + spaceBetweenAxes,
                                           right: insets.right)
    }
    
    func getYAxisRange(minValue: CGFloat, maxValue: CGFloat, stretching: CGFloat) -> (min: CGFloat, max: CGFloat) {
        var minYAxisValue = minValue
        var maxYAxisValue = maxValue
        let rangeYAxis = maxYAxisValue - minYAxisValue
        
        if minYAxisValue >= 0 {
            minYAxisValue = max(minYAxisValue - rangeYAxis * stretching, 0)
        } else {
            minYAxisValue -= minYAxisValue - rangeYAxis * stretching
        }
        
        maxYAxisValue += rangeYAxis * stretching
        
        return (minYAxisValue, maxYAxisValue)
    }
}

struct Chart: Decodable {
    var x: [Date] = []
    var graphs: [Graph] = []
    
    private enum ChartCodingKey: String, CodingKey {
        case columns
        case types
        case names
        case colors
    }
    
    init(columns: [[Column]], types: [String: String], names: [String: String], colors: [String: String]) {
        for column in columns {
            var items = [CGFloat]()
            var key = ""
            
            for item in column {
                switch item {
                case .integer(let val):
                    items.append(CGFloat(val))
                case .string(let val):
                    key = val
                }
            }
            
            if key == ColumnType.x.rawValue {
                self.x = items.map { Date(timeIntervalSince1970: TimeInterval(Int($0 / 1000))) }
            } else {
                guard let color = colors[key],
                    let name = names[key],
                    let typeRaw = types[key],
                    let type = ColumnType(rawValue: typeRaw)
                else {
                    fatalError("Can't parse graph")
                }
                
                let graph = Graph(column: items,
                                   color: UIColor(hexString: color),
                                   name: name,
                                   type: type,
                                   isHidden: false)
                self.graphs.append(graph)
            }
        }
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChartCodingKey.self)
        let columns = try container.decode([[Column]].self, forKey: .columns)
        let types = try container.decode([String: String].self, forKey: .types)
        let names = try container.decode([String: String].self, forKey: .names)
        let colors = try container.decode([String: String].self, forKey: .colors)
        self.init(columns: columns, types: types, names: names, colors: colors)
    }
}

extension Array where Array.Element : Comparable {
    
    public func minMax() -> (min: Element, max: Element)? {
        guard !self.isEmpty else {
            return nil
        }
        
        var min = self[0]
        var max = self[0]
        for item in self[1..<self.count] {
            if item < min {
                min = item
            } else if item > max {
                max = item
            }
        }
        return (min, max)
    }
}
