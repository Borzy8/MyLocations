//
//  HudView.swift
//  MyLocations
//
//  Created by Borzy on 26.08.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

import Foundation
import UIKit


class HudView: UIView,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var text: NSString = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds);
        hudView.opaque = false;
        
        view.addSubview(hudView);
        view.userInteractionEnabled = false;
        
        
        hudView.show(animated);
        return hudView;
    }
    
    override func drawRect(rect: CGRect) {
        let boxWidth: CGFloat = 96;
        let boxHeight: CGFloat = 96;
        
        let boxRect = CGRect(x:round((bounds.size.width - boxWidth)/2)
            , y: round((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight);
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10);
        UIColor(white: 0.3, alpha: 0.8).setFill();
        roundedRect.fill();
        
        // draw image on hudView
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2)
            
            , y: center.y - round(image.size.height/2) - boxHeight/8);
            image.drawAtPoint(imagePoint);
        }
        
        //draw text
        let attribs = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName : UIColor.whiteColor()]
        let textSize = text.sizeWithAttributes(attribs);
        
        let textPoint = CGPoint(x: center.x - round(textSize.width/2), y: center.y - round(textSize.height/2) + boxHeight/4)
        
        text.drawAtPoint(textPoint, withAttributes: attribs)
        
        
    }
    
    func show(animated: Bool) {
        //1
        if animated {
            alpha = 0;
            transform = CGAffineTransformMakeScale(1.3, 1.3);
        }
        //2
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            
                self.alpha = 1;
                self.transform = CGAffineTransformIdentity;
            
            }, completion: nil);

}
}