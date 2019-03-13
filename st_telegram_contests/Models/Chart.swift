//
//  ChartModel.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

struct Chart: Decodable {
    var x: [Int] = []
    var graphs: [Graph] = []
    var lowerValue: CGFloat = 0.6
    var upperValue: CGFloat = 1.0
    
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
                self.x = items.map { Int($0) }
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
