//
//  Graph.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 13/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

enum ColumnType: String {
    case x
    case line
}

struct Graph {
    let column: [CGFloat]
    let color: UIColor
    let name: String
    let type: ColumnType
    var isHidden: Bool
}
