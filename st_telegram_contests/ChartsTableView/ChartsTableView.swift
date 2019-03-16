//
//  ChartsTableView.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ChartsTableView: UITableView {
    
    var charts: [Chart] = []
    
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
        tableFooterView = UIView()
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChartsTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return charts.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == charts.count ? 1 : charts[section].graphs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section != charts.count else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellButtonIdentifier,
                                                           for: indexPath) as? ButtonTableViewCell else {
                fatalError("Can't dequeue reusable cell")
            }
            
            cell.selectionStyle = .none
            cell.button.setTitle(Theme.shared.switchButtonText, for: .normal)
            cell.button.setTitleColor(Theme.shared.buttonTextColor, for: .normal)
            cell.button.backgroundColor = Theme.shared.mainColor
            
            return cell
        }
        
        guard indexPath.row != 0 else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellChartIdentifier,
                                                           for: indexPath) as? ChartTableViewCell else {
                fatalError("Can't dequeue cell")
            }
            
            cell.selectionStyle = .none
            cell.backgroundColor = Theme.shared.mainColor
            cell.chartLayer.backgroundColor = Theme.shared.additionalColor.cgColor
            cell.chartSelector.mainColor = Theme.shared.mainColor
            cell.chartSelector.controlColor = Theme.shared.controlColor
            
            cell.configure(chart: charts[indexPath.section])
            cell.callback = { [weak self] lowerValue, upperValue in
                self?.charts[indexPath.section].lowerValue = lowerValue
                self?.charts[indexPath.section].upperValue = upperValue
            }
            
            cell.setNeedsDisplay()
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellLineIdentifier, for: indexPath) as? LineTableViewCell else {
            fatalError("Can't dequeue cell")
        }
        
        let item = charts[indexPath.section].graphs[indexPath.row - 1]
        
        if !item.isHidden {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        cell.isSelected = !item.isHidden
        
        cell.selectionStyle = .none
        cell.titleLabel.textColor = Theme.shared.mainTextColor
        cell.backgroundColor = Theme.shared.mainColor
        cell.titleLabel.text = item.name
        cell.rectView.backgroundColor = item.color
        
        if indexPath.row != charts[indexPath.section].graphs.count {
            cell.bottomView.isHidden = false
            cell.bottomView.backgroundColor = Theme.shared.additionalColor
        } else {
            cell.bottomView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == charts.count {
            let view = UIView()
            view.backgroundColor = Theme.shared.additionalColor
            return view
        } else {
            let view = HeaderView()
            view.titleLabel.text = "FOLLOWERS"
            view.backgroundColor = Theme.shared.additionalColor
            view.titleLabel.textColor = Theme.shared.additionalTextColor
            return view
        }
    }
}

extension ChartsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != charts.count, indexPath.row != 0 {
            charts[indexPath.section].graphs[indexPath.row - 1].isHidden = false
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = true
                if let graphCell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? ChartTableViewCell {
                    graphCell.setChart(charts[indexPath.section])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section != charts.count, indexPath.row != 0 {
            charts[indexPath.section].graphs[indexPath.row - 1].isHidden = true
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.isSelected = false
                if let graphCell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? ChartTableViewCell {
                    graphCell.setChart(charts[indexPath.section])
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != charts.count, indexPath.row == 0 {
            return tableView.bounds.width
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == charts.count {
            return 40
        } else {
            return 60
        }
    }
}
