//
//  ChartTableViewCell.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartTableViewCell: UITableViewCell {
    
    lazy var chartView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var controlView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(chartView)
        addSubview(controlView)
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            chartView.bottomAnchor.constraint(equalTo: controlView.topAnchor, constant: -5)
        ])
        NSLayoutConstraint.activate([
            controlView.heightAnchor.constraint(equalToConstant: 50),
            controlView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            controlView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            controlView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
