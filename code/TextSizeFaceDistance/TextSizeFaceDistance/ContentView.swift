//
//  ContentView.swift
//  TextSizeFaceDistance
//
//  Created by laptop on 7/16/23.
//

import SwiftUI

import SwiftUI
import ARKit

struct ContentView: View {
  @State private var faceDistance: Float = 0
  @State private var previousFaceDistance: Float = 0
  
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
      .frame(width: 100, height: 100)
      
      Text("Face Distance: \(faceDistance)")
        .font(.system(size: CGFloat(abs(faceDistance) * 100)))  // Multiply by 100 to convert from meters to something more suitable for a font size
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
