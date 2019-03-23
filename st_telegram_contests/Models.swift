//
//  ChartModel.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

typealias MinMaxType = (min: CGFloat, max: CGFloat)

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

struct OptimizedChart {
    var x: [Date] = []
    var xAxisValues: [Date] = []
    var graphs: [Graph] = []
    
    var years: [String] = []
    var days: [String] = []
    var daysRect: [CGSize] = []
    var rangeYears: [String] = []
    var rangeDays: [String] = []
    var rangeDaysWidth: [CGFloat] = []
    
    var insets: UIEdgeInsets = UIEdgeInsets(top: 15.0, left: 0.0, bottom: 0.0, right: 0.0) {
        didSet {
            updateInsets()
        }
    }
    
    // Indents for drawing area chart
    var graphInsets: UIEdgeInsets = .zero
    
    var spaceBetweenAxes: CGFloat = 12.0 {
        didSet {
            updateInsets()
        }
    }
    
    // The coefficient of compressing of the graph along the y axis
    var compressFactor: CGFloat = 0.05
    // The number of graph breaks for smooth horizontal scrolling
    var smoothFactor: CGFloat = 4
    
    var xAxisFont = UIFont.systemFont(ofSize: 12.0)
    var yAxisFont = UIFont.systemFont(ofSize: 12.0)  {
        didSet {
            updateInsets()
        }
    }
    
    var xAxisFontAlpha: CGFloat = 0.0
    
    // Visible range [0.0, 1.0]
    var lowerValue: CGFloat = 0.6
    var upperValue: CGFloat = 1.0
    
    // Visible index range
    var lowerXAxis: CGFloat = 0
    var upperXAxis: CGFloat = 0
    
    // Left smoothed index
    var lsIndex: Int = 0
    
    // The number of smoothed segments
    var segments: Int = 0
    
    // Definition value [0.0, 1.0]
    var definitionValuePoint: CGFloat = 0.7
    
    // Min and max values of chart
    var yAxisRange: MinMaxType = (0, 0)
    // Min and max values of visible range chart
    var yAxisFrameRange: MinMaxType = (0, 0)
    
    var visibleGraphs: [Graph] = []
    // Visible graphs with truncated x and y
    var visibleFrameGraphs: [Graph] = []
    
    // Min and max values of visible range chart before animation
    var oldYRange: MinMaxType = (0, 0)
    // Min and max values of visible range chart after animation
    var newYRange: MinMaxType = (0, 0)
    
    // The number of displayed dates on the x axis
    var segmentsVisibleXAxis = 4
    // The number of dates on the x axis
    var segmentsXAxis = 0
    // The number of dates on the y axis
    var segmentsYAxis = 4
    
