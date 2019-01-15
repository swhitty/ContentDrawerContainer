//
//  DetailViewController.swift
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

final class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        contentDrawerContainer?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                                   target: self,
                                                                                   action: #selector(didTapAdd))
    }
    
    @objc
    func didTapAdd() {
        guard let container = contentDrawerContainer,
              let openState = container.openState else { return }
        
        switch openState {
        case .closed:
            container.setOpenState(.peek, animated: true)
        case .peek:
            container.setOpenState(.partial, animated: true)
        case .partial:
            container.setOpenState(.open, animated: true)
        case .open:
            container.setOpenState(.closed, animated: true)
        }
    }
}
