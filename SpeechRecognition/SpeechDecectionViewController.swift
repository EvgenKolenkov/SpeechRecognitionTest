//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Evgeniy Kolenkov on 9/19/18.
//  Copyright © 2018 Evgeniy Kolenkov. All rights reserved.
//

import UIKit
import Speech

class SpeechDecectionViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestSpeechAuthorization()
        startButton.backgroundColor = UIColor.gray
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if !audioEngine.isRunning {
            self.recordAndRecognizeSpeech()
            startButton.backgroundColor = UIColor.red
        } else {
            audioEngine.stop();
            request.endAudio();
            audioEngine.inputNode.removeTap(onBus: 0);
            startButton.backgroundColor = UIColor.gray
        }
    }
    
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try self.audioEngine.start()
        } catch {
            return print(error)
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {
            result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                
                var lastString: String.SubSequence = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString[indexTo...]
                }
                self.checkForColorSaid(resultString: String(lastString))
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authstatus in
            OperationQueue.main.addOperation {
                switch authstatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    func checkForColorSaid(resultString: String) {
        switch resultString {
        case "red": colorView.backgroundColor = UIColor.red
        case "blue": colorView.backgroundColor = UIColor.blue
        case "green": colorView.backgroundColor = UIColor.green
        case "black": colorView.backgroundColor = UIColor.black
        default: break
        }
    }
}


