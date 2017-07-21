//
//  EXPhotoHelper.swift
//  Exchange
//
//  Created by Quang Vu on 7/8/17.
//  Copyright © 2017 Quang Vu. All rights reserved.
//

import UIKit
import MobileCoreServices

class EXPhotoHelper: NSObject {
    
    var completionHandler: ((UIImage) -> Void)?
    var selectedImage: UIImage?

    /**
     Present the action sheet
    */
    func presentActionSheet(from viewController: UIViewController){
        // Create an UIAlertController
        let alertController = UIAlertController(title: nil, message: "Post Picture", preferredStyle: .actionSheet)
        // Camera available -> Add photo¡ UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let capturePhotoAction = UIAlertAction(title: "Take a photo", style: .default, handler: { (action) in
                // Display camera
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            alertController.addAction(capturePhotoAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAciton = UIAlertAction(title: "Upload photo", style: .default, handler: { (action) in
                // Display photo library
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            
            alertController.addAction(photoLibraryAciton)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        // Present the options
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Present a image picker controller: Capture photo or Photo library
    */
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController){
        DispatchQueue.main.async(execute: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.mediaTypes = [kUTTypeImage as String]
            imagePickerController.sourceType = sourceType
            // Set the image picker controller delegate to handle the selected image
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            // Present
            viewController.present(imagePickerController, animated: true, completion: nil)
        })
    }
    
    /**
     Resize an image to the new specific size
    */
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension EXPhotoHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let handler = completionHandler else {
            print("No image handler")
            return
        }
        
        // Grab the selected image
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            guard let resizedImage = resizeImage(image: selectedImage, newWidth: 350) else {
                self.selectedImage = selectedImage
                return handler(selectedImage)
            }
            self.selectedImage = resizedImage
            handler(resizedImage)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
