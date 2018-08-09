//
//  RecordVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVC: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, RecordCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordLabel: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var recordings: [Record] = []

    @IBAction func record(_ sender: Any) {
        if audioRecorder == nil {

            let newEntry = self.recordings.count + 1

            let fileName = getDirectory().appendingPathComponent("\(newEntry).m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

            //START Recording

            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()

                self.recordLabel.setTitle("Stop Recording", for: .normal)

            } catch {
                self.displayAlert(title: "Error", message: "Recording failed")
            }

            //STOP recording

        } else {

            audioRecorder.stop()
            audioRecorder = nil

            self.refreshRecordings()

            UserDefaults.standard.set(self.recordings.count, forKey: "myNumber")

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

            recordLabel.setTitle("Record", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()

        self.askMicPermission()
        self.refreshRecordings()

    }

    // MARK: UITableView Datasource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordings.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "nibIdentifier", for: indexPath) as! RecordCell

        cell.delegate = self

        let eachRecord = self.recordings[indexPath.row]
        cell.configure(record: eachRecord)

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
    // MARK: RecordCellDelegate

    func editButtonDidSelect(cell: RecordCell) {
        let nib = UINib(nibName: "EditCellView", bundle: nil)

        let editView = nib.instantiate(withOwner: nil, options: nil).first as! EditCellView

        self.view.addSubview(editView)

        let viewCenter = self.view.center
        let viewSize = CGSize(width: self.view.frame.height/2, height: self.view.frame.height/2)

        editView.frame = CGRect(origin: viewCenter, size: viewSize)
        editView.center = self.view.center

        editView.backgroundColor = UIColor.red

        print("hello")
    }

    func refreshRecordings() {
        var existingRecords: [Record] = []

        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {
            for i in enumerator {
                let audioFile = i as! NSURL
                let filePath = audioFile.path

                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: filePath!) as? NSDictionary
                    if let fileTimeStamp = attr?.fileCreationDate()?.description {
                        let eachRecording = Record(file: audioFile, timestamp: fileTimeStamp)

                        existingRecords.append(eachRecording)
                        self.recordings = existingRecords
                    }

                } catch {
                    print(error.localizedDescription)
                }

            }
        }

    }

    func askMicPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("User grants permission!")
            } else {
                print("ERROR - User does not grant permission")
                return
            }
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
