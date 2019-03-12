//
//  ChartsTableView.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartsTableView: UITableView {
    
    var data: [(title: String, items: [(line: String, color: UIColor)])] = [] {
        didSet {
            selected = data.map{ $0.items.map{ _ in false } }
            reloadData()
        }
    }
    
    var selected: [[Bool]] = [[]]
    
    var callBack: () -> Void = {}
    
    private let cellButtonIdentifier = "cell_button"
    private let cellLineIdentifier = "cell_line"
    private let cellChartIdentifier = "cell_chart"
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        register(ButtonTableViewCell.self, forCellReuseIdentifier: cellButtonIdentifier)
        register(LineTableViewCell.self, forCellReuseIdentifier: cellLineIdentifier)
        register(ChartTableViewCell.self, forCellReuseIdentifier: cellChartIdentifier)
        allowsMultipleSelection = true
        separatorStyle = .none
        delegate = self
        dataSource = self
        tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChartsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section != data.count ? data[section].items.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == data.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellButtonIdentifier, for: indexPath) as? ButtonTableViewCell else {
                fatalError("Can't dequeue cell")
            }
            
            cell.selectionStyle = .none
            cell.button.setTitle(Theme.shared.switchButtonText, for: .normal)
            cell.button.setTitleColor(Theme.shared.buttonTextColor, for: .normal)
            cell.button.backgroundColor = Theme.shared.mainColor
            cell.callBack = { [weak self] in self?.callBack() }
            
            return cell
        } else {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellChartIdentifier, for: indexPath) as? ChartTableViewCell else {
                    fatalError("Can't dequeue cell")
                }
                
                cell.selectionStyle = .none
                cell.backgroundColor = Theme.shared.mainColor
                cell.chartView.backgroundColor = Theme.shared.additionalColor
                cell.controlView.backgroundColor = Theme.shared.additionalColor
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellLineIdentifier, for: indexPath) as? LineTableViewCell else {
                    fatalError("Can't dequeue cell")
                }
                
                let item = data[indexPath.section].items[indexPath.row - 1]
                let isSelected = selected[indexPath.section][indexPath.row - 1]
                
                if isSelected {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
                
                cell.isSelected = isSelected
                
                cell.selectionStyle = .none
                cell.titleLabel.textColor = Theme.shared.mainTextColor
                cell.backgroundColor = Theme.shared.mainColor
                cell.titleLabel.text = item.line
                cell.rectView.backgroundColor = item.color
                if indexPath.row != data[indexPath.section].items.count {
                    cell.bottomView.isHidden = false
                    cell.bottomView.backgroundColor = Theme.shared.additionalColor
                } else {
                    cell.bottomView.isHidden = true
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == data.count {
            let view = UIView()
            view.backgroundColor = Theme.shared.additionalColor
            return view
        } else {
            let view = HeaderView()
            view.titleLabel.text = data[section].title
            view.backgroundColor = Theme.shared.additionalColor
            view.titleLabel.textColor = Theme.shared.additionalTextColor
            return view
        }
    }
}

extension ChartsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != data.count, indexPath.row != 0 {
            selected[indexPath.section][indexPath.row - 1] = true
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section != data.count, indexPath.row != 0 {
            selected[indexPath.section][indexPath.row - 1] = false
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != data.count, indexPath.row == 0 {
            return tableView.bounds.width
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == data.count {
            return 40
        } else {
            return 60
        }
    }
}
