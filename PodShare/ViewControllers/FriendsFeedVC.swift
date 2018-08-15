//
//  FriendsFeedVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class FriendsFeedVC: UIViewController {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var audioPlayer: AVAudioPlayer!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Feed"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchRecordings()
    }

    func setup() {
        self.refreshButton.addTarget(self, action: #selector(fetchRecordings), for: .touchUpInside)
    }

    @objc func fetchRecordings() {
        let storageRef = Storage.storage().reference().child("User_Audio_Files")
        let starsRef = storageRef.child("oi9N830oqfhusL5u71Pzx89VuOE3/").child("Bumps.m4a")

        // Fetch the download URL
        starsRef.downloadURL { url, error in
            if let error = error {
                let alert = AlertPresenter(baseVC: self)
                alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }

            if let url = url {
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, urlResponse, error) in
                    if let error = error {
                        let alert = AlertPresenter(baseVC: self)
                        alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                        return
                    }
                    guard let data = data else { return }
                    self.play(with: data)
                })

                task.resume()

            }
        }
    }

    @objc func fetchRecordings2() {
        let dataRef = Database.database().reference()

    }

    func downloadFileFromURL(url:NSURL) {
        var task: URLSessionDownloadTask

        task = URLSession.shared.downloadTask(with: url as URL, completionHandler: { (url, response, error) in
            print("hello")
            self.play(with: url!)
        })

        task.resume()

    }

    func play(with url: URL) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch {
            let alert = AlertPresenter(baseVC: self)
            alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)        }
    }

    func play(with data: Data) {
        do {
            self.audioPlayer = try AVAudioPlayer(data: data)
            self.audioPlayer.play()

        } catch {
            let alert = AlertPresenter(baseVC: self)
            alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
        }
    }

}
