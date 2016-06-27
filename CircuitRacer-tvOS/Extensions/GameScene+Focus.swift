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

import Foundation

extension GameScene {
  
  var currentlyFocusableButtons: [ButtonNode] {
    return buttons.filter { !$0.hidden && $0.userInteractionEnabled }
  }
  
  var focussedButton: ButtonNode? {
    get {
      for button in currentlyFocusableButtons where button.isFocused {
        return button
      }
      return nil
    }
    
    set {
      focussedButton?.isFocused = false
      newValue?.isFocused = true
    }
  }
  
  private var buttonIdentifiersOrderedByInitialFocusPriority: [ButtonIdentifier] {
    return [
      .Replay,
      .Resume,
      .Cancel,
      .Pause
    ]
  }
  
  func createButtonFocusGraph() {
    let sortedFocusableButtons = currentlyFocusableButtons.sort { $0.position.y > $1.position.y }
    sortedFocusableButtons.forEach { $0.focusableNeighbors.removeAll() }
    
    for i in 0 ..< sortedFocusableButtons.count - 1 {
      let node = sortedFocusableButtons[i]
      let nextNode = sortedFocusableButtons[i + 1]
      
      node.focusableNeighbors[.Down] = nextNode
      nextNode.focusableNeighbors[.Up] = node
    }
  }
  
  func resetFocus() {
    focussedButton = currentlyFocusableButtons.maxElement { lhsButton, rhsButton in
      let lhsPriority = buttonIdentifiersOrderedByInitialFocusPriority.indexOf(lhsButton.buttonIdentifier)!
      let rhsPriority = buttonIdentifiersOrderedByInitialFocusPriority.indexOf(rhsButton.buttonIdentifier)!
      
      return lhsPriority > rhsPriority
    }
  }
}