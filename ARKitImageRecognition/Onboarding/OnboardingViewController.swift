//
//  OnboardingViewController.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 4/26/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFirebase

class OnboardingViewController: UIViewController, Storyboarded, RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        print("Will present picker")
        present(picker, animated: true, completion: nil)
    }
    
    func dismiss(picker: UIImagePickerController) {
        print("Will dismiss picker")
        dismiss(animated: true, completion: nil)
    }
    
    
    var coordinator:OnboardinCoordinator?
    var picker: RxMediaPicker?

    private var onboardingViewModel: OnboardingViewModel!
    private let disposeBag = DisposeBag()
    var currentUserInfo: OnboardingUserInfo?

    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var dateOfBirthPicker: UIDatePicker!
    @IBOutlet weak var continueButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let currentUserInfo = currentUserInfo else { return }
        onboardingViewModel = OnboardingViewModel(user: currentUserInfo)
        
        FirebaseServices.shared.isUserNameValid(username: "")
        
        getProfileImage()
        profileImageButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        
        firstNameTextField.text = currentUserInfo.firstName
        lastNameTextField.text = currentUserInfo.lastName
        emailTextField.text = currentUserInfo.email
        
        firstNameTextField.rx
            .text
            .orEmpty
            .bind(to: onboardingViewModel.firstNameTextFieldPublishSubject)
            .disposed(by: disposeBag)
        lastNameTextField.rx
            .text
            .orEmpty
            .bind(to: onboardingViewModel.lastNameTextFieldPublishSubject)
            .disposed(by: disposeBag)
        emailTextField.rx
            .text
            .orEmpty
            .bind(to: onboardingViewModel.emailTextFieldPublishSubject)
            .disposed(by: disposeBag)
        usernameTextField.rx
            .text
            .orEmpty
            .bind(to: onboardingViewModel.usernameTextFieldPublishSubject)
            .disposed(by: disposeBag)
        dateOfBirthPicker.rx
            .date
            .bind(to: onboardingViewModel.birthdatePublishSubject)
            .disposed(by: disposeBag)
                
        onboardingViewModel.isValid().bind(to: continueButton.rx.isEnabled).disposed(by: disposeBag)
        onboardingViewModel.isValid().map { $0 ? 1 : 0.1 }.bind(to: continueButton.rx.alpha).disposed(by: disposeBag)
        
        onboardingViewModel.isValid()
            .filter({$0})
            .subscribe(onNext: {
            print("isValid \($0)")
            self.moveDown(duration: 0.3)})
            .disposed(by: disposeBag)

        usernameTextField.rx
            .controlEvent([.editingDidBegin, .editingDidEnd])
            .asObservable()
            .subscribe(onNext: { _ in
                print("editing state changed")
                self.moveDown(duration: 0.3)
            })
            .disposed(by: disposeBag)

        print("user email is \(String(describing: coordinator?.user?.email))")
        
    }
    
    func fade(_ view: UIView, duration: TimeInterval) -> Observable<Void> {
        return Observable.create { (observer) -> Disposable in
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            }, completion: { (_) in
                observer.onNext(())
                observer.onCompleted()
            })
            return Disposables.create()
        }
    }
    
    func moveDown(duration: TimeInterval) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.scrollView.contentOffset.y = CGFloat(self.emailTextField.frame.origin.y - 50)
            }, completion: nil)
        }
    }
    
    @objc func pickPhoto() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Default", style: .default) { (action:UIAlertAction) in
            print("You've pressed default");
        }

        let action2 = UIAlertAction(title: "Photo Library", style: .default) { (action:UIAlertAction) in
            self.picker = RxMediaPicker(delegate: self)
            self.picker?.selectImage(editable: false)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (image, editedImage) in
                    self?.profileImageButton.setBackgroundImage(image.circleMasked, for: .normal)
                    
                }, onError: { error in
                    print("Picker photo error: \(error)")
                }, onCompleted: {
                    print("Completed")
                }, onDisposed: {
                    print("Disposed")
                })
                .disposed(by: self.disposeBag)
        }

        let action3 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed the destructive")
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
            
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func getProfileImage() {
        guard let url = currentUserInfo?.profilePictureURL else { return  }
        URLSession.shared.rx
            .response(request: URLRequest.init(url: url))
            // subscribe on main thread
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                // Update Image
                DispatchQueue.main.sync {
                    let image = UIImage.init(data: data.data)
                    self?.profileImageButton.imageView?.alpha = 0
                    self?.profileImageButton.setBackgroundImage(image?.circleMasked, for: .normal)
                }

            }, onError: { (_) in
                // Log error
            }, onCompleted: {
                // animate image view alpha
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5) { [weak self] in
                        self?.profileImageButton.imageView?.alpha = 1
                    }
                 }
            }).disposed(by: disposeBag)

    }
    
    //TODO: Move THIS LOGIC up to the coordinator
    @IBAction func continueButton(_ sender: Any) {
        //if usernameIsUnique
        FirebaseServices.shared.isUserNameValid(username: usernameTextField.text ?? "")
            .subscribe(onSuccess: { [weak self] isValid in
                guard let self = self else { return }
                if isValid {
                    //set everything in firebase
                    let profileImage = self.profileImageButton.currentBackgroundImage ?? nil
                    FirebaseServices.shared.setProfilePhotoForUser(image: profileImage)
                    FirebaseServices.shared.updateInfoForUser(firstName: self.firstNameTextField.text, lastName: self.lastNameTextField.text, email: self.emailTextField.text, birthDate: self.dateOfBirthPicker.date, userName: self.usernameTextField.text)
                    //continue to home page
                    self.coordinator?.userFinishedSetup()
                } else {
                    //username has been taken before
                    self.alert(title: "Error", message: "That username is taken, please try another one")
                    .subscribe()
                    .disposed(by: self.disposeBag)
                    
                }
            }).disposed(by: disposeBag)
        

        
    }
}




