//
//  LoginViewController.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 3/28/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import AVFoundation
import UIKit
import FirebaseAuth
import FirebaseUI
import FBSDKLoginKit
import RxUIAlert
import RxSwift
import SwiftyGif

class LoginViewController: UIViewController, Storyboarded, FUIAuthDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var emailValidationImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    weak var coordinator: LoginCoordinator?
    
    private var loginViewModel: LoginViewModel!
    private let disposeBag = DisposeBag()
    
    var authUI = FUIAuth.defaultAuthUI()
    var bombSoundEffect: AVAudioPlayer?


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
        
        loginViewModel = LoginViewModel()
        
//        emailTextField.rx
//            .text
//            .orEmpty
//            .bind(to: loginViewModel.emailTextFieldPublishSubject)
//            .disposed(by: disposeBag)
//        passwordTextField.rx
//            .text
//            .orEmpty
//            .bind(to: loginViewModel.passwordTextFieldPublishSubject)
//            .disposed(by: disposeBag)
//
//        loginViewModel.isValid().bind(to: emailValidationImageView.rx.isHidden).disposed(by: disposeBag)
//
//        Observable
//            .combineLatest(emailTextField.rx.controlEvent([.editingDidBegin]).asObservable(), passwordTextField.rx.controlEvent([.editingDidBegin]).asObservable()).subscribe { _ in
//                self.animateViewMoving(true, moveValue: 180)
//        }.disposed(by: disposeBag)
//
//        Observable
//            .combineLatest(emailTextField.rx.controlEvent([.editingDidEnd]).asObservable(), passwordTextField.rx.controlEvent([.editingDidEnd]).asObservable()).subscribe { _ in
//                self.animateViewMoving(false, moveValue: 180)
//        }.disposed(by: disposeBag)
//
//        Observable
//            .combineLatest(emailTextField.rx.controlEvent([.editingDidEndOnExit]).asObservable(), passwordTextField.rx.controlEvent([.editingDidEndOnExit]).asObservable()).subscribe { _ in
//                self.view.endEditing(true)
//        }.disposed(by: disposeBag)
        
        let path = Bundle.main.path(forResource: "loginBackground.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.play()
        } catch {
            // couldn't load file :(
        }
        
        //background gif
        let gif = try! UIImage(gifName: "futuristicRetroBackground.gif")
        self.backgroundImageView.setGifImage(gif, loopCount: -1) // Will loop forever

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.facebookLoginButton.alpha = 0
        self.facebookLoginButton.frame = CGRect.init(x: 45, y: 1430, width: 325, height: 50)


        UIView.animate(withDuration: 3.9) {
            self.facebookLoginButton.alpha = 1
            self.facebookLoginButton.frame = CGRect.init(x: 45, y: self.view.frame.height - self.view.frame.height * 0.20, width: 325, height: 50)
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
                self.alert(title: "Error",
                message: error.localizedDescription)
                .subscribe()
                .disposed(by: self.disposeBag)
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
                guard let self = self else { return }
                  
                  // 4
                  // Check for error
                  guard error == nil else {
                      // Error occurred
                      print(error!.localizedDescription)
                      self.alert(title: "Error", message: error?.localizedDescription)
                      .subscribe()
                      .disposed(by: self.disposeBag)
                      return
                  }
                  
                  // 5
                  // Check for cancel
                  guard let result = result, !result.isCancelled else {
                      print("User cancelled login")
                    self.alert(title: "Error", message: "User cancelled login")
                    .subscribe()
                    .disposed(by: self.disposeBag)
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
                        self.coordinator?.userSignedIn(withUserInfo: userInfo)
                        
                    }
                    else {
                        print("error \(error)")
                        self.alert(title: "Error", message: error?.localizedDescription)
                        .subscribe()
                        .disposed(by: self.disposeBag)
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
