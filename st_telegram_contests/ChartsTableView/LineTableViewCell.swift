//
//  LineTableViewCell.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class LineTableViewCell: UITableViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
        }
    }
    
    lazy var rectView: UIView = {
        var view = UIView()
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    lazy var bottomView: UIView = {
        var view = UIView()
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.alpha = 1.0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(rectView)
        addSubview(bottomView)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            rectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            rectView.centerYAnchor.constraint(equalTo: centerYAnchor),
            rectView.heightAnchor.constraint(equalToConstant: 15),
            rectView.widthAnchor.constraint(equalToConstant: 15)
        ])
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rectView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: rectView.trailingAnchor, constant: 15),
            bottomView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updateTheme() {
        alpha = 1.0
        titleLabel.textColor = Theme.shared.mainTextColor
        titleLabel.backgroundColor = Theme.shared.mainColor
        backgroundColor = Theme.shared.mainColor
    }
}
