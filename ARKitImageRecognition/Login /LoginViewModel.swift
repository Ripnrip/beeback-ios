//
//  LoginViewModel.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 6/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxSwift

class LoginViewModel {
    let emailTextFieldPublishSubject = PublishSubject<String>()
    let passwordTextFieldPublishSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    func isValid() -> Observable<Bool> {
        return Observable
            .combineLatest(
                emailTextFieldPublishSubject.asObservable().startWith(""),
                passwordTextFieldPublishSubject.asObservable().startWith(""))
            .map({ email, password  in
                return !email.isValidEmail()
            })
            .startWith(false)
    }

}
