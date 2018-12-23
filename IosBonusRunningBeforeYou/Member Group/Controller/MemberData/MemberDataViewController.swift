//
//  MemberDataViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MemberDataViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var memberDataView: UIView!
    @IBOutlet weak var userPhoto: UIImageView!
    
    let communicator = Communicator.shared
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhoto.layer.cornerRadius = userPhoto.frame.size.height / 2
        userPhoto.layer.masksToBounds = true
        userPhoto.layer.borderWidth = 0.3
        userPhoto.layer.borderColor = UIColor.black.cgColor
        
        memberDataView.buttomBorder(width: 1, borderColor: UIColor.lightGray)
        getImage(userPhoto, userDefaults.string(forKey: "email")!)

    }
    
    func getImage(_ image: UIImageView,_ email: String) {
        
        communicator.getImage(url: communicator.UserServlet_URL, email: email, imageSize: 270) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            print("userPhoto: \(data)")
            self.userPhoto.image = UIImage(data: data)
            print("userPhoto set success.")
            
        }
        
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        
        let imageData = image.jpegData(compressionQuality: 100)!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        userPhoto.image = image
        dismiss(animated: true) {
            self.view.showToast(text: "圖片更新成功")
        }
        
        
        guard let selectedImage = userPhoto.image else {
            print("Image not found!")
            return
        }
        
        let imageBase64 =  convertImageToBase64(image: selectedImage)
        communicator.updatePhoto(email: userDefaults.string(forKey: "email")!, imageBase64: imageBase64) { (result, error) in
            print("updateResult = \(String(describing: result))")
            
            if let error = error {
                print("Update userPhoto error:\(error)")
                return
            }
            
            if (result as! Int == 0) {
                return
            }
            
        }
        
    }
    
    @IBAction func changePhotoBtnPressed(_ sender: UIButton) {
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        
        imagePickerVC.modalPresentationStyle = .popover
        let popover = imagePickerVC.popoverPresentationController
        
        popover?.sourceView = sender
        
        popover?.sourceRect = sender.bounds
        popover?.permittedArrowDirections = .any
        
        show(imagePickerVC, sender: self)
        
        
        
    }
    
}

extension UIView {
    
    private func drawBorder(rect:CGRect,color:UIColor){
        let line = UIBezierPath(rect: rect)
        let lineShape = CAShapeLayer()
        lineShape.path = line.cgPath
        lineShape.fillColor = color.cgColor
        self.layer.addSublayer(lineShape)
    }
    
    //設置右邊框
    public func rightBorder(width:CGFloat,borderColor:UIColor) {
        let rect = CGRect(x: 0, y: self.frame.size.width - width, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: borderColor)
    }
    //設置左邊框
    public func leftBorder(width:CGFloat,borderColor:UIColor) {
        let rect = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        drawBorder(rect: rect, color: borderColor)
    }
    
    //設置上邊框
    public func topBorder(width:CGFloat,borderColor:UIColor) {
        let rect = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: borderColor)
    }
    
    
    //設置底邊框
    public func buttomBorder(width:CGFloat,borderColor:UIColor) {
        let rect = CGRect(x: 0, y: self.frame.size.height-width, width: self.frame.size.width, height: width)
        drawBorder(rect: rect, color: borderColor)
    }
}

extension Communicator {
    
    func updatePhoto(email: String, imageBase64: String, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "updatePhoto", "email": email, "imageBase64": imageBase64]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
    
    
}
