//
//  ChatRoomViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import Starscream
import UserNotifications
import Photos
import MobileCoreServices

class ChatRoomViewController: UIViewController, WebSocketDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var inputTextField: UITextField!
    let communicator = Communicator.shared
    var userInfo = [GoFriendItem]()
    var chatData = ChatData()
    var email = "123@gamil.com"
    let userDefault = UserDefaults.standard
    var socket:WebSocket!
    var firstView = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // userDefault
        email = userDefault.string(forKey: "email")!
        //Ask user's permission to access photo library.
        PHPhotoLibrary.requestAuthorization { (status) in
            print("PHPhotoLibrary.requestAuthorization: \(status.rawValue)")
        }
        // Do any additional setup after loading the view.
        getAll()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHight), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let groupId = userInfo.first?.groupId else{
            return
        }
        
        socketConnect(emailAccount: email, groupId:groupId )
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        socket.disconnect()
//    }
    @IBAction func sendPhoto(_ sender: UIButton) {
        let alert = UIAlertController(title: "Please choose source", message: nil, preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            //..
            self.launchPicker(source: .camera)
        }
        let library = UIAlertAction(title: "Photo library", style: .default) { (action) in
            //...
            self.launchPicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert,animated: true)
    }
    func launchPicker(source:UIImagePickerController.SourceType)  {
        //Check if the source is valid or not? 檢查user使用的來源是否合法
        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            print("Invalid source type")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.mediaTypes = ["public.image", "public.movie"] //user 可以選擇照片或影片
        //上面跟下面是一樣的不同寫法 下面要import MobileCoreServices
        picker.mediaTypes = [kUTTypeImage, kUTTypeMovie] as [String]
        picker.sourceType = source
        picker.allowsEditing = true //可以讓user裁切照片只能正方形,影片也能
        
        present(picker, animated: true)
    }
    
    //MARK: - UIImagePickerControllerDelegate Protocol Methods.
    func imagePickerController(_ picker :UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("info:\(info)")
        guard let type = info[.mediaType] as? String else {
            assertionFailure("Invalid type")
            return
        }
        if type == (kUTTypeImage as String) {
            guard let originalImage = info[.originalImage] as? UIImage else {
                assertionFailure("originalImage is nil")
                return
            }
            let resizedImage = originalImage.resize(maxEdge: 1024)!
            let jpgData = resizedImage.jpegData(compressionQuality: 0.8)
            //            let pngDate = resizedImage.pngData()
            print("jpgData:\(jpgData!.count)")
            //            print("pngData:\(pngDate!.count)")
            
            let base64Date = jpgData?.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
            let base64String = String(data: base64Date!, encoding: .utf8)!
            
            let chatMessage = ChatMessage.init(sender: email, receiver: (userInfo.first?.groupId)!, message: base64String, messageType: "image")
            let chatMessageData = try! JSONEncoder().encode(chatMessage)
            let chatMessageString = String(data: chatMessageData, encoding: .utf8)!
            socket.write(string: chatMessageString)
            let emailAccount = self.mailFilter(email)
            let text = "\(emailAccount ?? ""): "
            let image = UIImage(data: jpgData!)
            
            let chatItem = ChatItem(text:  text, image: image, senderType: .fromMe)
            chatView.add(chatItem: chatItem)
            
            
        }else if type == (kUTTypeMovie as String) {
            
        }
        picker.dismiss(animated: true) //Important!!! 點選照片後 收起視窗
    }
    
    @IBAction func sentMessage(_ sender: UIButton) {
        chatData.message = inputTextField.text
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        let stringTime = dateFormatter.string(from: now)
        chatData.lastUpdateDateTime = stringTime
        chatData.emailAccount = email
        chatData.groupId = userInfo.first?.groupId
        print("\(inputTextField.text), \(chatData)")
        
        let chatMessage = ChatMessage.init(sender: email, receiver:(userInfo.first?.groupId)! , message: inputTextField.text , messageType: "text")
        let chatMessageData = try! JSONEncoder().encode(chatMessage)
        let chatMessageString = String(data: chatMessageData, encoding: .utf8)!
        socket.write(string: chatMessageString)
        
         let emailAccount = self.mailFilter(email)
        let text = "\(emailAccount ?? ""): \(inputTextField.text ?? "") \(stringTime ?? "")"
        
        let chatItem = ChatItem(text:  text, image: nil, senderType: .fromMe)
        chatView.add(chatItem: chatItem)
        
        communicator.insertNewMessage(chatItem: chatData) { (result, error) in
            if let error = error {
                print("insertNewMessage error \(error)")
            }
            guard let result = result as? Int else{
                return
            }
            print("result = \(result)")
            
        }
        
        inputTextField.text = ""
    }
    
    func getAll(){
        communicator.getMessages(groupId:(userInfo.first?.groupId)!) { (result, error) in
            if let error = error{
                print("get messages error \(error)")
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get all  OK")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([ChatData].self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }

                for chatItem in resultObject {
                    let emailAccount = self.mailFilter(chatItem.emailAccount!)
                    let text = "\(emailAccount ?? ""): \(chatItem.message ?? "") \(chatItem.lastUpdateDateTime ?? "")"
                    //判斷這則訊息是自己還是其他人
                    let type: ChatSenderType = (chatItem.emailAccount == self.email ? .fromMe : .fromOthers)
                    let chatItem = ChatItem(text: text , image: nil, senderType: type)
                    self.chatView.add(chatItem: chatItem)

                }
        }
    }
    func mailFilter(_ input :String) -> String {
        
        var newStr = String()
        if input.contains("@gamil.com"){
            newStr = input.replacingOccurrences(of: "@gamil.com", with: "")
            print("replacingOccurrences:\(newStr)")
            return newStr
        } else {
            newStr = input.replacingOccurrences(of: "@gmail.com", with: "")
            print("replacingOccurrences:\(newStr)")
            return newStr
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func socketConnect(emailAccount:String, groupId:Int){
        socket = WebSocket(url: URL(string: communicator.SOCKET_URL+emailAccount + "/" + "\(groupId)")!)
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket isConnect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocket Disconnect ")
        print("websocket Disconnect error:\(error), socket:\(socket)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocket ReceiveMessage text = \(text)")
       
        let decoder = JSONDecoder()
        let jsonData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        let message = try! decoder.decode(ChatMessage.self, from: jsonData)
        guard message.sender != email else {
            return
        }
        if message.messageType == "text"{
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        let stringTime = dateFormatter.string(from: now)
            let emailAccount = self.mailFilter(message.sender!)
        let text = "\(emailAccount ?? ""): \(message.message ?? "") \(stringTime ?? "")"
        let chatItem = ChatItem(text:  text, image: nil, senderType: .fromOthers)
        chatView.add(chatItem: chatItem)
//        notice(message: message.message ?? "")
        }else{
            
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocket ReceiveData data = \(data.count)")
        let decoder = JSONDecoder()
        guard let resultObject = try? decoder.decode(ChatMessage.self, from: data) else {
            return
        }
        guard resultObject.sender != email else {
            return
        }
        print("\(resultObject)")
        let emailAccount = self.mailFilter(resultObject.sender!)
        let textDetail = "\(emailAccount): "
        let type: ChatSenderType = .fromOthers
        let base64String = resultObject.message
        
        guard let decodeData = Data(base64Encoded: base64String!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
            assertionFailure("decode Fail")
            return
        }
        let image = UIImage(data: decodeData)
        var chatItem = ChatItem(text: textDetail, image: nil, senderType: type)
        chatItem.image = image
        chatView.add(chatItem: chatItem)
    }
    
    func notice(message:String){
        let emailAccount = self.mailFilter(email)
        let content = UNMutableNotificationContent()
        content.title = "\(emailAccount)"
        content.subtitle = "\(message)"
        content.badge = 1
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notice", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if let error = error {
                print("UNUserNotificationCenter error:\(error)")
                return
            }
            print("成功建立通知...")
        })
    }
}
extension ChatRoomViewController {
    //彈出鍵盤時提高畫面
    @objc
    func keyboardHight(_ notification:Notification){
        let info = notification.userInfo
        let kbRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.1) {
            print("\(offsetY)")
            if offsetY == 0 {
                self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }else{
                self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
            }
        }
    }
}

extension Communicator{
    
    func insertNewMessage(chatItem:ChatData, completion:@escaping DoneHandler){
        let newChatData = try! JSONEncoder().encode(chatItem)
        let newChatString = String(data: newChatData, encoding: .utf8)
        let parameters:[String:Any] = [ACTION_KEY : "insertNewMessage", "chatItem": newChatString as Any]
        doPost(urlString: ChatServlet_URL, parameters: parameters, completion:completion)
    }
    
    func getMessages(groupId:Int, completion:@escaping DoneHandler){
        
        let parameters:[String:Any] = [ACTION_KEY : "getMessages", "groupId": groupId as Any]
        doPost(urlString: ChatServlet_URL, parameters: parameters, completion:completion)
    }
    
}
