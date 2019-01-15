//
//  UIView+CompatibleSafeAreaLayoutGuide.swift
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

protocol SafeAreaProviding {
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UILayoutGuide: SafeAreaProviding { }

extension UIView {
    var compatibleSafeAreaLayoutGuide: SafeAreaProviding {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            // iOS 10 and below, topLayoutGuide and bottomLayoutGuide must be used to create
            // replicate safeAreaLayoutGuide
            guard
                let parentViewController = parentViewController,
                let safeArea = ViewControllerSafeArea(viewController: parentViewController) else {
                    return layoutMarginsGuide
            }

            return safeArea
        }
    }
}

private extension UIView {
    
    @available(iOS, obsoleted: 11.0, message: "use safeAreaLayoutGuide instead")
    var parentViewController: UIViewController? {
        guard let viewController = next as? UIViewController else {
            return superview?.parentViewController
        }
        return viewController
    }
    
    @available(iOS, obsoleted: 11.0, message: "use safeAreaLayoutGuide instead")
    struct ViewControllerSafeArea: SafeAreaProviding {
        var leftAnchor: NSLayoutXAxisAnchor
        var rightAnchor: NSLayoutXAxisAnchor
        var topAnchor: NSLayoutYAxisAnchor
        var bottomAnchor: NSLayoutYAxisAnchor

        init?(viewController: UIViewController) {
            guard let view = viewController.viewIfLoaded else { return nil }
            leftAnchor = view.leftAnchor
            rightAnchor = view.rightAnchor
            topAnchor = viewController.topLayoutGuide.bottomAnchor
            bottomAnchor = viewController.bottomLayoutGuide.topAnchor
        }
    }
}
