//
//  OnboardingViewModel.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 6/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxSwift


class OnboardingViewModel {
    let firstNameTextFieldPublishSubject = PublishSubject<String>()
    let lastNameTextFieldPublishSubject = PublishSubject<String>()
    let emailTextFieldPublishSubject = PublishSubject<String>()
    let usernameTextFieldPublishSubject = PublishSubject<String>()
    let birthdatePublishSubject = PublishSubject<Date>()
    
    var user: OnboardingUserInfo
        
    let disposeBag = DisposeBag()
    
    init(user: OnboardingUserInfo) {
        self.user = user
    }
    
    func isValid() -> Observable<Bool> {
        return Observable
            .combineLatest(
                firstNameTextFieldPublishSubject.asObservable().startWith(user.firstName ?? ""),
                lastNameTextFieldPublishSubject.asObservable().startWith(user.lastName ?? ""),
                emailTextFieldPublishSubject.asObservable().startWith(user.email ?? ""),
                usernameTextFieldPublishSubject.asObservable().startWith(""))
            .map { firstName, lastName, email, username in
                return firstName.count > 2 && lastName.count > 2 && email.isValidEmail() && username.count > 3
            }
            .startWith(false)
    }

}
