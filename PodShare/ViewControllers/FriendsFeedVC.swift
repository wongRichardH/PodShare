//
//  FriendsFeedVC.swift
//  PodShare
//
//  Created by Richard on 8/7/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit

class FriendsFeedVC: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.title = "Feed"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
