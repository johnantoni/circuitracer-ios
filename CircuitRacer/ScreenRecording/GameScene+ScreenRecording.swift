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
import UIKit
import ReplayKit

extension GameScene: AutoRecordProtocol, ScreenRecordingAvailable {
  func startScreenRecording() {
    
    // 1
    guard screenRecordingToggleEnabled && screenRecordingAvailable else { return }
    
    // 2
    let sharedRecorder = RPScreenRecorder.sharedRecorder()
    
    sharedRecorder.delegate = self
    
    // 3
    sharedRecorder.startRecordingWithMicrophoneEnabled(true) { error in
      if let error = error {
        self.showScreenRecordingAlert(error.localizedDescription)
      }
    }
  }
  
  func stopScreenRecordingWithHandler(handler: (Void -> Void)) {
    // 1
    let sharedRecorder = RPScreenRecorder.sharedRecorder()
    
    // 2
    sharedRecorder.stopRecordingWithHandler { (previewViewController, error) in
      if let error = error {
        // 3
        self.showScreenRecordingAlert(error.localizedDescription)
        return
      }
      
      if let previewViewController = previewViewController {
        // 4
        previewViewController.previewControllerDelegate = self
        
        self.previewViewController = previewViewController
      }
      // 5
      handler()
    }
  }
  
  func discardRecording() {
    RPScreenRecorder.sharedRecorder().discardRecordingWithHandler {
      self.previewViewController = nil
    }
  }
  
  func displayRecordedContent() {
    guard let previewViewController = previewViewController else { fatalError("The user requested playback, but a valid preview controller does not exist.") }
    guard let rootViewController = view?.window?.rootViewController else { fatalError("The scene must be contained in a window with a root view controller.") }
    
    previewViewController.modalPresentationStyle = .FullScreen
    
    SKTAudio.sharedInstance().pauseBackgroundMusic()
    rootViewController.presentViewController(previewViewController, animated: true, completion:nil)
  }
  
  func showScreenRecordingAlert(message: String) {
    paused = true
    
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
    
    let alertAction = UIAlertAction(title: "OK", style: .Default) { _ in
      self.paused = false
    }
    alertController.addAction(alertAction)
    
    dispatch_async(dispatch_get_main_queue(), {
      self.view?.window?.rootViewController?.presentViewController(alertController, animated: false, completion: nil)
    })
  }
}

extension GameScene: RPScreenRecorderDelegate {
  func screenRecorder(screenRecorder: RPScreenRecorder, didStopRecordingWithError error: NSError, previewViewController: RPPreviewViewController?) {
    if previewViewController != nil {
      self.previewViewController = previewViewController
    }
  }
}

extension GameScene: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(previewController: RPPreviewViewController) {
    previewViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}
