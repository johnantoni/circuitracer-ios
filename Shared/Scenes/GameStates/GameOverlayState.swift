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
import GameplayKit

class GameOverlayState: GKState {
  
  unowned let gameScene: GameScene
  
  var overlay: SceneOverlay!
  var overlaySceneFileName: String { fatalError("Unimplemented overlaySceneName") }
  
  init(gameScene: GameScene) {
    self.gameScene = gameScene
    super.init()
    
    overlay = SceneOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: 2)
    
    ButtonNode.parseButtonInNode(overlay.contentNode)
  }
  
//  override func didEnterWithPreviousState(previousState: GKState?) {
//    super.didEnterWithPreviousState(previousState)
//    gameScene.paused = true
//    gameScene.overlay = overlay
//    
//    #if os(iOS)
//    buttonWithIdentifier(.ScreenRecordingToggle)?.hidden = !gameScene.screenRecordingAvailable
//    buttonWithIdentifier(.ViewRecordedContent)?.hidden = !gameScene.screenRecordingAvailable
//    #endif
//  }

  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(previousState)
    gameScene.paused = true
    gameScene.overlay = overlay
    
    #if os(iOS)
    // 1
    buttonWithIdentifier(.ScreenRecordingToggle)?.isSelected = gameScene.screenRecordingToggleEnabled
    buttonWithIdentifier(.ScreenRecordingToggle)?.hidden = !gameScene.screenRecordingAvailable
    
    // 2
    if self is GameSuccessState || self is GameFailureState {
      if let viewRecordedContentButton = buttonWithIdentifier(.ViewRecordedContent) {
        // 3
        viewRecordedContentButton.hidden = true
        
        // 4
        gameScene.stopScreenRecordingWithHandler {
          let recordingEnabledAndPreviewAvailable = self.gameScene.screenRecordingToggleEnabled && self.gameScene.previewViewController != nil
          
          // 5
          if self.gameScene.levelType == .Easy {
            viewRecordedContentButton.texture = SKTexture(imageNamed: "level_1_preview_frame")
          } else if self.gameScene.levelType == .Medium {
            viewRecordedContentButton.texture = SKTexture(imageNamed: "level_2_preview_frame")
          } else {
            viewRecordedContentButton.texture = SKTexture(imageNamed: "level_3_preview_frame")
          }
          // 6
          viewRecordedContentButton.hidden = !recordingEnabledAndPreviewAvailable
        }
      }
    }
    #endif
  }
  
  override func willExitWithNextState(nextState: GKState) {
    super.willExitWithNextState(nextState)
    gameScene.paused = false
    gameScene.overlay = nil
  }
  
  func buttonWithIdentifier(identifier: ButtonIdentifier) -> ButtonNode? {
    return overlay.contentNode.childNodeWithName("//\(identifier.rawValue)") as? ButtonNode
  }
}
