//
//  ImagePicker.swift
//  Babilonia
//
//  Created by Denis on 7/5/19.
//  Copyright © 2019 Yalantis. All rights reserved.
//

import UIKit

open class ImagePicker: NSObject {
    
    var sourceType: UIImagePickerController.SourceType = .camera
    private let pickerController = UIImagePickerController()
    private weak var presentationController: UIViewController?
    private let didPickImage: (UIImage?) -> Void
    
    public init(
        presentationController: UIViewController,
        didPickImage: @escaping (UIImage?) -> Void
    ) {
        self.presentationController = presentationController
        self.didPickImage = didPickImage
        
        super.init()
        
        self.pickerController.delegate = self
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.pickerController.modalPresentationStyle = .fullScreen
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(allowsEditing: Bool = true) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return
        }

        self.pickerController.allowsEditing = allowsEditing
        self.pickerController.sourceType = sourceType
        self.pickerController.modalPresentationStyle = .fullScreen
        self.presentationController?.present(self.pickerController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        didPickImage(image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.pickerController(picker, didSelect: image)
            return
        }
        if let image = info[.originalImage] as? UIImage {
            self.pickerController(picker, didSelect: image)
            return
        }
        
        self.pickerController(picker, didSelect: nil)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
