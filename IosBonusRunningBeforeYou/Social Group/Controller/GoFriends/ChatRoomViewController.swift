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
class ChatRoomViewController: UIViewController,WebSocketDelegate,UITextFieldDelegate {
    
    
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        socket.disconnect()
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
        
        let chatMessage = ChatMessage.init(sender: email, receiver:(userInfo.first?.groupId)! , message: inputTextField.text)
        let chatMessageData = try! JSONEncoder().encode(chatMessage)
        let chatMessageString = String(data: chatMessageData, encoding: .utf8)!
        socket.write(string: chatMessageString)
        
        let text = "\(email ?? ""): \(inputTextField.text ?? "") \(stringTime ?? "")"
        
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
//            if self.firstView == 0{
                for chatItem in resultObject {
                    let text = "\(chatItem.emailAccount ?? ""): \(chatItem.message ?? "") \(chatItem.lastUpdateDateTime ?? "")"
                    //判斷這則訊息是自己還是其他人
                    let type: ChatSenderType = (chatItem.emailAccount == self.email ? .fromMe : .fromOthers)
                    let chatItem = ChatItem(text: text , image: nil, senderType: type)
                    self.chatView.add(chatItem: chatItem)

                }
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
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
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocket ReceiveMessage text = \(text)")
        let decoder = JSONDecoder()
        let jsonData = text.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        let message = try! decoder.decode(ChatMessage.self, from: jsonData)
        guard message.sender != email else {
            return
        }
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        let stringTime = dateFormatter.string(from: now)
        let text = "\(message.sender ?? ""): \(message.message ?? "") \(stringTime ?? "")"
        let chatItem = ChatItem(text:  text, image: nil, senderType: .fromOthers)
        chatView.add(chatItem: chatItem)
//        notice(message: message.message ?? "")
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocket ReceiveData data = \(data.count)")
    }
    
    func notice(message:String){
        let content = UNMutableNotificationContent()
        content.title = "\(email)"
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
extension UIViewController {
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
