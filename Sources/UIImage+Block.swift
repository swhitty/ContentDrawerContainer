//
//  UIImage+Block.swift
//  ContentDrawerContainer
//
//  Created by Simon Whitty on 25/06/2017.
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

extension UIImage {
    
    class func render(size: CGSize,
                      isOpaque: Bool = true,
                      scale: CGFloat = 0,
                      block: (CGContext)->()) -> UIImage {
        
        if #available(iOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat.default()
            format.opaque = isOpaque
            format.scale = scale
            if #available(iOS 12.0, *) {
                format.preferredRange = .automatic
            } else {
                format.prefersExtendedRange = false
            }

            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { block($0.cgContext) }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
            let ctx = UIGraphicsGetCurrentContext()!
            
            block(ctx)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            
            UIGraphicsEndImageContext()
            
            return image
        }
    }
    
    func with(overlayColor: UIColor, size: CGSize? = nil) -> UIImage {
        let newSize = size ?? self.size
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        return UIImage.render(size: newSize,
                              isOpaque: false,
                              scale: 2.0) { ctx in
                                self.draw(in: rect)
                                ctx.setBlendMode(.sourceIn)
                                ctx.setFillColor(overlayColor.cgColor)
                                ctx.fill(rect)
        }
    }
    
    func with(overlayColor: UIColor, scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: floor(size.width * scale),
                             height: floor(size.height * scale))
        return with(overlayColor: overlayColor, size: newSize)
    }
}
