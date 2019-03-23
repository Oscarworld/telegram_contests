//
//  ViewController.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableView: ChartsTableView = {
        var tableView = ChartsTableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func updateColors() {
        view.backgroundColor = Theme.shared.additionalColor
        navigationController?.navigationBar.barTintColor = Theme.shared.mainColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.shared.mainTextColor]
        tableView.backgroundColor = Theme.shared.additionalColor
        UIApplication.shared.statusBarStyle = Theme.shared.barStyle
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            tableView.charts = (try parseJson()).map{ OptimizedChart(chart: $0) }
        } catch {
            fatalError("Can't parse json data")
        }
        
        navigationItem.title = "Statistics"
        navigationController?.navigationBar.isTranslucent = false
        updateColors()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDidReceiveData(_:)),
                                               name: .didSwitchTheme,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didSwitchTheme, object: nil)
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        updateColors()
    }
    
    func parseJson() throws -> [Chart] {
        guard let url = Bundle.main.url(forResource: "chart_data", withExtension: "json") else {
            fatalError("Can't find json file")
        }
        
        let jsonData = try Data(contentsOf: url)
        let chart = try JSONDecoder().decode([Chart].self, from: jsonData)
        return chart
    }
}
