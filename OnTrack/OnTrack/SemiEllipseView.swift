//
//  SemiEllipseView.swift
//  OnTrack
//
//  Created by Daren David Taylor on 08/12/2015.
//  Copyright © 2015 LondonSwift. All rights reserved.
//

import UIKit


@IBDesignable
class SemiEllipseView: UIView {
    

    
    
    @IBInspectable var color: UIColor = UIColor.redColor()
    
    @IBInspectable var position: Int = 0
    
    override func drawRect(rect: CGRect) {
        
       // let context = UIGraphicsGetCurrentContext()
        
     //   CGContextSetFillColorWithColor( context, UIColor.clearColor().CGColor );
     //   CGContextFillRect( context, rect );
        
        
       // self.clearsContextBeforeDrawing = true
        var offsetRect = rect
        
      //
        offsetRect.size.height = rect.size.height * 2
        
        
        if position == 1 {
            offsetRect.origin.y = -rect.size.height
            
        
        }
        
        self.color.setFill()
        UIBezierPath(ovalInRect: offsetRect).fill()
        
        
    }
 
}
