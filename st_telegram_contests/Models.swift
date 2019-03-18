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
}

struct OptimizedChart {
    var x: [Date] = []
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
    
    var xAxisFont = UIFont.systemFont(ofSize: 12.0)
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
    
    var definitionValuePoint: CGFloat = 0.7
    
    var xAxisValues: [Date] = []
    var yAxisRange: (min: CGFloat, max: CGFloat) = (0, 0)
    var visibleGraphs: [Graph] = []
    
    init(chart: Chart) {
        self.x = chart.x
        self.graphs = chart.graphs
        self.update()
        self.updateInsets()
    }
    
    mutating func hideGraph(at index: Int) {
        graphs[index].isHidden = true
        self.update()
    }
    
    mutating func showGraph(at index: Int) {
        graphs[index].isHidden = false
        update()
    }
    
    mutating func changeBoundaries(lowerValue: CGFloat, upperValue: CGFloat) {
        self.lowerValue = lowerValue
        self.upperValue = upperValue
        self.update()
    }
    
    private mutating func update() {
        guard x.count > 1 else {
            return
        }
        
        let lowerXAxis = Int(CGFloat(x.count) * lowerValue)
        let upperXAxis = Int(CGFloat(x.count) * upperValue)
        
        guard lowerXAxis < upperXAxis else {
            return
        }
        
        let visibleGraphs: [Graph] = graphs.filter { !$0.isHidden }.map {
            var graph = $0
            graph.column = Array(graph.column[lowerXAxis..<upperXAxis])
            return graph
        }
        
        let xAxisValues = Array(x[lowerXAxis..<upperXAxis])
        let yAxisValues = visibleGraphs.flatMap{ $0.column }
        
        guard xAxisValues.count > 1 else {
            return
        }
        
        let minYAxisValue = yAxisValues.min() ?? 0
        let maxYAxisValue = yAxisValues.max() ?? 0
        
        let yAxisRange = getYAxisRange(minValue: minYAxisValue, maxValue: maxYAxisValue, stretching: stretchingYAxis)
        
        self.xAxisValues = xAxisValues
        self.yAxisRange = yAxisRange
        self.visibleGraphs = visibleGraphs
    }
    
    private mutating func updateInsets() {
        self.insetsWithAxes = UIEdgeInsets(top: insets.top + yAxisFont.lineHeight,
                                           left: insets.left,
                                           bottom: insets.bottom + yAxisFont.lineHeight + spaceBetweenAxes,
                                           right: insets.right)
    }
    
    private func getYAxisRange(minValue: CGFloat, maxValue: CGFloat, stretching: CGFloat) -> (min: CGFloat, max: CGFloat) {
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
