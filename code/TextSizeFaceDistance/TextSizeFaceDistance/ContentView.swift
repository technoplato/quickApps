//
//  ContentView.swift
//  TextSizeFaceDistance
//
//  Created by laptop on 7/16/23.
//

import SwiftUI

import SwiftUI
import ARKit
import Speech

struct ContentView: View {
  @State private var faceDistance: Float = 0
  @State private var previousFaceDistance: Float = 0
  @State private var recognizedText: String = ""
  
  private let audioEngine = AVAudioEngine()
  private let speechRecognizer = SFSpeechRecognizer()
  
  let distanceThreshold: Float = 0.001 // Set a threshold for significant changes
  
  var body: some View {
    VStack {
      ARViewContainer { newFaceDistance in
        // Only update the face distance state if the change is greater than the threshold
        if abs(newFaceDistance - previousFaceDistance) > distanceThreshold {
          faceDistance = newFaceDistance
          previousFaceDistance = newFaceDistance
        }
      }
      .frame(width: 200, height: 200)
      
      Text("Face Distance: \(faceDistance)")
        .font(.system(size: getFontSize()))
      
      Text("Recognized Text: \(recognizedText)")
              
        .font(.system(size: getFontSize()))  

    }        .onAppear(perform: startListening)
    
  }
  
  
   func getFontSize() -> CGFloat {
     
       return CGFloat(abs(faceDistance) * 72)
   }
  
  
  func startListening() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    self.recognizedText = result.bestTranscription.formattedString
                } else if let error = error {
                    print("Recognition failed: \(error)")
                }
            }
        } catch {
            print("Failed to set up speech recognition: \(error)")
        }
    }
}


struct ARViewContainer: UIViewRepresentable {
  var onFaceDistanceChange: (Float) -> Void
  
  func makeUIView(context: Context) -> ARSCNView {
    let arView = ARSCNView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    arView.session.delegate = context.coordinator
    let configuration = ARFaceTrackingConfiguration()
    arView.session.run(configuration, options: [])
    return arView
  }
  
  func updateUIView(_ uiView: ARSCNView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, ARSessionDelegate {
    var parent: ARViewContainer
    
    init(_ parent: ARViewContainer) {
      self.parent = parent
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
      guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
      
      let faceDistance = faceAnchor.transform.columns.3.z
      DispatchQueue.main.async {
        self.parent.onFaceDistanceChange(faceDistance)
      }
    }
  }
}


#Preview {
  ContentView()
}
