//
//  ViewController.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var theme: Theme { return Theme.shared }
    
    lazy var tableView: ChartsTableView = {
        var tableView = ChartsTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.callBack = { [weak self] in
            self?.theme.swithTheme()
            self?.themeUpdate()
        }
        return tableView
    }()
    
    @objc
    func switchThemeButtonDidTapped() {
        theme.swithTheme()
        themeUpdate()
    }
    
    private func themeUpdate() {
        self.tableView.reloadData()
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.view.backgroundColor = self.theme.additionalColor
            self.navigationController?.navigationBar.barTintColor = self.theme.mainColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: self.theme.mainTextColor]
            self.tableView.backgroundColor = self.theme.additionalColor
            UIApplication.shared.statusBarStyle = self.theme.barStyle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Statistics"
        navigationController?.navigationBar.isTranslucent = false
        tableView.data = [
            ("FOLLOWERS", [("Some", .red), ("One more", .blue), ("Another", .green)]),
            ("SUBSCRIBERS", [("Get", .black), ("Set", .white), ("Another", .purple), ("Another 2", .brown),]),
            ("FOLLOWERS", [("Some", .red), ("One more", .blue)])
        ]
        themeUpdate()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

