//
//  DrawerContainerView.swift
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

/// DrawerContainerView
///
/// Class that renders the background for the drawer view controller.
/// - background is UIVisualEffect blur, with rounded corners and, shadow applied.
/// - various techniques have been used to ensure the view is rendered and animated quickly 
///   and easily via UIView implicit animations.

final class DrawerContainerView: UIView {
    
    let contentView: UIView
    
    var backgroundView: UIView {
        didSet { didChangeBackgroundView(from: oldValue) }
    }
    
    let contentLayoutGuide: UILayoutGuide
    
    var background: ContentDrawerContainer.Background? {
        didSet {
            guard let background = background,
                  case .visualEffect(let effect) = background else {
                    backgroundView = UIView(frame: .zero)
                    backgroundView.addSubview(contentView)
                    contentView.constrainToFillSuperview()
                    return
            }
            
            guard let effectView = backgroundView as? UIVisualEffectView else {
                let blurView: UIVisualEffectView
                blurView = UIVisualEffectView(effect: effect)
                blurView.contentView.addSubview(contentView)
                backgroundView = blurView
                contentView.constrainToFillSuperview()
                return
            }
            
            effectView.effect = effect
        }
    }
    
    var cornerRadius: CGFloat = 0.0 {
        didSet { setNeedsLayout() }
    }
    
    var corners: UIRectCorner = .allCorners {
        didSet { setNeedsLayout() }
    }

    var shadowColor: UIColor = .black {
        didSet { setNeedsLayout() }
    }
    
    var shadowRadius: CGFloat = 0.0 {
        didSet { didChangeShadowRadius(from: oldValue) }
    }
    
    var shadowOffset: CGSize = .zero {
        didSet { didChangeShadowOffset(from: oldValue) }
    }
    
    var grabberStyle: GrabberStyle = .none {
        didSet { setNeedsLayout() }
    }
    
    let grabberTop: UIView
    let grabberBottom: UIView
    
    let shadowView: UIImageView
    var shadow: Shadow? {
        didSet{ didChangeShadow(from: oldValue) }
    }
    
    override init(frame: CGRect) {
        grabberTop = UIView(frame: .zero)
        grabberBottom = UIView(frame: .zero)
        shadowView = UIImageView(frame: .zero)
        backgroundView = UIView(frame: .zero)
        contentView = UIView(frame: .zero)
        contentLayoutGuide = UILayoutGuide()
        super.init(frame: frame)
        
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        contentView.constrainToFillSuperview()
        
        addSubview(grabberTop)
        grabberTop.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        grabberTop.clipsToBounds = true
        grabberTop.layer.cornerRadius = 2.5
        grabberTop.translatesAutoresizingMaskIntoConstraints = false
        grabberTop.widthAnchor.constraint(equalToConstant: 35).isActive = true
        grabberTop.heightAnchor.constraint(equalToConstant: 5).isActive = true
        grabberTop.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        grabberTop.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        
        addSubview(grabberBottom)
        grabberBottom.backgroundColor = UIColor(white: 0.7, alpha: 1.0)
        grabberBottom.clipsToBounds = true
        grabberBottom.layer.cornerRadius = 2.5
        grabberBottom.translatesAutoresizingMaskIntoConstraints = false
        grabberBottom.widthAnchor.constraint(equalToConstant: 35).isActive = true
        grabberBottom.heightAnchor.constraint(equalToConstant: 5).isActive = true
        grabberBottom.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        grabberBottom.topAnchor.constraint(equalTo: bottomAnchor, constant: -7).isActive = true
        
        contentView.addLayoutGuide(contentLayoutGuide)
        contentLayoutConstraints = [contentLayoutGuide.leftAnchor.constraint(equalTo: leftAnchor),
                                    contentLayoutGuide.rightAnchor.constraint(equalTo: rightAnchor),
                                    contentLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
                                    contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)]

        didChangeContentLayoutConstraints(from: [])
        didChangeShadowRadius(from: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("not implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.layer.cornerRadius = cornerRadius
        backgroundView.clipsToBounds = true
        
        grabberTop.alpha = grabberStyle == .top ? 1.0 : 0.0
        grabberBottom.alpha = grabberStyle == .bottom ? 1.0 : 0.0
 
        shadow = Shadow(color: shadowColor,
                        radius: shadowRadius,
                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius),
                        corners: corners)
    }
    
    private func didChangeBackgroundView(from previous: UIView?) {
        guard backgroundView != previous else { return }
        previous?.removeFromSuperview()
        insertSubview(backgroundView, aboveSubview: shadowView)
        backgroundView.constrainToFillSuperview()
    }
    
