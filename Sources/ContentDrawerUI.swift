//
//  ContentDrawerUI.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 26/06/2017.
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

/// ContentDrawerUI
///
/// Configurable UI provider for the ContentDrawerView.
/// ContentDrawerContainer provides different UI based on sizeclass
/// and can animate the transition.

protocol ContentDrawerUI {
    // direction to open the drawer
    var drawerDirection: ContentDrawerContainer.Direction { get }
    var initialOpenState: ContentDrawerContainer.OpenState { get }
    
    var barStyle: UIBarStyle { get }
    
    var drawerTintColor: UIColor { get }
    var drawerBackground: ContentDrawerContainer.Background { get }
    var drawerCornerRadius: CGFloat { get }
    var drawerCorners: UIRectCorner { get }
    var drawerShadowColor: UIColor { get }
    var drawerShadowRadius: CGFloat { get }
    var drawerShadowOffset: CGSize { get }
    
    // delegates the creation of auto layout constraints
    var constraintProvider: ContentDrawerConstraintProviding { get }
}

extension ContentDrawerContainer {
     /// Drawer may slide up from bottom of screen, or slide down from the top
    enum Direction {
        case bottomUp
        case topDown
    }
    
    /// Drawer background may be a UIVisualEffect or any UIView
    enum Background: Equatable {
        case visualEffect(UIVisualEffect)
        case view(UIView)
        
        var backgroundIdentifier: ObjectIdentifier {
            switch self {
            case .visualEffect(let val):
                return ObjectIdentifier(val)
            case .view(let val):
                return ObjectIdentifier(val)
            }
        }
        
        static func ==(lhs: ContentDrawerContainer.Background, rhs: ContentDrawerContainer.Background) -> Bool {
            return lhs.backgroundIdentifier == rhs.backgroundIdentifier
        }
    }

    /// Returns the current `UIBlurEffect` (if any) used by the drawer background
    /// Useful for creating `UIVibrancyEffect` referencing the `UIBlurEffect`.
    var drawerBlurEffect: UIBlurEffect? {
        guard case .visualEffect(let effect) = currentUI.drawerBackground else {
            return nil
        }
        
        return effect as? UIBlurEffect
    }
}


protocol ContentDrawerConstraintProviding {
    func drawerLength(for openState: ContentDrawerContainer.OpenState) -> ContentDrawerView.Length
    
    func fixedLength(of drawer: UIView, within parent: UIView) -> CGFloat
    
    func makeDrawerConstraints(for drawer: UIView,
                               within parent: UIView,
                               having length: ContentDrawerView.Length) -> [NSLayoutConstraint]
    
    func makeDrawerContentGuideConstraints(for guide: UILayoutGuide,
                                           within drawer: UIView,
                                           having drawerLength: ContentDrawerView.Length) -> [NSLayoutConstraint]
}

extension ContentDrawerView {
    
    enum Length {
        case maximum
        case fixed(CGFloat)
    }
    
    struct DefaultUI: ContentDrawerUI {
        var drawerDirection: ContentDrawerContainer.Direction = .topDown
        
        var initialOpenState = ContentDrawerContainer.OpenState.peek
        
        var barStyle: UIBarStyle = .default
        
        static let sharedBlur = UIBlurEffect(style: .extraLight)
        var drawerBackground = ContentDrawerContainer.Background.visualEffect(DefaultUI.sharedBlur)
        var drawerTintColor = UIView().tintColor!
        
        static func topDown() -> DefaultUI {
            return DefaultUI()
        }
        
        static func bottomUp() -> DefaultUI {
            var ui = DefaultUI()
            ui.drawerDirection = .bottomUp
            ui.drawerWidth = .maximum
            ui.drawerCorners = [.topLeft, .topRight]
            return ui
        }
        
        var drawerWidth = Length.fixed(320)
        var drawerCornerRadius: CGFloat = 13.0
        var drawerCorners: UIRectCorner = .allCorners
        var drawerShadowColor = UIColor(white: 0.0, alpha: 0.1)
        var drawerShadowRadius: CGFloat = 3.0
        var drawerShadowOffset: CGSize = .zero
        
        var constraints: Constraints {
            var constraints = Constraints()
            constraints.drawerDirection = drawerDirection
            constraints.drawerWidth = drawerWidth
            switch drawerDirection {
            case .topDown:
                constraints.drawerHeightOpen = Length.maximum
            case .bottomUp:
                constraints.drawerContentInsets = UIEdgeInsets(top: 13, left: 0, bottom: 13, right: 0)
                constraints.drawerInsets = UIEdgeInsets(top: 20, left: 0, bottom: -13, right: 0)
                constraints.drawerHeightClosed = Length.fixed(86)
                constraints.drawerHeightPeek = Length.fixed(86)
                constraints.drawerHeightPartial = Length.fixed(250)
                constraints.drawerHeightOpen = Length.maximum
            }
            return constraints
        }
        
        var constraintProvider: ContentDrawerConstraintProviding {
            return constraints
        }
    }
    
    
    struct Constraints: ContentDrawerConstraintProviding {
        var drawerDirection = ContentDrawerContainer.Direction.topDown
        var drawerContentInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        var drawerInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var drawerHeightClosed = Length.fixed(197)
        var drawerHeightPeek = Length.fixed(197)
        var drawerHeightPartial = Length.fixed(250)
        var drawerHeightOpen = Length.maximum
        var drawerWidth = Length.maximum
        
        func drawerLength(for openState: ContentDrawerContainer.OpenState) -> Length {
            switch openState {
            case .closed:
                return drawerHeightClosed
            case .peek:
                return drawerHeightPeek
            case .partial:
                return drawerHeightPartial
            case .open:
                return drawerHeightOpen
            }
        }
        
