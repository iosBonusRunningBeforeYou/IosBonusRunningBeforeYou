//
//  GoFriendsViewController.swift
//
//
//  Created by Apple on 2018/11/19.
//  Copyright © 2018 Apple. All rights reserved.
//
// @Justin

import UIKit
import SVProgressHUD
import Starscream

class GoFriendsViewController: UIViewController,WebSocketDelegate {
   
    
    
    @IBOutlet weak var goFriendsTVC: UITableView!
    @IBOutlet weak var goFriendCV: UICollectionView!
    let communicator = Communicator.shared
    var email = "Lisa@gmail.com"
    var userJoinGroupId: [Int] = []
    var groupItems = [GoFriendItem]()
    var userJoinGroup = [GoFriendItem]()
    let tag = "goFriendViewController"
    var isfromCreatNewGroup = false
    var indexPathForCV:Int?
    let userDefault = UserDefaults.standard
    var socket:WebSocket!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        goFriendsTVC.dataSource = self
        goFriendsTVC.delegate = self
        goFriendCV.dataSource = self
        goFriendCV.delegate = self
         email = userDefault.string(forKey: "email")!
        //接收頁面的廣播通知
        NotificationCenter.default.addObserver(self, selector: #selector(GoFriendsViewController.reloadDatas(notification:)), name: Notification.Name(rawValue: "creatGroupOk"), object: nil)
    }
    
