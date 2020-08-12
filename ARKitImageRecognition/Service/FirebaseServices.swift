//
//  FirebaseServices.swift
//  ARKitImageRecognition
//
//  Created by Gurinder Singh on 5/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import RxFirebase
import FirebaseStorage
import FirebaseAuth
import RxSwift
import FirebaseDatabase

class FirebaseServices{
    static let shared = FirebaseServices()
    let ref = Storage.storage().reference(forURL: "gs://beeback-1dede.appspot.com")
    let profileRef =  Storage.storage().reference(forURL: "gs://beeback-1dede.appspot.com").child("profile").child(Auth.auth().currentUser?.uid ?? "")
    let dbRef = Database.database().reference().child("users")
    let disposeBag = DisposeBag()
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    
    func profileImageforCurrentUser() -> Single<UIImage> {
        guard let currentUser = Auth.auth().currentUser?.uid else {
            return Single.just(UIImage())
        }
        let storageProfileRef = ref.child("profile").child(currentUser)
        
        return Single<UIImage>.create { observer in
        return storageProfileRef.rx.getData(maxSize: 15 * 1024 * 1024)
            .subscribe(onNext: { data in
                observer(.success(UIImage.init(data: data)!))
            })
        }
    }
    
    func setProfilePhotoForUser(image: UIImage?){
        guard let image = image else { return }
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        let storageProfileRef = ref.child("profile").child(currentUser)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        let data = image.pngData()!
        storageProfileRef.rx.putData(data, metadata: metadata).subscribe(onNext: { _ in
            print("upload success")
            }).disposed(by: disposeBag)
    }
    
    func updateInfoForUser(firstName: String?, lastName: String?, email: String?, birthDate: Date?, userName: String?) {
        guard let currentUser = Auth.auth().currentUser?.uid,
            let email = email, let firstName = firstName, let lastName = lastName, let birthDate = birthDate, let userName = userName
        else { return }
        dbRef.child(currentUser).updateChildValues(["email": email, "firstName":firstName, "lastName":lastName,"birthDate":birthDate.description,"userName":userName])
    }
    
    func isUserNameValid(username: String) -> Single<Bool> {
        return Single<Bool>.create { observer in
            return self.dbRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onSuccess: { snapshot in
                //print("Value:\(String(describing: snapshot.value))")
                let values = snapshot.value as? NSDictionary
                var usernames:[String] = []
                values?.allValues.forEach({ (value) in
                    guard let dict = value as? NSDictionary,
                     let username = dict["userName"] as? String
                        else {
                            observer(.error(NSError.init(domain: "Couldn't parse the dict or username", code: 0, userInfo: nil)))
                            return
                    }
                    print(username)
                    usernames.append(username)
                })
                observer(.success(!usernames.contains(username)))
            })
        }
    }
    
    
}
