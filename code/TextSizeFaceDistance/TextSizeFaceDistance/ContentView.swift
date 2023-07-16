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

struct RecordedAudio : Identifiable, Codable {
    let id: UUID
    let fileURL: URL
    let transcription: String
    let segments: [Segment]  // new property
}

struct Segment: Codable {
    let substring: String
    let timestamp: TimeInterval
    let duration: TimeInterval
}

struct ContentView: View {
  @State private var faceDistance: Float = 0
  @State private var previousFaceDistance: Float = 0
  
  @ObservedObject var recorderAndPlayer = RecorderAndPlayer()
  
  @State private var recognizedText: String = ""
  @State private var baseFontSize: Float = 72
  
  private let audioEngine = AVAudioEngine()
  private let speechRecognizer = SFSpeechRecognizer()
  
  let distanceThreshold: Float = 0.01 // Set a threshold for significant changes
  let ss = ["one", "two"]
  
  
  @ViewBuilder
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
      
      if recorderAndPlayer.isRecording {
        Button("Stop Recording", action: recorderAndPlayer.stopListeningAndSave)
      } else {
        Button("Start Recording", action: recorderAndPlayer.startListening)
      }
      
      List(recorderAndPlayer.recordedAudios, id: \.id) { recording in
        HStack {
          Button("Play", action: {
            recorderAndPlayer.playRecording(recording)

          })
          Text(recording.transcription.prefix(30))
        }
      }
      
      
      Spacer()
      
      Text(recorderAndPlayer.highlightedWord)
          .font(.headline)
          .foregroundColor(.red)
      
      ScrollViewReader { proxy in
          ScrollView {
              recorderAndPlayer.transcriptWithHighlightedWord
                  .font(.system(size: getFontSize()))
                  .id("end")
                  .onChange(of: recognizedText) { newValue in
                      // Process the new recognized text
                      processRecognizedText(newValue)

                      proxy.scrollTo("end", anchor: .bottom)
                  }.padding()
          }
      }
      
    }        .onAppear(perform: recorderAndPlayer.startListening)
    
  }
  
  func processRecognizedText(_ text: String) {
    let last = text.lowercased().split(separator: " ").last
    let words = [last]
    
    if words.contains("bigger") || words.contains("increase") {
      baseFontSize += 10
    } else if words.contains("smaller") || words.contains("decrease") {
      baseFontSize -= 10
    }
  }
  
  
  func getFontSize() -> CGFloat {
    
    return CGFloat(abs(faceDistance) * baseFontSize)
  }
}


class RecorderAndPlayer: ObservableObject {
  private var audioEngine = AVAudioEngine()
  private var speechRecognizer = SFSpeechRecognizer()
  private var audioFile: AVAudioFile?
  private var audioPlayer: AVAudioPlayer?
  private let recordedAudiosKey = "recordedAudios"

  
  @Published var recognizedText: String = ""
  @Published var recordedAudios: [RecordedAudio] = []
  @Published var recognizedSegments: [Segment] = []
  @Published var highlightedWord: String = ""
  private var wordHighlightTimer: Timer?
//  private var handleSegmentTappped: (Segment) -> Void
  
  var isRecording: Bool {
    audioEngine.isRunning
  }
  
  var transcriptWithHighlightedWord: Text {
      var text = Text("")

      for segment in recognizedSegments {
          if segment.substring == highlightedWord {
            text = text + Text(segment.substring).foregroundColor(.red)
              
//              .onTapGesture {
//              handleSegmentTapped(segment)
//            }
            
            + Text(" ")
          } else {
              text = text + Text(segment.substring) + Text(" ")
          }
      }

      return text
  }
  
  init() {
        loadRecordedAudios()
    }
  
  func startListening() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      
      let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
      
      let inputNode = audioEngine.inputNode
      
      // Prepare the audio file
      let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

      let fileUrl = documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        print("Starting recording to file: \(fileUrl)")
        audioFile = try AVAudioFile(forWriting: fileUrl, settings: inputNode.outputFormat(forBus: 0).settings)
      
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
        recognitionRequest.append(buffer)
        
        // Write buffer data to the audio file on a background queue
        DispatchQueue.global(qos: .userInitiated).async {
          do {
            try self?.audioFile?.write(from: buffer)
          } catch {
            print("Failed to write buffer to file: \(error)")
          }
        }
      }
      
      audioEngine.prepare()
      try audioEngine.start()
      
      speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
          if let result = result {
              let segments = result.bestTranscription.segments.map {
                  Segment(substring: $0.substring, timestamp: $0.timestamp, duration: $0.duration)
              }
              self?.recognizedText = result.bestTranscription.formattedString
              self?.recognizedSegments = segments
          } else if let error = error {
              print("Recognition failed: \(error)")
          }
      }
    } catch {
      print("Failed to set up speech recognition: \(error)")
    }
  }
  
  func stopListening() -> RecordedAudio {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    
    let recordedAudio = RecordedAudio(
      id: UUID(),
      fileURL: audioFile!.url,
      transcription: recognizedText,
      segments: recognizedSegments
    )
    
    recognizedText = ""
    print("Finished recording to file: \(audioFile!.url)")

    return recordedAudio
  }
  

  func stopListeningAndSave() {
      let recordedAudio = stopListening()
      recordedAudios.append(recordedAudio)
      print("Saving recording: \(recordedAudio)")
      saveRecordedAudios()
  }
  
  private func saveRecordedAudios() {
      let recordedAudiosData = try? JSONEncoder().encode(recordedAudios)
      UserDefaults.standard.set(recordedAudiosData, forKey: recordedAudiosKey)
      print("Saved recordings to UserDefaults")
  }

  private func loadRecordedAudios() {
      guard let recordedAudiosData = UserDefaults.standard.data(forKey: recordedAudiosKey),
            let recordedAudios = try? JSONDecoder().decode([RecordedAudio].self, from: recordedAudiosData) else {
          return
      }
      self.recordedAudios = recordedAudios
      print("Loaded recordings from UserDefaults: \(recordedAudios)")

  }
  
  
  func playRecording(_ recording: RecordedAudio) {
      do {
          print("Playing recording from file: \(recording.fileURL)")
          audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
          audioPlayer?.play()
          
          // Clear any existing timer
          wordHighlightTimer?.invalidate()
          
          // Start a new timer
          wordHighlightTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
              let currentTime = self?.audioPlayer?.currentTime ?? 0
              let currentWord = recording.segments.first { segment in
                  currentTime >= segment.timestamp && currentTime <= segment.timestamp + segment.duration
              }?.substring
              self?.highlightedWord = currentWord ?? ""
          }
      } catch {
          print("Failed to play audio file: \(error)")
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
