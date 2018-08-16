//
//  RecordVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class RecordVC: UIViewController, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, RecordCellDelegate, EditCellViewDelegate, DeleteCellViewDelegate, UploadAudioViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordLabel: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordings: [Record] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.askMicPermission()
        self.refreshRecordings()
    }

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
                self.recordLabel.setImage(#imageLiteral(resourceName: "stop"), for: .normal)
            } catch {
                let alert = AlertPresenter(baseVC: self)
                alert.showAlert(alertTitle: "Error Recording", alertMessage: "Reason: \(error.localizedDescription)")
            }
            //STOP Recording
        } else {
            audioRecorder.stop()
            audioRecorder = nil
            self.refreshRecordings()
            UserDefaults.standard.set(self.recordings.count, forKey: "myNumber")
            self.recordLabel.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        cell.titleLabel.text = eachRecord.name
        return cell
    }

    // MARK: UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cellAtIndexPath = self.tableView.cellForRow(at: indexPath) as! RecordCell
        let cellName = cellAtIndexPath.titleLabel.text ?? ""
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
        let nib = UINib(nibName: "EditCellView", bundle: nil)
        let editView = nib.instantiate(withOwner: nil, options: nil).first as! EditCellView
        editView.delegate = self
        self.addViewAndSetFrame(with: editView)

        let editCellIndexPath = self.tableView.indexPath(for: cell)
        editView.cellIndexPath = editCellIndexPath
        editView.textField.text = cell.titleLabel.text

    }

    // MARK: EditCellViewDelegate
    func renameButtonDidSelect(text: String, indexPath: IndexPath) {

        let cell = self.tableView.cellForRow(at: indexPath) as! RecordCell
        let currentName = cell.titleLabel.text ?? ""

        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let originPath = documentDirectory.appendingPathComponent("\(currentName).m4a")
            let destinationPath = documentDirectory.appendingPathComponent("\(text).m4a")
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        }
        catch {
            print("error trying to name file")
        }

        cell.titleLabel.text = text
        self.refreshRecordings()

    }

    // MARK: deleteButtonDidSelectDelegate
    func deleteButtonDidSelect(cell: RecordCell) {

        let nib = UINib(nibName: "DeleteCellView", bundle: nil)
        let deleteView = nib.instantiate(withOwner: nil, options: nil).first as! DeleteCellView
        deleteView.delegate = self

        if let cellTitleName = cell.titleLabel.text {
            deleteView.warningLabel.text = "Delete \(cellTitleName)?"
        }
        self.addViewAndSetFrame(with: deleteView)

        deleteView.cellName = cell.titleLabel.text
    }

    // MARK: DeleteCellViewDelegate
    func deleteAudioDidSelected(cell: DeleteCellView, cellName: String) {

        let cellName = cell.cellName ?? ""

        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {

            for file in enumerator {
                let audioFileURL = file as! NSURL
                let filePath = audioFileURL.path ?? ""

                do {
                    let nsStringPath = filePath as NSString
                    let fileName = String(nsStringPath.lastPathComponent.split(separator: ".")[0])
                    if cellName == fileName {
                        try FileManager.default.removeItem(atPath: filePath)
                    }
                } catch {
                    print(error)
                }
            }
        }
        self.refreshRecordings()

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: shareButtonDidSelectDelegate
    func shareButtonDidSelect(cell: RecordCell) {
        cell.delegate = self
        let nib = UINib(nibName: "UploadAudioView", bundle: nil)
        let uploadView = nib.instantiate(withOwner: nil, options: nil).first as! UploadAudioView
        uploadView.delegate = self

        if let cellTitleName = cell.titleLabel.text {
            uploadView.warningMessageLabel.text = "Upload \(cellTitleName)?"
        }

        self.addViewAndSetFrame(with: uploadView)
        uploadView.cell = cell
    }

    // MARK: uploadAudioViewDidSelectedDelegate
    func uploadAudioDidSelected(cell: RecordCell) {
        
        guard let currentUser = Auth.auth().currentUser else { return }
        guard let filePath = cell.fileURL?.path else { return }

        let userEmail = currentUser.email ?? ""
        let encodedEmail = self.encode(email: userEmail)
        let alert = AlertPresenter(baseVC: self)
        let fileName = cell.titleLabel.text ?? ""
        let localFile = URL(fileURLWithPath: filePath)

//        let userRef = Database.database().reference().child("Users").child("\(encodedEmail)")
//        userRef.setValue(["creatorID": currentUser.uid])

        let fileRef = Storage.storage().reference().child("User_Audio_Files").child("\(encodedEmail)").child("\(fileName).m4a")

        let _ = fileRef.putFile(from: localFile, metadata: nil) { (metadata, error) in
            if let error = error {
                alert.showAlert(alertTitle: "Error Uploading", alertMessage: error.localizedDescription)
            }
            if let _ = metadata {
                alert.showAlert(alertTitle: "Success", alertMessage: "Uploaded to friends!")
            }
        }
        
    }

    func refreshRecordings() {
        var existingRecords: [Record] = []

        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {

            for file in enumerator {
                let audioFileURL = file as! NSURL
                guard let filePath = audioFileURL.path else {return}

                do {
                    let attr = try FileManager.default.attributesOfItem(atPath: filePath) as? NSDictionary
                    
                    if let fileTimeStamp = attr?.fileCreationDate()?.description {
                        let nsStringPath = filePath as NSString
                        let lastComponent = nsStringPath.lastPathComponent.split(separator: ".")
                        let fileName = String(nsStringPath.lastPathComponent.split(separator: ".")[0])

                        if lastComponent[0] != "DS_Store" {
                            let eachRecord = Record(name: fileName, timestamp: fileTimeStamp, fileURL: audioFileURL)
                            existingRecords.append(eachRecord)
                        }
                    }
                } catch {
                    print(error)
                }
            }
            self.recordings = existingRecords
        }
    }

    func setup() {
        self.tabBarItem.title = "Record"
        self.tableView.dataSource = self
        self.tableView.delegate = self

        let recordNib = UINib(nibName: "RecordCell", bundle: nil)
        self.tableView.register(recordNib, forCellReuseIdentifier: "nibIdentifier")
    }

    func printDirectoryNames() {
        if let enumerator = FileManager.default.enumerator(at: getDirectory(), includingPropertiesForKeys: nil) {

            for file in enumerator {
                let audioFileURL = file as! NSURL
                let filePath = audioFileURL.path

                do {
                    let nsStringPath = filePath! as NSString
                    let fileName = String(nsStringPath.lastPathComponent.split(separator: ".")[0])
                    print(fileName)
                }
            }
        }
    }

    func askMicPermission() {
        recordingSession = AVAudioSession.sharedInstance()
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if !hasPermission {
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

    func addViewAndSetFrame(with view: UIView) {
        self.view.addSubview(view)
        let viewCenter = self.view.center
        let viewSize = CGSize(width: view.frame.width, height: view.frame.height)
        view.frame = CGRect(origin: viewCenter, size: viewSize)
        view.center = self.view.center
    }
}
