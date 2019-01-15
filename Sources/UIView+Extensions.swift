//
//  UIView+Extensions.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 21/01/2018.
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

extension UIView {
    
    func makeConstraintsToFillSuperview(insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let superview = self.superview else {
            preconditionFailure("superview is required.")
        }
        translatesAutoresizingMaskIntoConstraints = false
        return [topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
                leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left),
                bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: insets.bottom),
                rightAnchor.constraint(equalTo: superview.rightAnchor, constant: insets.right)]
    }
    
    func constrainToFillSuperview(insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate(makeConstraintsToFillSuperview(insets: insets))
    }
    
}
