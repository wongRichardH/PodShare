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
        self.setupTextFields()
    }

    func setupTextFields() {
        self.passwordTextField.isSecureTextEntry = true
        self.loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        self.registerButton.addTarget(self, action: #selector(registerButtonPressed), for: .touchUpInside)

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
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let presenter = AlertPresenter(baseVC: self)
                presenter.showAlert(alertTitle: "Error Creating User", alertMessage: "Reason: \(error.localizedDescription)")
            }
            if let _ = user {
                let presenter = AlertPresenter(baseVC: self)
                presenter.showAlert(alertTitle: "User Created!", alertMessage: "Login to continue")
            }
        }
    }

    func setupTabController() -> UITabBarController{
        let recordVC = RecordVC()
        let friendsVC = FriendsFeedVC()
        let tabBar = UITabBarController()
        tabBar.addChildViewController(friendsVC)
        tabBar.addChildViewController(recordVC)
//        tabBar.addChildViewController(friendsVC)

        return tabBar
    }

    

}
