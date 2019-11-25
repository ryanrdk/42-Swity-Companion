//
//  LoginViewController.swift
//  rush00
//
//  Created by teo KELESTURA on 2019/10/12.
//  Copyright © 2019 teo KELESTURA. All rights reserved.
//

import UIKit
class AlertHelper {
//    ALERT_MESSAGE
    func showAlert(fromController controller: UIViewController, messages: String) {
        let alert = UIAlertController(title: "Error", message: messages, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}

class LoginViewController: UIViewController {

//    IMAGES
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!

//    STACKVIEW
    @IBOutlet weak var stackView: UIStackView!

//    TEXT_FIELD
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!

//    LOGIN_BUTTON
    @IBOutlet weak var loginButton: UIButton!
    let client = Client()
    let conn:APIConnection = APIConnection()
    @IBAction func loginButtonPress(_ sender: Any) {
        let loadIcon = loadingIconStart()
        if usernameTextField.text! != "" && passwdTextField.text! != "" {
            //BEGIN LOGIN PROCESS
            loginUser(input: usernameTextField.text!)
            sleep(2)
            if (client.userFirstName != "") {
                self.loadLoggedInScreen()
            }
            else {
                let alert = AlertHelper()
                alert.showAlert(fromController: self, messages: "Invalid Login or Password.")
            }
        }
        else {
            let alert = AlertHelper()
            alert.showAlert(fromController: self, messages: "Empty Fields")
        }
        loadingIconStop(activityIndicator: loadIcon)
    }

//LOGIN USER, GET TOKEN, GET USER DATA
    func loginUser(input: String) {
        if input == "" {
            print("No username entered")
            return
        }
        else {
           print("User is \(input)")
        }

        //get token
        conn.genTok{ (token) in
            print("Token is \(token)")
            //user requests in here with token
            self.client.getUserInfo(token: token, username: "\(input)") { firstName,lastName,login,photo,userLevel, cursusNames,cursusLevels  in
                print("User found with Firstname: \(firstName), Lastname: \(lastName), Login: \(login) Photo: \(photo) Userlevel: \(userLevel), CursusNames: \(cursusNames), CursusLevels: \(cursusLevels)")
            }
        }
    }

//    View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.text = ""
        passwdTextField.text = ""
//        if UIDevice.current.orientation.isLandscape {}
    }

//    Hides Navbar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

//    Loads Icon
    func loadingIconStart () -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.color = UIColor.white
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        return activityIndicator
    }

//    Stops Icon Load
    func loadingIconStop(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
    }

//    Loads Logged In Screen
    func loadLoggedInScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loggedInViewController = storyBoard.instantiateViewController(withIdentifier: "LoggedInViewController") as! LoggedInViewController
        loggedInViewController.clientlogged = client
        loggedInViewController.connection = conn
        self.navigationController?.pushViewController(loggedInViewController, animated: true)
//        self.present(loggedInViewController, animated: true, completion: nil)
    }
}
