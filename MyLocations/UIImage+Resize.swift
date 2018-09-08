//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Borzy on 02.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        let verticalRatio = bounds.height / size.height;
        let horizontalRatio = bounds.width / size.width;
        let ratio = min(verticalRatio, horizontalRatio);
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio);
        let sizeForAspectFill = CGSize(width: bounds.width, height: bounds.height);
        
        // If you want Aspect Fit mode, just insert newSize in parameters below
        UIGraphicsBeginImageContextWithOptions(sizeForAspectFill, true, 0);
        drawInRect(CGRect(origin: CGPoint.zero, size: sizeForAspectFill));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
}
