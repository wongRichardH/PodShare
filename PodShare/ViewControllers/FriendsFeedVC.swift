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

class FriendsFeedVC: UIViewController, UITableViewDataSource, UITableViewDelegate, AddFriendViewDelegate {

    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!

    var audioPlayer: AVAudioPlayer!
    var friendsList: [String] = []
    var feedRecordings: [FeedRecording] = []

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Feed"
        self.tabBarItem.image = #imageLiteral(resourceName: "text-align-right-7")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.fetchFriendsList()
    }

    func setup() {
        self.refreshButton.addTarget(self, action: #selector(fetchRecordings), for: .touchUpInside)
        self.addButton.addTarget(self, action: #selector(addFriendButtonPressed), for: .touchUpInside)
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self

        let nib = UINib(nibName: "LeftPostCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "LeftPostCellIdentifier")
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedRecordings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "LeftPostCellIdentifier", for: indexPath) as! LeftPostCell
        let eachFeedRecording = self.feedRecordings[indexPath.row]
        cell.configure(with: eachFeedRecording)

        return cell
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! LeftPostCell
        let cellURL = cell.fileURL ?? ""

        self.playFile(with: cellURL)
    }

    @objc func fetchRecordings() {
        let dataRef = Database.database().reference().child("FileMetaData")

        for friendEmail in self.friendsList {
            //observe from database now

            dataRef.child(friendEmail).observe(.value) { (snapshot) in
                if let file = snapshot.value as? [String: Any] {
                    var fetchedRecordings: [FeedRecording] = []

                    for (_, val) in file {
                        if let fileContents = val as? [String: String] {

                            var feedCreatorName = ""
                            var feedRecordName = ""
                            var feedTimeCreated = ""
                            var feedFileURL = ""

                            if let creatorName = fileContents["creator"] {
                                feedCreatorName = creatorName
                            }
                            if let fileName = fileContents["fileName"] {
                                feedRecordName = fileName
                            }
                            if let timeCreated = fileContents["timeCreated"] {
                                feedTimeCreated = timeCreated
                            }
                            if let fileURL = fileContents["fileURL"] {
                                feedFileURL = fileURL
                            }

                            let eachFeedRecording = FeedRecording(creatorName: feedCreatorName, recordName: feedRecordName, timeCreated: feedTimeCreated, fileURL: feedFileURL)

                            fetchedRecordings.append(eachFeedRecording)
                        }
                    }
                    self.feedRecordings = fetchedRecordings

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    func fetchFriendsList() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let currentUserEmail = currentUser.email ?? ""
        let encodedCurrentUserEmail = self.encode(email: currentUserEmail)

        let _ = Database.database().reference().child("Friends").child(encodedCurrentUserEmail).observe(.value) { (snapshot) in
            if let friendsDict = snapshot.value as? [String:Bool] {

                for (key, val) in friendsDict {
                    if key != "placeholder" && val == true {
                        self.friendsList.append(key)
                    }
                }
            }
        }
    }


    //MARK: AddFriendDelegate
    @objc func addFriendButtonPressed() {
        let nib = UINib(nibName: "AddFriendView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! AddFriendView
        view.delegate = self

        self.addViewAndSetFrame(with: view)

    }

    func confirmFriendDidSelected(email: String) {
        guard let currentUser = Auth.auth().currentUser else { return }

        let currentUserEmail = currentUser.email ?? ""
        let encodedFriendEmail = self.encode(email: email)

        if currentUserEmail == email {
            let alert = AlertPresenter(baseVC: self)
            alert.showAlert(alertTitle: "Error", alertMessage: "Can not add yourself to be your own friend")
            return
        }

        let dataRef = Database.database().reference().child("Users")
        dataRef.observe(.value) { (snapshot) in
            if let usersDict = snapshot.value as? [String: [String: Any]] {

                //See if user's email is in database
                if let _ = usersDict[encodedFriendEmail] {
                    let currentUserEncodedEmail = self.encode(email: currentUserEmail)
                    let dataRef = Database.database().reference().child("Friends").child(currentUserEncodedEmail)

                    dataRef.updateChildValues([encodedFriendEmail: true], withCompletionBlock: { (error, databaseReference) in
                        let alert = AlertPresenter(baseVC: self)
                        alert.showAlert(alertTitle: "Success", alertMessage: "Friend Added!")
                    })

                } else {
                    let alert = AlertPresenter(baseVC: self)
                    alert.showAlert(alertTitle: "Error", alertMessage: "Can not find email in database")
                }
            }
        }
    }

    func play(with url: URL) {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        } catch {
            let alert = AlertPresenter(baseVC: self)
            alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
        }
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

    func playFile(with url: String) {
        var task: URLSessionDownloadTask
        let fileURL = URL(string: url)

        task = URLSession.shared.downloadTask(with: fileURL!, completionHandler: { (url, response, error) in
            if let error = error {
                let alert = AlertPresenter(baseVC: self)
                alert.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                return
            }
            if let url = url {
                self.play(with: url)
            }
        })
        task.resume()
    }

    func downloadFileFromURL(url: URL) {
        var task: URLSessionDownloadTask

        task = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            self.play(with: url!)
        })
        task.resume()
    }

    func addViewAndSetFrame(with view: UIView) {
        self.view.addSubview(view)
        let viewCenter = self.view.center
        let viewSize = CGSize(width: view.frame.width, height: view.frame.height)
        view.frame = CGRect(origin: viewCenter, size: viewSize)
        view.center = self.view.center
    }
}
