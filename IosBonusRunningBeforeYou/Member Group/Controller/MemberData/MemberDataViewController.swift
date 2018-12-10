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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPhoto.layer.cornerRadius = userPhoto.frame.size.height / 2
        userPhoto.layer.masksToBounds = true
        userPhoto.layer.borderWidth = 0.3
        userPhoto.layer.borderColor = UIColor.black.cgColor
        
        memberDataView.buttomBorder(width: 1, borderColor: UIColor.lightGray)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        userPhoto.image = image
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePhotoBtnPressed(_ sender: UIButton) {
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
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
