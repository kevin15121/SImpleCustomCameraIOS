//
//  UIImageExtension.swift
//  AuthMe
//
//  Created by zencher on 2021/6/30.
//

import Foundation
import UIKit

extension UIImage {

    public func correctlyOrientedImage() -> UIImage? {
        if self.imageOrientation == .up{
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage:UIImage? = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return normalizedImage;
    }
}