    init(chart: Chart) {
        self.x = chart.x
        self.graphs = chart.graphs
        self.years = chart.x.map { Theme.shared.yearFormatter.string(from: $0) }
        self.days = chart.x.map { Theme.shared.monthDayFormatter.string(from: $0) }
        self.daysRect = self.days.map { $0.boundingRect(font: self.xAxisFont) }
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
    
    mutating func changeRange(lowerValue: CGFloat, upperValue: CGFloat) {
        self.lowerValue = lowerValue
        self.upperValue = upperValue
        self.update(refresh: false)
    }
    
    private mutating func update(refresh: Bool) {
        let lowerXAxis = CGFloat(x.count) * lowerValue
        let upperXAxis = CGFloat(x.count) * upperValue
        
        guard x.count > 1, lowerXAxis < upperXAxis else {
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
        
        if refresh {
            let minMaxValues = visibleGraphs.map { (min: $0.minY, max: $0.maxY) }
            self.yAxisRange = (minMaxValues.map { $0.min }.min() ?? 0, minMaxValues.map { $0.max }.max() ?? 0)
        }
        
        let lsIndex = Int(lowerXAxis * smoothFactor) % Int(smoothFactor)
        let rsIndex = Int(upperXAxis * smoothFactor) % Int(smoothFactor)
        let segments = (xAxisValues.count - 1) * Int(smoothFactor) + rsIndex - lsIndex
        
        self.updateSegmentsXAxis()
        
        self.rangeYears = Array(years[Int(lowerXAxis)..<Int(upperXAxis)])
        self.rangeDays = Array(days[Int(lowerXAxis)..<Int(upperXAxis)])
        self.lsIndex = lsIndex
        self.segments = segments
        self.lowerXAxis = lowerXAxis
        self.upperXAxis = upperXAxis
        self.xAxisValues = xAxisValues
        self.visibleGraphs = visibleGraphs
        self.visibleFrameGraphs = visibleFrameGraphs.map { $0 }
    }
    
    mutating func updateSegmentsXAxis() {
        let allSegmentsXAxis = CGFloat(min(self.segmentsVisibleXAxis, x.count)) / (upperValue - lowerValue)
        let allSegmentsXAxisRounded = allSegmentsXAxis.rounded(.down)
        
        let l2 = log2(allSegmentsXAxisRounded).rounded(.down)
        let segmentsXAxis = Int(pow(2, l2))
        
        self.xAxisFontAlpha = log2(allSegmentsXAxis) - log2(allSegmentsXAxis).rounded(.down)
        self.segmentsXAxis = segmentsXAxis
    }
    
    mutating func updateYAxis() {
        let upLowerXAxis = max(Int(lowerXAxis.rounded(.up)), 0)
        let downLowerXAxis = max(Int(lowerXAxis), 0)
        
        let upUpperXAxis = min(Int(upperXAxis.rounded(.up)), x.count - 1)
        let downUpperXAxis = min(Int(upperXAxis), x.count - 1)
        
        let visibleFrameGraphs: [Graph] = visibleGraphs.map {
            var smoothGraph = $0
            
            smoothGraph.column = Array($0.column[Int(upLowerXAxis)..<Int(downUpperXAxis)])
            
            let difLower = ($0.column[upLowerXAxis] - $0.column[downLowerXAxis]) / smoothFactor
            let difUpper = ($0.column[upUpperXAxis] - $0.column[downUpperXAxis]) / smoothFactor
            let indentLower = CGFloat(Int(max(0, lowerXAxis) * smoothFactor) % Int(smoothFactor))
            let indentUpper = CGFloat(Int(min(CGFloat(x.count - 1), upperXAxis) * smoothFactor) % Int(smoothFactor))
            
            smoothGraph.column.append($0.column[downLowerXAxis] + difLower * indentLower)
            smoothGraph.column.append($0.column[downUpperXAxis] + difUpper * indentUpper)
            
            return smoothGraph
        }
        
        let minMaxYAxisFrameValue = visibleFrameGraphs.flatMap { $0.column }.minMax() ?? (0, 0)
        
        let yAxisFrameRange = getYAxisRange(minValue: minMaxYAxisFrameValue.min,
                                            maxValue: minMaxYAxisFrameValue.max,
                                            compressFactor: compressFactor)
        
        self.yAxisFrameRange = yAxisFrameRange
        self.oldYRange = yAxisFrameRange
        self.newYRange = yAxisFrameRange
    }
    
    private mutating func updateInsets() {
        self.graphInsets = UIEdgeInsets(top: insets.top + yAxisFont.lineHeight,
                                        left: insets.left,
                                        bottom: insets.bottom + yAxisFont.lineHeight + spaceBetweenAxes,
                                        right: insets.right)
    }
    
    func newYAxis(minY: CGFloat, maxY: CGFloat) -> (min: CGFloat, max: CGFloat) {
        if minY + maxY == 0 {
            return (0, 0)
        }
        
        let v1no = Int(log10(abs(max(minY, 1))))
        let v2no = Int(log10(abs(max(maxY, 1))))
        let rangeOrder = Int(log10(max(abs(maxY - minY), 1)))
        let left = max(v1no - rangeOrder + 2, 0)
        let right = v2no - rangeOrder + 2
        
        if minY == 0 {
            return (0, round(value: maxY, range: right, roundUp: true))
        }
        
        return (round(value: minY, range: left, roundUp: false), round(value: maxY, range: right, roundUp: true))
    }
    
    func round(value: CGFloat, range: Int, roundUp: Bool) -> CGFloat {
        let numberOrder = Int(log10(abs(value)))
        let rnd = CGFloat(truncating: pow(10, range) as NSNumber)
        let decimalValue = CGFloat(truncating: pow(10, numberOrder + 1) as NSNumber)
        let newValue = (value / decimalValue * rnd)
        return (roundUp ? newValue.rounded(.up) : newValue.rounded(.down)) * decimalValue / rnd
    }
    
    func getYAxisRange(minValue: CGFloat, maxValue: CGFloat, compressFactor: CGFloat) -> (min: CGFloat, max: CGFloat) {
        var minYAxisValue: CGFloat
        var maxYAxisValue: CGFloat
        let rangeYAxis = maxValue - minValue
        
        if minValue >= 0 {
            minYAxisValue = max(minValue - rangeYAxis * 0.3, 0)
        } else {
            minYAxisValue = minValue - rangeYAxis * compressFactor
        }
        
        maxYAxisValue = maxValue + rangeYAxis * compressFactor
        
        return newYAxis(minY: minYAxisValue, maxY: maxYAxisValue)
    }
}
