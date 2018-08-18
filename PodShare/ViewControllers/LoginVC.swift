//
//  LoginVC.swift
//  PodShare
//
//  Created by Richard on 8/13/18.
//  Copyright © 2018 wongRichardH. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    var presenter: AlertPresenter?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    func setup() {
        self.passwordTextField.isSecureTextEntry = true
        self.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        self.registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)

        self.loginButton.backgroundColor = UIColor(red:0.50, green:0.75, blue:0.89, alpha:1.0)
        self.registerButton.backgroundColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.0)


        self.loginButton.setTitleColor(UIColor.white, for: .normal)
        self.registerButton.setTitleColor(UIColor.white, for: .normal)

        self.view.backgroundColor = UIColor(red:0.94, green:0.92, blue:0.84, alpha:0.98)

        self.emailTextField.text = "rwong@gmail.com"
        self.passwordTextField.text = "123123"

    }
    @objc func loginButtonPressed() {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let presenter = AlertPresenter(baseVC: self)
                presenter.showAlert(alertTitle: "Error Signing In", alertMessage: "Reason: \(error.localizedDescription)")
            }
            if let _ = user {
                let tab = self.setupTabController()
                self.present(tab, animated: true, completion: nil)
            }
        }
    }

    @objc func registerButtonPressed() {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""

        if email.isEmpty || password.isEmpty {
            let presenter = AlertPresenter(baseVC: self)
            presenter.showAlert(alertTitle: "Empty Fields", alertMessage: "Reason: Please enter valid username or password")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let presenter = AlertPresenter(baseVC: self)
                presenter.showAlert(alertTitle: "Error Creating User", alertMessage: "Reason: \(error.localizedDescription)")
            }
            if let user = user {
                let encodedEmail = self.encode(email: email)
                let dataRef = Database.database().reference().child("Users").child(encodedEmail)
                dataRef.setValue(["creatorID": user.uid])


                //sets for self. user who creates email creates placeholder friend for themselves
                let friendRef = Database.database().reference().child("Friends").child(encodedEmail)
                friendRef.setValue(["placeholder": true])

                let presenter = AlertPresenter(baseVC: self)
                presenter.showAlert(alertTitle: "User Created!", alertMessage: "Login to continue")
            }
        }
    }

    func setupTabController() -> UITabBarController{
        let recordVC = RecordVC()
        let friendsVC = FriendsFeedVC()
        let tabBar = UITabBarController()
//        tabBar.addChildViewController(friendsVC)
        tabBar.addChildViewController(recordVC)
        tabBar.addChildViewController(friendsVC)

        return tabBar
    }

    

}
