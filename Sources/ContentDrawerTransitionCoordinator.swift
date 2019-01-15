//
//  ContentDrawerTransitionCoordinator.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 21/11/2018.
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

protocol ContentDrawerTransitionCoordinator {
    @discardableResult
    func animate(alongsideTransition animation: @escaping () -> Void, completion: @escaping () -> Void) -> Bool
}
extension ContentDrawerTransitionCoordinator {
    @discardableResult
    func animate(alongsideTransition animation: @escaping () -> Void) -> Bool {
        return self.animate(alongsideTransition: animation, completion: {})
    }
}

//UINavigationController will update its UI to match the drawer UI
extension UINavigationController: ContentDrawerContainerTransitioning {
    func container(_ container: ContentDrawerContainer, willTransitionTo newUI: ContentDrawerUI, with coordinator: ContentDrawerTransitionCoordinator) {
        let navigationBar = self.navigationBar
        
        coordinator.animate(alongsideTransition: {
            navigationBar.barStyle = newUI.barStyle
            navigationBar.tintColor = newUI.drawerTintColor
            navigationBar.layoutIfNeeded()
        })
    }
}

extension ContentDrawerContainer {
    final class TransitionCoordinator: ContentDrawerTransitionCoordinator {
        
        let duration: TimeInterval
        let delay: TimeInterval
        let options: UIView.AnimationOptions
        
        var animations = [() -> Void]()
        var completions = [() -> Void]()

        init(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions) {
            self.duration = duration
            self.delay = delay
            self.options = options
        }
        
        @discardableResult
        func animate(alongsideTransition animation: @escaping () -> Void, completion: @escaping () -> Void) -> Bool  {
            animations.append(animation)
            completions.append(completion)
            return true
        }
        
        func perform() {
            guard duration > 0.0 else {
                animations.forEach { $0() }
                completions.reversed().forEach{ $0() }
                return
            }
            
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: options,
                animations: {
                    self.animations.forEach { $0() }
                },
                completion: { _ in
                    self.completions.reversed().forEach{ $0() }
                })
        }
    }
}
