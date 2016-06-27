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

import SpriteKit

protocol ButtonNodeResponder {
  func buttonPressed(button: ButtonNode)
}

enum ButtonIdentifier: String {
  case Resume = "resume"
  case Cancel = "cancel"
  case Replay = "replay"
  case Pause  = "pause"
  case ScreenRecordingToggle = "screen_recording_toggle"
  case ViewRecordedContent = "view_recorded_content"
  
  static let allIdentifiers: [ButtonIdentifier] =
  [.Resume, .Cancel, .Replay, .Pause,
    .ScreenRecordingToggle, .ViewRecordedContent]
  
  var selectedTextureName: String? {
    switch self {
      case .ScreenRecordingToggle:
        return "btn_autorecord_small_on"
      default:
        return nil
    }
  }
  
  var focusedTextureName: String? {
    switch self {
      case .Replay:
        return "button_green_focussed"
      case .Cancel:
        return "button_red_focussed"
      default:
        return nil
    }
  }
}

class ButtonNode: SKSpriteNode {
  
  var defaultTexture: SKTexture?
  var selectedTexture: SKTexture?
  var focusedTexture: SKTexture?
  
  var focusableNeighbors = [ControlInputDirection: ButtonNode]()
  
  var buttonIdentifier: ButtonIdentifier!
  
  var responder: ButtonNodeResponder {
    guard let responder = scene as? ButtonNodeResponder else {
      fatalError("ButtonNode may only be used within a 'ButtonNodeResponder' scene")
    }
    return responder
  }
  
  var isHighlighted = false {
    didSet {
      colorBlendFactor = isHighlighted ? 1.0 : 0.0
    }
  }
  
  var isSelected = false {
    didSet {
      texture = isSelected ? selectedTexture : defaultTexture
    }
  }
  
  var isFocused = false {
    didSet {
      if isFocused {
        scaleAsPoint = CGPoint(x: 1.08, y: 1.08)
      } else {
        scaleAsPoint = CGPoint(x: 1, y: 1)
      }
      texture = isFocused ? focusedTexture : defaultTexture
      
      if let label = childNodeWithName("label") as? SKLabelNode {
        label.fontColor = isFocused ? SKColor.blackColor() : SKColor.whiteColor()
      }
    }
  }
  
  init(templateNode: SKSpriteNode) {
    super.init(texture: templateNode.texture, color: SKColor.clearColor(), size: templateNode.size)
    
    guard let nodeName = templateNode.name, buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
      fatalError("Unsupported button name found")
    }
    
    self.buttonIdentifier = buttonIdentifier
    
    name = templateNode.name
    position = templateNode.position
    
    //zPosition
    
    color = SKColor(white: 0.8, alpha: 1.0)
    
    defaultTexture = texture
    
    if let textureName = buttonIdentifier.selectedTextureName {
      selectedTexture = SKTexture(imageNamed: textureName)
    } else {
      selectedTexture = texture
    }
    
    if let focusedTextureName = buttonIdentifier.focusedTextureName {
      focusedTexture = SKTexture(imageNamed: focusedTextureName)
    } else {
      focusedTexture = texture
    }
    
    for child in templateNode.children {
      addChild(child.copy() as! SKNode)
    }
    
    userInteractionEnabled = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func buttonTriggered() {
    if userInteractionEnabled {
      responder.buttonPressed(self)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    if hasTouchWithinButton(touches) {
      isHighlighted = true
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    
    isHighlighted = false
    
    if hasTouchWithinButton(touches) {
      responder.buttonPressed(self)
    }
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    super.touchesCancelled(touches, withEvent: event)
    
    isHighlighted = false
  }
  
  func hasTouchWithinButton(touches: Set<UITouch>) -> Bool {
    guard let scene = scene else {fatalError("Button must be used within a scene")}
    
    let touchesInButton = touches.filter { touch in
      let touchPoint = touch.locationInNode(scene)
      let touchedNode = scene.nodeAtPoint(touchPoint)
      return touchedNode === self || touchedNode.inParentHierarchy(self)
    }
    return !touchesInButton.isEmpty
  }
  
  // MARK: Convenience
  static func parseButtonInNode(containerNode: SKNode) {
    for identifier in ButtonIdentifier.allIdentifiers {
      
      guard let templateNode = containerNode.childNodeWithName(identifier.rawValue) as? SKSpriteNode else { continue}
      
      let buttonNode = ButtonNode(templateNode: templateNode)
      buttonNode.zPosition = templateNode.zPosition
      
      containerNode.addChild(buttonNode)
      templateNode.removeFromParent()
    }
  }
}
