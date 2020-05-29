//
//  LoginViewController.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 3/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI
import FBSDKLoginKit

class LoginViewController: UIViewController, Storyboarded, FUIAuthDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    weak var coordinator: LoginCoordinator?
    
    var authUI = FUIAuth.defaultAuthUI()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.view.overrideUserInterfaceStyle = .light
        }
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        let providers: [FUIAuthProvider] = [
          FUIFacebookAuth(),
        ]
        self.authUI?.providers = providers
        
        //self.present(authUI?.authViewController() ?? nil, animated: true, completion: nil)
        
        //fb


    }

    @IBAction func signIn(_ sender: Any) {
        guard let text = emailTextField.text, let password = passwordTextField.text else { return }

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://www.beeback.io")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().createUser(withEmail: text, password: password) { authResult, error in
            if let error = error {
                //self.showMessagePrompt(error.localizedDescription)
                print(error.localizedDescription)
                return
            }
            print("the auth result is \(String(describing: authResult))")
            UserDefaults.standard.set(text, forKey: "Email")
            self.coordinator?.userSignedIn(withUserInfo: OnboardingUserInfo(email:text))
        }

    

    }
    
    
    @IBAction func facebookSignIn(_ sender: Any) {
        // 1
          let loginManager = LoginManager()
          
          if let _ = AccessToken.current {
              // Access token available -- user already logged in
              // Perform log out
              
              // 2
              loginManager.logOut()
              
          } else {
              // Access token not available -- user already logged out
              // Perform log in
              
              // 3
              loginManager.logIn(permissions: ["email"], from: self) { [weak self] (result, error) in
                  
                  // 4
                  // Check for error
                  guard error == nil else {
                      // Error occurred
                      print(error!.localizedDescription)
                      return
                  }
                  
                  // 5
                  // Check for cancel
                  guard let result = result, !result.isCancelled else {
                      print("User cancelled login")
                      return
                  }
                
                // 6
                // get user info and pass along to next page
                guard let accessToken = FBSDKLoginKit.AccessToken.current else { return }
                let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                              parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                              tokenString: accessToken.tokenString,
                                                              version: nil,
                                                              httpMethod: .get)
                graphRequest.start { (connection, result, error) -> Void in
                    if error == nil {
                        
                        print("result \(result)")
                        let dict = result as? Dictionary ?? [:]
                        let email = dict["email"] as? String ?? ""
                        let firstName = dict["first_name"] as? String ?? ""
                        let lastName = dict["last_name"] as? String ?? ""
                        let profilePictureURL = ((dict["picture"] as? Dictionary ?? [:])["data"] as? Dictionary ?? [:])["url"] as? String ?? ""
                        print(profilePictureURL)
                        let userInfo = OnboardingUserInfo(firstName: firstName, lastName: lastName, email: email, birthdate: Date(), profilePictureURL: URL(string: profilePictureURL)!)
                        
                        // No error, No cancelling:
                        // using the FBAccessToken, we get a Firebase token
                        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)

                        // using the credentials above, sign in to firebase to create a user session
                        Auth.auth().signIn(with: credential) { (user, error) in
                            print("User logged in the firebase")
                            }
                        
                    // Successfully logged in
                    // 7
                    //self?.updateButton(isLoggedIn: true)
                        self?.coordinator?.userSignedIn(withUserInfo: userInfo)
                        
                    }
                    else {
                        print("error \(error)")
                    }
                }

                  // 7
                  //Profile.loadCurrentProfile { (profile, error) in
                  //    self?.updateMessage(with: Profile.current?.name)
                  //}
              }
          }
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField || textField == passwordTextField {
            animateViewMoving(true, moveValue: 180)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField || textField == passwordTextField {
            animateViewMoving(false, moveValue: 180)
        }
    }
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)

        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)

        self.loginView.frame = self.loginView.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

}