    //通知方法
    @objc
    func reloadDatas(notification: Notification) {
        //        showAlert(title: "reloadData", message: "")
//        SVProgressHUD.show()
        let chatMessage = ChatMessage.init(sender: nil, receiver:nil , message: nil, messageType: "goFriends")
        let chatMessageData = try! JSONEncoder().encode(chatMessage)
        let chatMessageString = String(data: chatMessageData, encoding: .utf8)!
        socket.write(string: chatMessageString)
//        showJoinGroup()
//        showGroup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "currentPageChanged"), object: 1)
       socketConnectGoFriends(emailAccount:email)
        if isfromCreatNewGroup {
            
        }else{
            showJoinGroup()
            showGroup()
            SVProgressHUD.show()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        isfromCreatNewGroup = false
        groupItems.removeAll()
        userJoinGroup.removeAll()
        goFriendsTVC.reloadData()
        goFriendCV.reloadData()
    }
    @IBAction func unwindToGroupList(_ segue: UIStoryboardSegue){
        if  segue.identifier == "save" {
            isfromCreatNewGroup = true
//             socketConnectGoFriends(emailAccount:email)
            
//            let chatMessage = ChatMessage.init(sender: nil, receiver:nil , message: nil, messageType: "goFriends")
//            let chatMessageData = try! JSONEncoder().encode(chatMessage)
//            let chatMessageString = String(data: chatMessageData, encoding: .utf8)!
//            socket.write(string: chatMessageString)
        }
        //        guard let creatNewGroupCV = segue.source as? CreatNewGroupViewController else{
        //            return
        //        }
        //       print("creatNewGroupCV.newGroup = \(creatNewGroupCV.newGroup), \(creatNewGroupCV.newGroup.groupName), \(creatNewGroupCV.newGroup.groupRunningLastTime), \(creatNewGroupCV.newGroup.groupRunningIntroduce), \(creatNewGroupCV.newGroup.startPointLatitude)")
        
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "nonJoinSegue" || segue.identifier == "joinSegue"{
            let groupDetailViewController = segue.destination as!
            GroupDeatilViewController
            groupDetailViewController.segue = segue.identifier!
        }
        if segue.identifier == "nonJoinSegue" {
            guard let indextPath = goFriendsTVC.indexPathForSelectedRow ,
                let groupDetailVC = segue.destination as? GroupDeatilViewController else {
                    return
            }
            groupDetailVC.groupDetail = groupItems[indextPath.row]
        }else if segue.identifier == "joinSegue" {
            guard let indexPath = goFriendCV.indexPathsForSelectedItems?.first,
                let groupDetailVC = segue.destination as? GroupDeatilViewController else {
                    return
            }
            groupDetailVC.groupDetail = userJoinGroup[indexPath.row]
            print("prepare:indexPath =  \(indexPath.row)")
        }
    }
    
    func showJoinGroup(){
        communicator.getUserJoinGroup(emailAccount: email) { (result, error) in
            if let error = error {
                print("Get getUserJoinGroup error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            self.userJoinGroupId = result as! [Int]
//            PrintHelper.println(tag: self.tag, line: 135, "getUserJoinGroup = \(result)")
        }
    }
    
    func showGroup(){
        communicator.getAll(url: communicator.GoFriendsServlet_URL) { (result, error) in
            if let error = error {
                print("Get showGroup error:\(error)")
                return
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
            guard let resultObject = try? decoder.decode([GoFriendItem].self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }
            //將取得的資料分為已參加及未參加
            for group in resultObject {
                var i = 0
                for joinId in self.userJoinGroupId {
                    if group.groupId == joinId {
                        i = 1
                        self.userJoinGroup.append(group)
                        break
                    }
                }
                if i == 0{
                    self.groupItems.append(group)
                    print("group = \(group)")
                }
            }
            
//            PrintHelper.println(tag: self.tag, line: 149, "userJoinGroup = \(self.userJoinGroup),@@@@@@ groupItems = \(self.groupItems)")
            
            self.goFriendCV.reloadData()
            self.goFriendsTVC.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    func socketConnectGoFriends(emailAccount:String){
        socket = WebSocket(url: URL(string: communicator.GOFRIENDS_SOCKET_URL + emailAccount)!)
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
        if message.messageType == "goFriends"{
            groupItems.removeAll()
            userJoinGroup.removeAll()
            showJoinGroup()
            showGroup()
          
            
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
         print("websocket ReceiveData data = \(data.count)")
    }
}

extension GoFriendsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userJoinGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath )
        cell!.layer.cornerRadius = 4
        cell?.backgroundColor = UIColor.white
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userJoinCell", for: indexPath)
        guard let finalCell = cell as? UserJoinGroupCollectionViewCell else{
            return cell
        }
        if(indexPath.row > userJoinGroup.count-1){
            print("(indexPath.row > userJoinGroup.count-1)")
            return UICollectionViewCell()
        }else{
        let item = userJoinGroup[indexPath.row]
        finalCell.textLabel.text = item.groupName
        finalCell.userJoinImageView.layer.cornerRadius = 10
        cell.layer.cornerRadius = 10
        return cell
    }
    }
}

extension GoFriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoFriendsCell", for: indexPath) as! JoinGroupTableViewCell
        if(indexPath.row > groupItems.count-1){
            print("(indexPath.row > groupItems.count-1)")
            return UITableViewCell()
        }else{
            let item = groupItems[indexPath.row]
            
            guard let groupName = item.groupName, let groupJoinPeople = item.groupJoinPeople,
                let lastDay = item.lastDay, let lastHour = item.lastHour,
                let lastMinute = item.lastMinute else {
                    return cell
            }
            
            cell.groupNameLabel.text = groupName
            cell.joinPeopleLabel.text = groupJoinPeople
            cell.lastTimeLabel.text = "\(lastDay)\(lastHour)\(lastMinute)"
            cell.nunJoinCellView.layer.cornerRadius = 20
            return cell
        }
        
    }
}
//MARK: - UITableViewDelegate
extension GoFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
extension Communicator {
    //取得user參加的項目
    func getUserJoinGroup(emailAccount:String,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY:"getUserJoinGroup",
                                       EMAIL_ACCOUNT_KEY:emailAccount]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion: completion)
    }
}

extension GoFriendsViewController: UICollectionViewDelegateFlowLayout {
    //collectionViewCell大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2 - 5, height: collectionView.frame.width/2 + 10 )
    }
}
