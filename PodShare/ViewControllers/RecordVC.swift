//
//  RecordVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import AVFoundation

class RecordVC: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, RecordCellDelegate, EditCellViewDelegate{

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
        } else {
            //STOP recording

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

        let cellAtIndexPath = self.tableView.cellForRow(at: indexPath) as! RecordCell
        let cellName = cellAtIndexPath.titleLabel.text ?? ""
        print(cellName)

//        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")

        let path = getDirectory().appendingPathComponent("\(cellName).m4a")

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    // MARK: RecordCellDelegate

    func editButtonDidSelect(cell: RecordCell) {
        //View setup
        let nib = UINib(nibName: "EditCellView", bundle: nil)
        let editView = nib.instantiate(withOwner: nil, options: nil).first as! EditCellView

        editView.delegate = self

        self.view.addSubview(editView)
        let viewCenter = self.view.center
        let viewSize = CGSize(width: editView.frame.width, height: editView.frame.height)
        editView.frame = CGRect(origin: viewCenter, size: viewSize)
        editView.center = self.view.center


        //need to pass indexPath
        let editCellIndexPath = self.tableView.indexPath(for: cell)
        editView.cellIndexPath = editCellIndexPath

    }

    // MARK: EditCellView Delegate
    func renameButtonDidSelect(text: String, indexPath: IndexPath) {
        let view = EditCellView()
        view.delegate = self

        let cell = self.tableView.cellForRow(at: indexPath) as! RecordCell
        cell.titleLabel.text = text

        //Get name of cell from within Userdefaults to supply textField with default string value
        let currentName = cell.titleLabel.text ?? ""
        //Grab name from userdefault
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let originPath = documentDirectory.appendingPathComponent("\(currentName).m4a")
            let destinationPath = documentDirectory.appendingPathComponent("\(text).m4a")
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error.localizedDescription)
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }


        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {
            for i in enumerator {
                let audioFile = i as! NSURL
                let filePath = audioFile.path

                print(audioFile.relativePath ?? "")
            }
        }

    }


    func refreshRecordings() {
        var existingRecords: [Record] = []

        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {
            for i in enumerator {
                let audioFile = i as! NSURL
                let filePath = audioFile.path

                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: filePath!) as? NSDictionary
                    
                    print(audioFile.relativePath ?? "")

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
