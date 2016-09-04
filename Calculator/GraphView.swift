//
//  GraphView.swift
//  Calculator
//
//  Created by Talha Baig on 7/8/16.
//  Copyright © 2016 Talha Baig. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 50 { didSet{ setNeedsDisplay() } } //related to contentScaleFactor
    @IBInspectable
    var origin =  CGPoint(x: 0 ,y: 0) { didSet { setNeedsDisplay() } }
    @IBInspectable
    var axesColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    var graphingFunction: (CGFloat -> CGFloat)? = nil
    var originIsSet = false
    var translation = CGPointZero //for the pan thing
    
    func pan(recognizer: UIPanGestureRecognizer){
        switch recognizer.state {
        case .Changed, .Ended:
            translation = recognizer.translationInView(self)
            origin = CGPoint(x: origin.x + translation.x, y: origin.y + translation.y) //find an alternative
            recognizer.setTranslation(CGPointZero, inView: self)
        default:
            break
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer){
        switch recognizer.state {
        case .Changed, .Ended:
            pointsPerUnit *=  recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    func tap(recognizer: UITapGestureRecognizer){
        recognizer.numberOfTapsRequired = 2
        switch recognizer.state {
        case .Ended:
            origin = recognizer.locationInView(self)
        default:
            break
        }
    }
    override func drawRect(rect: CGRect) {
        
        //have to write a conditional here so that if it is changed do not reset it
        
        if !originIsSet{
            origin.x = bounds.midX
            origin.y = bounds.midY
            originIsSet = true
        }

        var firstPoint = true
        let path = UIBezierPath()
        if graphingFunction != nil {
            var index = bounds.minX
            while index < bounds.maxX {
                let cartesianX = convertXCoordinateToCartesian(index)
                let cartesianY = graphingFunction!(cartesianX)
                if cartesianY.isNaN {
                    index += 1
                    continue
                }
                let boundsY = convertYCoordinateToBounds(cartesianY)
                let plottedPoint = CGPoint(x: index, y: boundsY)
                if firstPoint{
                    firstPoint = false
                    path.moveToPoint(plottedPoint)
                }
                else{
                    path.addLineToPoint(plottedPoint)
                }
                index += 1

            }
        }
        UIColor.redColor().set()
        path.stroke()
        //this is done
        let axesDrawer = AxesDrawer()
        axesDrawer.drawAxesInRect (bounds, origin: origin, pointsPerUnit: CGFloat(pointsPerUnit))

    }
    
    private func convertXCoordinateToCartesian(xCoordinateInBounds: CGFloat) -> CGFloat{
        let nonScaledReturnMe = xCoordinateInBounds - origin.x
        return nonScaledReturnMe / pointsPerUnit
    }
    
    private func convertYCoordinateToBounds(yCoordinateInCartesian: CGFloat) -> CGFloat{
        let nonTranslatedReturnMe = yCoordinateInCartesian * pointsPerUnit
        return origin.y - nonTranslatedReturnMe
    }
    
    
}
