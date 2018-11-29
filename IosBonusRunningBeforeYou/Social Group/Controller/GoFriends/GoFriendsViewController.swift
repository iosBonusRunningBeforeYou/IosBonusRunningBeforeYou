//
//  GoFriendsViewController.swift
//  pageViewDemo
//
//  Created by Apple on 2018/11/19.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class GoFriendsViewController: UIViewController {
//    var goFriendsItem = ["5","6","7","8","9"]
    @IBOutlet weak var goFriendsTVC: UITableView!
    @IBOutlet weak var goFriendCV: UICollectionView!
    let communicator = Communicator.shared
    let userEmail = "123@gamil.com"
    var userJoinGroupId: [Int] = []
    var groupItems = [GoFriendItem]()
    var userJoinGroup = [GoFriendItem]()
    let tag = "goFriendViewController"
    var isfromCreatNewGroup = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goFriendsTVC.dataSource = self
        goFriendsTVC.delegate = self
        goFriendCV.dataSource = self
        goFriendCV.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "currentPageChanged"), object: 1)
        if isfromCreatNewGroup == false {
            showJoinGroup()
            showGroup()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        isfromCreatNewGroup = false
        groupItems.removeAll()
        userJoinGroup.removeAll()
    }
    @IBAction func unwindToGroupList(_ segue: UIStoryboardSegue){
        
        isfromCreatNewGroup = true
            showJoinGroup()
            showGroup()
 
        
        guard  segue.identifier == "save"  else {
            return
        }
        guard let creatNewGroupCV = segue.source as? CreatNewGroupViewController else{
            return
        }
       print("creatNewGroupCV.newGroup = \(creatNewGroupCV.newGroup), \(creatNewGroupCV.newGroup.groupName), \(creatNewGroupCV.newGroup.groupRunningLastTime), \(creatNewGroupCV.newGroup.groupRunningIntroduce), \(creatNewGroupCV.newGroup.startPointLatitude)") 
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func showJoinGroup(){
        communicator.getUserJoinGroup(emailAccount: userEmail) { (result, error) in
            if let error = error {
                print("Get showJoinGroup error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            
            self.userJoinGroupId = result as! [Int]
            PrintHelper.println(tag: self.tag, line: 57, "showJoinGroup = \(result)")
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
            
            for group in resultObject {
                //                print("\(#line)\(game)")
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
            
            PrintHelper.println(tag: self.tag, line: 93, "userJoinGroup = \(self.userJoinGroup), groupItems = \(self.groupItems)")
            
            self.goFriendCV.reloadData()
            self.goFriendsTVC.reloadData()

        }
    }

}

extension GoFriendsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userJoinGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath )
        cell!.layer.cornerRadius = 4
        cell?.backgroundColor = UIColor.yellow
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
           let item = userJoinGroup[indexPath.row]
        
        finalCell.textLabel.text = item.groupName
        cell.layer.cornerRadius = 10
        
        return cell
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
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoFriendsCell", for: indexPath)
        //        cell.coverImageView.sd_setImage(with: URL(string: movie.imageURL))
        //        cell.titleLabel.text = movie.title
        let item = groupItems[indexPath.row]
        cell.textLabel?.text = item.groupName
        cell.detailTextLabel?.text = item.groupJoinPeople
        return cell
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
    func getUserJoinGroup(emailAccount:String,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY:"getUserJoinGroup",
                                       EMAIL_ACCOUNT_KEY:emailAccount]
        
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion: completion)
    }
    
    
}
