//
//  FGInitialCircleImage.swift
//  FGInitialCircleImage
//
//  Created by Feng Guo on 19/01/2016.
//  Copyright © 2016 Feng Guo. All rights reserved.
//

import UIKit

class FGInitialCircleImage {
    
    static func circleImage(firstName: NSString, lastName: NSString, size: CGFloat, borderWidth: CGFloat, borderColor: UIColor, backgroundColor: UIColor, textColor: UIColor) -> UIImage? {
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: size, height: size);
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, UIScreen.main.scale)
        
        let factor: CGFloat = 2.0
        let bezierRect = imageRect
        bezierRect.insetBy(dx: ceil(borderWidth / factor), dy: ceil(borderWidth / factor))
        
        let circlePath: UIBezierPath = UIBezierPath.init(ovalIn: bezierRect)
        
        // Border
        borderColor.setStroke()
        circlePath.lineWidth = borderWidth
        circlePath.stroke()
        
        // Fill
        backgroundColor.setFill()
        circlePath.fill()
        
        // Text
        let internalCircleRect = calculateInternalRectSize(size: imageRect);
        let attributeString = initals(firstName: firstName, lastName: lastName, size: internalCircleRect, textColor: textColor)
    
        attributeString.draw(in: internalCircleRect)
        
        // Final rendering
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image.withRenderingMode(UIImage.RenderingMode.automatic)
    }
    
    // MARK: Internal
    
    private class func initals(firstName: NSString, lastName: NSString, size: CGRect, textColor: UIColor) -> NSAttributedString {
        let firstNameInitial: NSString = firstName.substring(to: 1) as NSString
        let lastNameInitial: NSString = lastName.substring(to: 1) as NSString
        let inital: NSString = (firstNameInitial as String) + (lastNameInitial as String) as NSString
        
        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle;
        paragraphStyle.alignment = NSTextAlignment.center;
        let attributes = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        let attributed = NSMutableAttributedString(string: inital as String, attributes: attributes)
        
        addDynamicFontAttribute(attributeString: attributed, rect: size)

        return attributed
    }
    
    private class func addDynamicFontAttribute(attributeString: NSMutableAttributedString, rect: CGRect) {
        let text :NSString = attributeString.string as NSString
        
        if (text.length == 0) {
            return;
        }
        
        let maxFontSize: CGFloat = 150.0;
        let minFontSize: CGFloat = 5.0;
        
        var maxFont = Int(maxFontSize)
        var minFont = Int(minFontSize)
        
        let constraintSize = CGSize(width: rect.width, height: CGFloat.greatestFiniteMagnitude)
        
        var font: UIFont = UIFont.systemFont(ofSize: CGFloat(1.0))
        
        while (minFont <= maxFont) {
            let currentSize = (minFont + maxFont) / 2
            font = font.withSize(CGFloat(currentSize))
            
            attributeString.removeAttribute(NSAttributedString.Key.font, range: NSMakeRange(0, text.length));
            attributeString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, text.length))
            let textRect = attributeString.boundingRect(with: constraintSize, options:.usesLineFragmentOrigin, context: nil)
            
            let labelSize = textRect.size;
            
            if (labelSize.height < rect.height &&
                labelSize.height >= rect.height &&
                labelSize.width < rect.width &&
                labelSize.width >= rect.width) {
                break;
            } else if (labelSize.height > rect.height || labelSize.width > rect.width) {
                maxFont = currentSize - 1
            } else {
                minFont = currentSize + 1
            }
        }
    }
    
    private class func calculateInternalRectSize(size: CGRect) -> CGRect {
        let radius = size.width / 2
        let newOrigin = (size.width / sqrt(CGFloat(2)) - radius) / sqrt(CGFloat(2))
        let newSize = sqrt(CGFloat(2)) * radius
        
        return CGRect(x: newOrigin, y: newOrigin, width: newSize, height: newSize)
    }
}
