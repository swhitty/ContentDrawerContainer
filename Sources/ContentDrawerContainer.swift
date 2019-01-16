//
//  ContentDrawerContainer.swift
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

/// A UIViewController that arranges 2 child view controllers
/// - content: a full size view controller that typically displays content
/// - drawer:  an auxillary view controller that is displayed above the content.
///            can be opened or closed by the user

public final class ContentDrawerContainer: UIViewController {
    
    /// A UIViewController that will appear within the drawer
    public var drawer: UIViewController? {
        didSet { didChangeDrawer(from: oldValue ) }
    }
    
    /// A UIViewController that will appear full size, underneath the drawer
    public var content: UIViewController? {
        didSet { didChangeContent(from: oldValue ) }
    }
    
    public enum OpenState {
        case closed   //drawer is hidden
        case peek     //slightly open
        case partial  //approx 50% open
        case open     //fully open
    }
    
    public private(set) var openState: OpenState?

    /// Open and close the drawer with a sprint animation
    public func setOpenState(_ state: OpenState, animated: Bool, completion: (() -> ())? = nil) {
        openState = state
        guard let view = _view else { return }
        
        view.openLength = view.ui.constraintProvider.drawerLength(for: state)
        
        UIView.animate(withDuration: 0.45,
                       delay: 0.0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 0.0,
                       options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {
                        view.updateConstraintsIfNeeded()
                        view.layoutIfNeeded()
                       },
                       completion: { _ in completion?() } )
    }
    
    private(set) var resizer: ContentDrawerResizer? {
        didSet { didChangeResizer(from: oldValue) }
    }

    public private(set) var _view: ContentDrawerView?
    
    public override func loadView() {
        let ui = currentUI
        let openState = self.openState ?? ui.initialOpenState
        let length = ui.constraintProvider.drawerLength(for: openState)
        let view = ContentDrawerView(ui: ui, openLength: length)
        view.content = content?.view
        view.drawer = drawer?.view
        
        resizer = ResizerBasic(view: view)
        //resizer = ResizerInteractive(view: view)
        
        self.view = view
        _view = view
        
        self.openState = openState
    }
    
    public private(set) var regularUI: ContentDrawerUI = ContentDrawerView.DefaultUI.topDown()
    public private(set) var compactUI: ContentDrawerUI = ContentDrawerView.DefaultUI.bottomUp()
    
    public var currentUI: ContentDrawerUI {
        return ui(for: traitCollection)
    }
    
    func ui(for traitCollection: UITraitCollection) -> ContentDrawerUI {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return regularUI
        case .compact, .unspecified:
            return compactUI
        }
    }
    
    public func setUI(compact: ContentDrawerUI, regular: ContentDrawerUI, animated: Bool, completion: (() -> ())? = nil) {
        compactUI = compact
        regularUI = compact
        
        let coordinator = TransitionCoordinator(duration: animated ? 0.2 : 0.0,
                                                delay: 0.0,
                                                options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction])
        
        let currentUI = self.currentUI
        let view = _view
        
        coordinator.animate(alongsideTransition: {
            view?.ui = currentUI
            view?.layoutIfNeeded()
        }) {
            completion?()
        }
        
        navigationController.map {
            $0.container(self, willTransitionTo: currentUI, with: coordinator)
        }
        
        //traverse child view controller heirachry and notify that transition will occur
        childrenTransitioning.forEach{
             $0.container(self, willTransitionTo: currentUI, with: coordinator)
        }
        
        coordinator.perform()
    }
    
    private func didChangeDrawer(from previous: UIViewController?) {
        guard drawer != previous else { return }
        
        previous?.willMove(toParent: nil)
        drawer.map{ addChild($0) }
        
        _view?.drawer = drawer?.view
        
        previous?.removeFromParent()
        drawer?.didMove(toParent: self)
    }
    
    private func didChangeContent(from previous: UIViewController?) {
        guard content != previous else { return }
        
        previous?.willMove(toParent: nil)
        content.map{ addChild($0) }
        
        _view?.content = content?.view
        
        previous?.removeFromParent()
        content?.didMove(toParent: self)
    }
    
    private func didChangeResizer(from previous: ContentDrawerResizer?) {
        guard resizer !== previous else { return }
        previous?.delegate = nil
        resizer?.delegate = self
    }

    private func didChangeCompactUI(from previous: ContentDrawerUI?) {
        
    }
    
    private func didChangeRegularUI(from previous: ContentDrawerUI?) {
        
    }
}

extension ContentDrawerContainer: ContentDrawerResizerDelegate {
    func resizer(currentDirection resizer: ContentDrawerResizer) -> ContentDrawerContainer.Direction {
        guard self.resizer === resizer else { return .topDown }
        return currentUI.drawerDirection
    }
    
    func resizer(currentOpenState resizer: ContentDrawerResizer) -> ContentDrawerContainer.OpenState {
        guard
            self.resizer === resizer,
            let openState = self.openState else { return .closed }

        return openState
    }
    
    func resizer(_ resizer: ContentDrawerResizer, setOpenState state: ContentDrawerContainer.OpenState, animated: Bool) {
        guard self.resizer === resizer else { return }
        self.setOpenState(state, animated: animated)
    }
    
    func resizer(_ resizer: ContentDrawerResizer, didEndResizingTo length: ContentDrawerView.Length) {
        guard
            self.resizer === resizer,
            case .fixed(let points) = length else {
                return
        }

        if points < 150 {
            setOpenState(.closed, animated: true)
        } else  if points < 500 {
            setOpenState(.partial, animated: true)
        } else {
            setOpenState(.open, animated: true)
        }
    }
}

extension ContentDrawerContainer {
    
    func horizontalSizeClass(forWidth: CGFloat) -> UIUserInterfaceSizeClass {
        return forWidth > 650.0 ? .regular : .compact
    }
    
    override public func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        guard childViewController == drawer,
              let view = _view else {
            return super.overrideTraitCollection(forChild: childViewController)
        }
        
        let collection = traitCollection
        let sizeClass = horizontalSizeClass(forWidth: view.containerDrawer.bounds.width)
        
        guard sizeClass != collection.horizontalSizeClass else {
            return collection
        }
        
        let hCollection = UITraitCollection(horizontalSizeClass: sizeClass)
        return UITraitCollection(traitsFrom: [collection, hCollection])
    }
}

extension ContentDrawerContainer {
    
    override public func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let view = _view else { return }
        let newUI = ui(for: newCollection)
        coordinator.animate(alongsideTransition: { _ in
            view.ui = newUI
        })
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let view = _view else { return }
        view.ui = ui(for: traitCollection)
    }
}

public extension UIViewController {
    var contentDrawerContainer: ContentDrawerContainer? {
        guard let parent = self.parent else { return nil }
        
        guard let container = parent as? ContentDrawerContainer else {
            return parent.contentDrawerContainer
        }
        
        return container
    }
}

protocol ContentDrawerContainerTransitioning {
    func container(_ container: ContentDrawerContainer, willTransitionTo newUI: ContentDrawerUI, with coordinator: ContentDrawerTransitionCoordinator)
}

extension UIViewController {
    var childrenTransitioning: [UIViewController & ContentDrawerContainerTransitioning] {
        var transitioning = [UIViewController & ContentDrawerContainerTransitioning]()
        
        children.forEach{
            if let vc = $0 as? UIViewController & ContentDrawerContainerTransitioning {
                transitioning.append(vc)
            }
            transitioning.append(contentsOf: $0.childrenTransitioning)
        }
        return transitioning
    }
}
