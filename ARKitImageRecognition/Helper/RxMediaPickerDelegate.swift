import UIKit
import RxSwift

extension RxMediaPickerDelegate where Self: UIViewController {
    
    func presentPicker(picker: UIImagePickerController) {
        self.present(picker, animated: true, completion: nil)
    }
    
    func dismissPicker(picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