        func fixedLength(of drawer: UIView, within parent: UIView) -> CGFloat {
            return 10.0
        }
        
        func makeDrawerConstraints(for drawer: UIView,
                                   within parent: UIView,
                                   having length: Length) -> [NSLayoutConstraint] {
            
            var constraints: [NSLayoutConstraint]
            
            switch drawerWidth {
            case .maximum:
                constraints = [drawer.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: drawerInsets.left),
                               drawer.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -drawerInsets.right)]
            case .fixed(let w):
                
                let widthConstraint = drawer.widthAnchor.constraint(equalToConstant: w)
                widthConstraint.priority = .defaultHigh
                
                constraints = [drawer.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: drawerInsets.left),
                               drawer.rightAnchor.constraint(lessThanOrEqualTo: parent.rightAnchor, constant: -drawerInsets.right),
                               widthConstraint]
            }
            
            switch drawerDirection {
            case .topDown:
                constraints.append(contentsOf: makeTopDownConstraints(for: drawer, within: parent, having: length))
            case .bottomUp:
                constraints.append(contentsOf: makeBottomUpConstraints(for: drawer, within: parent, having: length))
            }

            return constraints
        }
        
        func makeDrawerContentGuideConstraints(for guide: UILayoutGuide,
                                               within drawer: UIView,
                                               having drawerLength: ContentDrawerView.Length) -> [NSLayoutConstraint] {

            let insets = drawerContentInsets
            var constraints: [NSLayoutConstraint]
            
            constraints = [guide.leftAnchor.constraint(equalTo: drawer.leftAnchor, constant: insets.left),
                           guide.rightAnchor.constraint(equalTo: drawer.rightAnchor, constant: -insets.right),
                           guide.topAnchor.constraint(equalTo: drawer.topAnchor, constant: insets.top)]
            if case .fixed(let v) = drawerLength, v < 100.0 {
                constraints.append(guide.bottomAnchor.constraint(equalTo: drawer.compatibleSafeAreaLayoutGuide.bottomAnchor))
            }
            else {
                constraints.append(guide.bottomAnchor.constraint(equalTo: drawer.bottomAnchor, constant: -insets.left))
            }
            return constraints
        }
        
        private func makeBottomUpConstraints(for drawer: UIView, within parent: UIView, having length: Length) -> [NSLayoutConstraint] {
            let safeArea = parent.compatibleSafeAreaLayoutGuide
            switch length {
            case .maximum:
                return [drawer.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -drawerInsets.bottom),
                        drawer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: drawerInsets.top)]
            case .fixed(let height):
                return [drawer.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -drawerInsets.bottom),
                        drawer.heightAnchor.constraint(equalToConstant: height)]
            }
        }
        
        private func makeTopDownConstraints(for drawer: UIView, within parent: UIView, having length: Length) -> [NSLayoutConstraint] {
            let safeArea = parent.compatibleSafeAreaLayoutGuide
            switch length {
            case .maximum:
                return [drawer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -drawerInsets.bottom),
                        drawer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: drawerInsets.top)]
            case .fixed(let height):
                return [drawer.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: drawerInsets.top),
                        drawer.heightAnchor.constraint(equalToConstant: height)]
            }
        }
    }
}


extension ContentDrawerView.DefaultUI: Equatable {
    static func ==(lhs: ContentDrawerView.DefaultUI, rhs: ContentDrawerView.DefaultUI) -> Bool {
        return
            lhs.drawerDirection == rhs.drawerDirection &&
            lhs.initialOpenState == rhs.initialOpenState &&
            lhs.barStyle == rhs.barStyle &&
            lhs.drawerBackground == rhs.drawerBackground &&
            lhs.drawerTintColor == rhs.drawerTintColor &&
            lhs.drawerWidth == rhs.drawerWidth &&
            lhs.drawerCornerRadius == rhs.drawerCornerRadius &&
            lhs.drawerCorners == rhs.drawerCorners &&
            lhs.drawerShadowColor == rhs.drawerShadowColor &&
            lhs.drawerShadowRadius == rhs.drawerShadowRadius &&
            lhs.drawerShadowOffset == rhs.drawerShadowOffset &&
            lhs.constraints == rhs.constraints
    }
}

extension ContentDrawerView.Constraints: Equatable {
    static func ==(lhs: ContentDrawerView.Constraints, rhs: ContentDrawerView.Constraints) -> Bool {
        return
            lhs.drawerDirection == rhs.drawerDirection &&
            lhs.drawerContentInsets == rhs.drawerContentInsets &&
            lhs.drawerInsets == rhs.drawerInsets &&
            lhs.drawerHeightClosed == rhs.drawerHeightClosed &&
            lhs.drawerHeightPeek == rhs.drawerHeightPeek &&
            lhs.drawerHeightPartial == rhs.drawerHeightPartial &&
            lhs.drawerHeightOpen == rhs.drawerHeightOpen &&
            lhs.drawerWidth == rhs.drawerWidth
    }
}

extension ContentDrawerView.Length: Comparable {
    
    private var compareVal: CGFloat {
        switch self {
        case .maximum:
            return CGFloat.greatestFiniteMagnitude
        case .fixed(let val):
            return val
        }
    }
    static func <(lhs: ContentDrawerView.Length, rhs: ContentDrawerView.Length) -> Bool {
        return lhs.compareVal < rhs.compareVal
    }
    
    static func ==(lhs: ContentDrawerView.Length, rhs: ContentDrawerView.Length) -> Bool {
        switch (lhs, rhs) {
        case (.maximum, .maximum):
            return true
        case (.fixed(let lVal), .fixed(let rVal)):
            return lVal == rVal
        default:
            return false
        }
    }
}
