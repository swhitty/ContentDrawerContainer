//
//  SettingsViewController.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 16/01/2019.
//  Copyright 2019 Simon Whitty
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/ContentDrawerContainer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import ContentDrawerContainer

final class SettingsViewController: UIViewController {
    
    var theme: Theme = .light {
        didSet {
            contentDrawerContainer?.setUI(compact: theme.compactUI,
                                          regular: theme.regularUI,
                                          animated: true)
        }
    }
    
    enum Theme {
        case light
        case dark
        
        var theme: (background: ContentDrawerContainer.Background, tintColor: UIColor, barStyle: UIBarStyle) {
            switch self {
            case .light:
                return (background: .visualEffect(UIBlurEffect(style: .extraLight)),
                        tintColor: UIView().tintColor,
                        barStyle: .default)
            case .dark:
                return (background: .visualEffect(UIBlurEffect(style: .dark)),
                        tintColor: .white,
                        barStyle: .blackTranslucent)
            }
        }
        
        var compactUI: ContentDrawerUI {
            var ui = ContentDrawerView.DefaultUI.bottomUp()
            ui.drawerBackground = theme.background
            ui.drawerTintColor = theme.tintColor
            ui.barStyle = theme.barStyle
            return ui
        }
        
        var regularUI: ContentDrawerUI {
            var ui = ContentDrawerView.DefaultUI.topDown()
            ui.drawerBackground = theme.background
            ui.drawerTintColor = theme.tintColor
            ui.barStyle = theme.barStyle
            return ui
        }
    }
    
    var segmentedTheme: UISegmentedControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let segmentedTheme = UISegmentedControl(items: ["Light", "Dark"])
        segmentedTheme.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedTheme)
        NSLayoutConstraint
            .activate([segmentedTheme.topAnchor.constraint(equalTo: view.topAnchor, constant: 5.0),
                       segmentedTheme.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                       segmentedTheme.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)])
        
        segmentedTheme.selectedSegmentIndex = 0;
        segmentedTheme.addTarget(self, action: #selector(didChangeTheme(_:)), for: .valueChanged)
        self.segmentedTheme = segmentedTheme

        contentDrawerContainer?.setUI(compact: theme.compactUI,
                                      regular: theme.regularUI,
                                      animated: true)
    }
    
    @objc
    func didChangeTheme(_ segmented: UISegmentedControl) {
        if segmented.selectedSegmentIndex == 1 {
            theme = .dark
        } else {
            theme = .light
        }
    }
}
