//
//  ContentDrawerView.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 24/06/2017.
//  Copyright 2017 Simon Whitty
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

final class ContentDrawerView: UIView {
    
    var drawer: UIView? {
        didSet { didChangeDrawer(from: oldValue) }
    }
    
    var openLength: Length {
        didSet { setNeedsUpdateConstraints() }
    }
    
    var content: UIView? {
        didSet { didChangeContent(from: oldValue) }
    }
    
    var ui: ContentDrawerUI {
        didSet { didChangeUI(from: oldValue) }
    }
    
    let containerDrawer = DrawerContainerView(frame: .zero)
    let containerContent = UIView(frame: .zero)
    
    init(ui: ContentDrawerUI, openLength: ContentDrawerView.Length) {
        self.ui = ui
        self.openLength = openLength
        super.init(frame: .zero)
        
        addSubview(containerContent)
        addSubview(containerDrawer)
        
        containerDrawer.translatesAutoresizingMaskIntoConstraints = false
        containerContent.constrainToFillSuperview()
        
        didChangeUI(from: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not implemented") }
    
    var containerDrawerConstraints: [NSLayoutConstraint] = [] {
        didSet {
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(containerDrawerConstraints)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        let provider = ui.constraintProvider
        
        containerDrawerConstraints = provider.makeDrawerConstraints(for: containerDrawer,
                                                                    within: self,
                                                                    having: openLength)
        
        containerDrawer.contentLayoutConstraints = provider.makeDrawerContentGuideConstraints(for: containerDrawer.contentLayoutGuide,
                                                                                              within: containerDrawer,
                                                                                              having: openLength)
    }
    
    private func didChangeUI(from previous: ContentDrawerUI?) {
        if let existingDefault =  previous as? DefaultUI,
            let newDefault = ui as? DefaultUI {
            guard existingDefault != newDefault else {
                return
            }
        }
        
        containerDrawer.corners = ui.drawerCorners
        containerDrawer.cornerRadius = ui.drawerCornerRadius
        containerDrawer.shadowColor = ui.drawerShadowColor
        containerDrawer.shadowRadius = ui.drawerShadowRadius
        containerDrawer.shadowOffset = ui.drawerShadowOffset
        
        containerDrawer.background = ui.drawerBackground
        containerDrawer.tintColor = ui.drawerTintColor
        
        switch ui.drawerDirection {
        case .topDown:
            containerDrawer.grabberStyle = .bottom
        case .bottomUp:
            containerDrawer.grabberStyle = .top
        }
        
        setNeedsUpdateConstraints()
    }
    
    private func didChangeContent(from previous: UIView?) {
        guard content != previous else { return }
        
        previous.map{
            $0.removeFromSuperview()
        }
        
        content.map {
            containerContent.addSubview($0)
            $0.constrainToFillSuperview()
        }
    }
    
    private func didChangeDrawer(from previous: UIView?) {
        guard drawer != previous else { return }
        
        previous.map{
            $0.removeFromSuperview()
        }
        
        drawer.map {
            containerDrawer.contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            let guide = containerDrawer.contentLayoutGuide
            NSLayoutConstraint.activate(
                [$0.leftAnchor.constraint(equalTo: guide.leftAnchor),
                 $0.rightAnchor.constraint(equalTo: guide.rightAnchor),
                 $0.topAnchor.constraint(equalTo: guide.topAnchor),
                 $0.bottomAnchor.constraint(equalTo: guide.bottomAnchor)])
        }
    }
}


