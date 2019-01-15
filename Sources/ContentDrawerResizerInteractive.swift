//
//  ContentDrawerResizerInteractive.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 09/06/2018.
//  Copyright 2018 Simon Whitty
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

extension ContentDrawerContainer {
    
    final class ResizerInteractive: NSObject, ContentDrawerResizer {
        
        unowned let view: ContentDrawerView
        
        weak var delegate: ContentDrawerResizerDelegate?
        
        lazy var gesture = UIPanGestureRecognizer(target: self, action: #selector(didSwipeUp(_ :)))
        
        init(view: ContentDrawerView) {
            self.view = view
            super.init()
            gesture.delegate = self
            view.addGestureRecognizer(gesture)
        }
        
        deinit {
            view.removeGestureRecognizer(gesture)
        }
        
        var initialHeight: CGFloat?
        
        func length(with translation: CGPoint) -> ContentDrawerView.Length? {
            guard let initialHeight = self.initialHeight else { return nil }
            
            switch view.ui.drawerDirection {
            case .topDown:
                return .fixed(initialHeight + translation.y)
            case .bottomUp:
                return .fixed(initialHeight - translation.y)
            }
        }
        
        @objc
        func didSwipeUp(_ gesture: UIPanGestureRecognizer) {
            let view = self.view
            if gesture.state == .began {
                initialHeight = view.containerDrawer.bounds.height
            }

            length(with: gesture.translation(in: view)).map {
                view.openLength = $0
                
                UIView.animate(withDuration: 0.07,
                               delay: 0.0,
                               options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                               animations: {
                                view.updateConstraintsIfNeeded()
                                view.layoutIfNeeded()
                               })
            }

            if gesture.state == .ended || gesture.state == .cancelled {
                length(with: gesture.predictedTranslation(in: view, after: 0.07)).map {
                    delegate?.resizer(self, didEndResizingTo: $0)
                }
            }
        }
    }
    
}

extension ContentDrawerContainer.ResizerInteractive: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: view.containerDrawer)
        let expandedBounds = view.containerDrawer.bounds.insetBy(dx: -60, dy: -60)
        return expandedBounds.contains(location)
    }
}

private extension UIPanGestureRecognizer {
    
    func predictedTranslation(in view: UIView?, after seconds: TimeInterval) -> CGPoint {
        let v = CGPoint(x: velocity(in: view).x * CGFloat(seconds),
                        y: velocity(in: view).y * CGFloat(seconds))
        
        return CGPoint(x: translation(in: view).x + v.x,
                       y: translation(in: view).y + v.y)
    }
}

private extension UIScrollView {
    
    var canScrollUp: Bool {
        return contentOffset.y > 0.0
    }
    
    var canScrollDown: Bool {
        return contentOffset.y < (contentSize.height - bounds.size.height)
    }
}

