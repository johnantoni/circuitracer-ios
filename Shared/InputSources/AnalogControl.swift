/*
* Copyright (c) 2015-2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class AnalogControl: UIView {
  
  let baseCenter: CGPoint
  
  let knobImageView: UIImageView
  let baseImageView: UIImageView
  
  var knobImageName: String = "knob" {
    didSet {
      knobImageView.image = UIImage(named: knobImageName)
    }
  }
  
  var baseImageName: String = "base" {
    didSet {
      baseImageView.image = UIImage(named: baseImageName)
    }
  }
  
  var delegate: InputControlProtocol?
  
  override init(frame: CGRect) {
    
    baseCenter = CGPoint(x: frame.size.width/2,
      y: frame.size.height/2)
    
    knobImageView = UIImageView(image:  UIImage(named: knobImageName))
    knobImageView.frame.size.width /= 2
    knobImageView.frame.size.height /= 2
    knobImageView.center = baseCenter
    
    baseImageView = UIImageView(image: UIImage(named: baseImageName))
    
    super.init(frame: frame)
    
    userInteractionEnabled = true
    
    baseImageView.frame = bounds
    addSubview(baseImageView)
    
    addSubview(knobImageView)
    
    assert(CGRectContainsRect(bounds, knobImageView.bounds),
      "Analog control should be larger than the knob in size")
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  func updateKnobWithPosition(position:CGPoint) {

    var positionToCenter = position - baseCenter
    var direction: CGPoint
    
    if positionToCenter == CGPointZero {
      direction = CGPointZero
    } else {
      direction = positionToCenter.normalized()
    }
    

    let radius = frame.size.width/2
    var length = positionToCenter.length()
    

    if length > radius {
      length = radius
      positionToCenter = direction * radius
    }
    
    let relPosition = CGPoint(x: direction.x * (length/radius),
      y: direction.y * (length/radius) * -1)
    
    knobImageView.center = baseCenter + positionToCenter
    delegate?.directionChangedWithMagnitude(relPosition)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if let touch = touches.first {
      let touchLocation = touch.locationInView(self)
      updateKnobWithPosition(touchLocation)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if let touch = touches.first {
      let touchLocation = touch.locationInView(self)
      updateKnobWithPosition(touchLocation)
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    updateKnobWithPosition(baseCenter)
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    updateKnobWithPosition(baseCenter)
  }
}
