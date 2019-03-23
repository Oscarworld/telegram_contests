//
//  Themes.swift
//  st_telegram_contests
//
//  Created by Sergey Tobolin on 12/03/2019.
//  Copyright © 2019 Sergey Tobolin. All rights reserved.
//

import UIKit

class Theme {
    static let shared = Theme()
    
    private init() {
        updateColors()
        monthDayFormatter.dateFormat = "MMM dd"
        yearFormatter.dateFormat = "yyyy"
    }
    
    let monthDayFormatter = DateFormatter()
    let yearFormatter = DateFormatter()
    
    enum ThemeMode: Int {
        case day = 0
        case night = 1
    }
    
    var mode: ThemeMode = (ThemeMode(rawValue: (UserDefaults.standard.value(forKey: "ThemeModeKey") as? Int) ?? 0) ?? .day) {
        didSet {
            updateColors()
            UserDefaults.standard.setValue(mode.rawValue, forKey: "ThemeModeKey")
            NotificationCenter.default.post(name: .didSwitchTheme, object: nil)
        }
    }
    
    func switchTheme() {
        switch mode {
        case .day:
            mode = .night
        case .night:
            mode = .day
        }
    }
    
    private func updateColors() {
        switch mode {
        case .day:
            barStyle = .default
            mainColor = UIColor(netHex: 0xFEFEFE)
            additionalColor = UIColor(netHex: 0xEFEFF4)
            axisColor = UIColor(netHex: 0xE1E2E3)
            axisLineColor = UIColor(netHex: 0xF3F3F3)
            definitionLineColor = UIColor(netHex: 0xCFD1D2)
            mainTextColor = UIColor(netHex: 0x000000)
            additionalTextColor = UIColor(netHex: 0x68686D)
            axisTextColor = UIColor(netHex: 0x989EA2)
            definitionDateTextColor = UIColor(netHex: 0x68686D)
            controlColor = UIColor(netHex: 0xC9D4DF).withAlphaComponent(0.95)
            backgroundTrackColor = UIColor(netHex: 0xF2F5F8).withAlphaComponent(0.75)
            switchButtonText = "Switch to Night Mode"
        case .night:
            barStyle = .lightContent
            mainColor = UIColor(netHex: 0x222F3F)
            additionalColor = UIColor(netHex: 0x18222D)
            axisColor = UIColor(netHex: 0x131B23)
            axisLineColor = UIColor(netHex: 0x1B2734)
            definitionLineColor = UIColor(netHex: 0x131B23)
            mainTextColor = UIColor(netHex: 0xFFFFFF)
            additionalTextColor = UIColor(netHex: 0x5B6B80)
            axisTextColor = UIColor(netHex: 0x5B6B80)
            definitionDateTextColor = UIColor(netHex: 0xFFFFFF)
            controlColor = UIColor(netHex: 0x394859).withAlphaComponent(0.95)
            backgroundTrackColor = UIColor(netHex: 0x1B293A).withAlphaComponent(0.75)
            switchButtonText = "Switch to Day Mode"
        }
    }
    
    lazy var barStyle: UIStatusBarStyle = .default
    
    lazy var mainColor: UIColor = UIColor(netHex: 0xFEFEFE)
    lazy var additionalColor: UIColor = UIColor(netHex: 0xEFEFF4)
    
    lazy var axisColor: UIColor = UIColor(netHex: 0xE1E2E3)
    lazy var axisLineColor: UIColor = UIColor(netHex: 0xF3F3F3)
    lazy var definitionLineColor: UIColor = UIColor(netHex: 0xCFD1D2)
    
    lazy var mainTextColor: UIColor = UIColor(netHex: 0x000000)
    lazy var additionalTextColor: UIColor = UIColor(netHex: 0x68686D)
    lazy var axisTextColor: UIColor = UIColor(netHex: 0x989EA2)
    lazy var definitionDateTextColor: UIColor = UIColor(netHex: 0x68686D)
    
    lazy var controlColor: UIColor = UIColor(netHex: 0xC9D4DF).withAlphaComponent(0.95)
    lazy var backgroundTrackColor: UIColor = UIColor(netHex: 0xF2F5F8).withAlphaComponent(0.75)
    
    lazy var buttonTextColor: UIColor = UIColor(netHex: 0x007AFF)
    
    lazy var switchButtonText: String = "Switch to Night Mode"
}

extension Notification.Name {
    static let didSwitchTheme = Notification.Name("didSwitchTheme")
}