    private func didChangeShadow(from previous: Shadow?) {
        guard shadow != previous else { return }
        shadowView.image = shadow?.createImage()
    }
    
    private(set) var shadowConstraints: [NSLayoutConstraint] = [] {
        didSet{
            NSLayoutConstraint.deactivate(oldValue)
            NSLayoutConstraint.activate(shadowConstraints)
        }
    }
    
    private func didChangeShadowRadius(from previous: CGFloat?) {
        guard shadowRadius != previous else { return }
        setNeedsLayout()
        shadowConstraints = createShadowConstraints()
    }
    
    private func didChangeShadowOffset(from previous: CGSize?) {
        guard shadowOffset != previous else { return }
        setNeedsLayout()
        shadowConstraints = createShadowConstraints()
    }
    
    var contentLayoutConstraints: [NSLayoutConstraint] = [] {
        didSet{ didChangeContentLayoutConstraints(from: oldValue) }
    }
    
    private func didChangeContentLayoutConstraints(from previous: [NSLayoutConstraint] ) {
        guard contentLayoutConstraints != previous else { return }
        NSLayoutConstraint.deactivate(previous)
        NSLayoutConstraint.activate(contentLayoutConstraints)
    }
    
    func createShadowConstraints() -> [NSLayoutConstraint] {
        let insets = UIEdgeInsets(top: shadowOffset.height - shadowRadius,
                                  left:shadowOffset.width - shadowRadius,
                                  bottom: shadowOffset.height + shadowRadius,
                                  right: shadowOffset.width + shadowRadius)
        
        return shadowView.makeConstraintsToFillSuperview(insets: insets)
    }
    
    enum GrabberStyle {
        case top
        case bottom
        case none
    }
    
    //Render UIImage that looks like CALayer shadow
    struct Shadow: Equatable {
        var color: UIColor
        var radius: CGFloat
        var cornerRadii: CGSize
        var corners: UIRectCorner
        
        func createImage() -> UIImage {
            let shadowSize = CGSize(width: cornerRadii.width * 2.0 + 2.0,
                                    height: cornerRadii.height * 2.0 + 2.0)
            
            let imageSize = CGSize(width: shadowSize.width + (radius*2.0) + 1.0,
                                   height: shadowSize.height + (radius*2.0) + 1.0)

            
            let path = UIBezierPath(roundedRect: CGRect(x: radius, y: radius, width: shadowSize.width, height: shadowSize.height),
                                    byRoundingCorners: corners,
                                    cornerRadii: cornerRadii).cgPath
            
            let clipPath = UIBezierPath(roundedRect: CGRect(x: radius-1.0, y: radius-1.0, width: shadowSize.width+2.0, height: shadowSize.height+2.0),
                                    byRoundingCorners: corners,
                                    cornerRadii: cornerRadii).cgPath
            
            let image =  UIImage.render(size: imageSize,
                                        isOpaque: false,
                                        scale: 2.0) { ctx in
                
                let bounds = CGRect(x:0, y:0, width: imageSize.width, height: imageSize.height)
                
                ctx.setShadow(offset: .zero, blur: radius, color: UIColor.black.cgColor)
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.addPath(path)
                ctx.fillPath()
  
                ctx.setBlendMode(.copy)
                ctx.setFillColor(color.cgColor)
                ctx.addPath(clipPath)
                ctx.fillPath()
                
                ctx.setAlpha(0.7)
                ctx.setBlendMode(.sourceIn)
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(bounds)
            }
            
            var cornerInset = UIEdgeInsets.zero
            if corners.contains(.topLeft) {
                cornerInset.top = cornerRadii.height
                cornerInset.left = cornerRadii.width
            }
            
            if corners.contains(.topRight) {
                cornerInset.top = cornerRadii.height
                cornerInset.right = cornerRadii.width
            }
            
            if corners.contains(.bottomLeft) {
                cornerInset.bottom = cornerRadii.height
                cornerInset.left = cornerRadii.width
            }
            
            if corners.contains(.bottomRight) {
                cornerInset.bottom = cornerRadii.height
                cornerInset.right = cornerRadii.width
            }
            
            cornerInset.top += radius+1.0
            cornerInset.left += radius+1.0
            cornerInset.bottom += radius+1.0
            cornerInset.right += radius+1.0
            
            return image.resizableImage(withCapInsets: cornerInset)
        }
        
        static func ==(_ lhs: Shadow, _ rhs: Shadow) -> Bool {
            return lhs.color === rhs.color &&
                   lhs.radius == rhs.radius &&
                   lhs.cornerRadii == rhs.cornerRadii &&
                   lhs.corners == rhs.corners
        }
    }
}
