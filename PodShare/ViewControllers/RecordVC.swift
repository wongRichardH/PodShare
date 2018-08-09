//
//  RecordVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVC: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordLabel: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var numOfRecords: Int = 0

    var recordings: [Record] = []

    @IBAction func record(_ sender: Any) {
        if audioRecorder == nil {

            numOfRecords += 1

            let fileName = getDirectory().appendingPathComponent("\(numOfRecords).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

            //Start Recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()

                self.recordLabel.setTitle("Stop Recording", for: .normal)

            } catch {
                self.displayAlert(title: "Error", message: "Recording failed")
            }
        } else {
            //Stop recording
            audioRecorder.stop()
            audioRecorder = nil

            UserDefaults.standard.set(self.numOfRecords, forKey: "myNumber")
            UserDefaults.standard.set(self.recordings, forKey: "myRecordings")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            recordLabel.setTitle("Record", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()


        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("User grants permission!")
            } else {
                print("ERROR - User does not grant permission")
                return
            }
        }


//        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {
//            for i in enumerator {
//                let audioFile = i as! NSURL
//                self.recordings.append(audioFile)
//            }
//        }

        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {
            for i in enumerator {
                let audioFile = i as! NSURL

                let filePath = audioFile.path

                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: filePath!) as? NSDictionary
                    if let fileTimeStamp = attr?.fileCreationDate()?.description {
                        let eachRecording = Record(file: audioFile, timestamp: fileTimeStamp)
                        self.recordings.append(eachRecording)
                    }

                } catch {
                    print(error.localizedDescription)
                }

            }
        }

        for i in self.recordings {
            print(i.file)
            print(i.timestamp)
        }


        //When we make a new recording, use existing numRecords

        if let number: Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            self.numOfRecords = number
        }

    }

    // MARK: UITableView Datasource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfRecords

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "nibIdentifier", for: indexPath) as! RecordCell

        cell.titleLabel.text = String(indexPath.row + 1)

        return cell
    }

    // MARK: UITableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()

        } catch {
            print(error.localizedDescription)
        }

    }

    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }





    func setup() {
        self.tabBarItem.title = "Record"
        self.tableView.dataSource = self
        self.tableView.delegate = self

        let recordNib = UINib(nibName: "RecordCell", bundle: nil)
        self.tableView.register(recordNib, forCellReuseIdentifier: "nibIdentifier")
    }

    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


}
