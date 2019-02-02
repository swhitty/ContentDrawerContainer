//
//  ContentDrawerResizerBasic.swift
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
    
    final class ResizerBasic: NSObject, ContentDrawerResizer {

        let view: ContentDrawerView?
        weak var delegate: ContentDrawerResizerDelegate?

        init(view: ContentDrawerView) {
            self.view = view
            super.init()
            view.addGestureRecognizer(swipeUp)
            view.addGestureRecognizer(swipeDown)
        }
    
        deinit {
            view?.removeGestureRecognizer(swipeUp)
            view?.removeGestureRecognizer(swipeDown)
        }
        
        lazy var swipeUp: UIGestureRecognizer = {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeUp(_ :)))
            gesture.delegate = self
            gesture.direction = [.up]
            return gesture
        }()
        
        lazy var swipeDown: UIGestureRecognizer = {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDown(_ :)))
            gesture.delegate = self
            gesture.direction = [.down]
            return gesture
        }()
        
        @objc
        func didSwipeUp(_ sender: UISwipeGestureRecognizer) {
            guard
                sender == self.swipeUp,
                let direction = delegate?.resizer(currentDirection: self) else { return }

            switch direction {
            case .topDown:
                didSwipeClose()
            case .bottomUp:
                didSwipeOpen()
            }
        }

        @objc
        func didSwipeDown(_ sender: UISwipeGestureRecognizer) {
            guard
                sender == self.swipeDown,
                let direction = delegate?.resizer(currentDirection: self) else { return }
            
            switch direction {
            case .topDown:
                didSwipeOpen()
            case .bottomUp:
                didSwipeClose()
            }
        }
        
        func didSwipeOpen() {
            guard
                let openState = delegate?.resizer(currentOpenState: self) else { return }
            
            switch openState {
            case .peek:
                delegate?.resizer(self, setOpenState: .partial, animated: true)
            case .partial:
                delegate?.resizer(self, setOpenState: .open, animated: true)
            case .open, .closed:
                ()
            }
        }

        func didSwipeClose() {
            guard
                let openState = delegate?.resizer(currentOpenState: self) else { return }
            
            switch openState {
            case .open:
                delegate?.resizer(self, setOpenState: .partial, animated: true)
            case .partial:
                delegate?.resizer(self, setOpenState: .peek, animated: true)
            case .closed, .peek:
                ()
            }
        }
    }
    
}

extension ContentDrawerContainer.ResizerBasic: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = self.view else { return false }
        
        let point = touch.location(in: view)
        let expandedDrawer = view.containerDrawer.frame.insetBy(dx: -50, dy: -50)
        guard expandedDrawer.contains(point) else { return false }
        
        if gestureRecognizer == self.swipeUp {
            let t = canSwipeUp()
            return t
        } else if gestureRecognizer == self.swipeDown {
            let t = canSwipeDown()
            return t
        } else {
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy other: UIGestureRecognizer) -> Bool {
        guard let scrollView = other.view as? UIScrollView else { return true }
        
        if let openState = delegate?.resizer(currentOpenState: self), openState != .open {
            return true
        }

        if gestureRecognizer == self.swipeUp {
            return canUpGesturePrevent(scrollView: scrollView)
        } else if gestureRecognizer == self.swipeDown {
            return canDownGesturePrevent(scrollView: scrollView)
        } else {
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return false
    }
    
    func canUpGesturePrevent(scrollView: UIScrollView) -> Bool {
        guard let direction = delegate?.resizer(currentDirection: self) else { return false }

        switch direction {
        case .bottomUp:
            return false
        case .topDown:
            return scrollView.canScrollDown == false
        }
    }
    
    func canDownGesturePrevent(scrollView: UIScrollView) -> Bool {
        guard let direction = delegate?.resizer(currentDirection: self) else { return false }

        switch direction {
        case .bottomUp:
            return scrollView.canScrollUp == false
        case .topDown:
            return false
        }
    }

    func canSwipeDown() -> Bool {
        guard
            let direction = delegate?.resizer(currentDirection: self),
            let openState = delegate?.resizer(currentOpenState: self) else {
                return false
        }

        switch direction {
        case .bottomUp:
            return openState != .peek
        case .topDown:
            return openState != .open
        }
    }
    
    func canSwipeUp() -> Bool {
        guard
            let direction = delegate?.resizer(currentDirection: self),
            let openState = delegate?.resizer(currentOpenState: self) else {
                return false
        }

        switch direction {
        case .bottomUp:
            return openState != .open
        case .topDown:
            return openState != .peek
        }
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

