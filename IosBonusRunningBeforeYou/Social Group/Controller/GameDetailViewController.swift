//
//  GameDetailViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/20.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

import UIKit
import Alamofire
import SVProgressHUD

class GameDetailViewController: UIViewController {
    
    @IBOutlet weak var rankOfGameTVC: UITableView!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var gameTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userRankNumLabel: UILabel!
    @IBOutlet weak var userRuleLabel: UILabel!
    
    
    var email = "123@gamil.com"
    let userDefault = UserDefaults.standard
    var gameItem:GameItem?
    var rankOfGameItem = [RankOfGame]()
    let communicator = Communicator.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        handleView()
    }
    
    func handleView() {
        gameTextLabel.text = gameItem?.gameDetail
        navigationItem.title = gameItem?.gameName
        userInfoView.isHidden = true
        rankOfGameTVC.delegate = self
        rankOfGameTVC.dataSource = self
         userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 25
       email = userDefault.string(forKey: "email")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let gameId = gameItem?.gameId, let ruleId = gameItem?.ruleId else {
            print("gameId")
            return
        }
        SVProgressHUD.show()
        getRankOfGame(gameId: gameId, ruleId: ruleId)
        getJoinStatus(email: email, gameId: gameId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        rankOfGameItem.removeAll()
    }
    
    func getRankOfGame (gameId:Int, ruleId:Int){
        communicator.getRankOfGame(gameId: gameId, ruleId: ruleId) { (result, error) in
            if let error = error {
                print("Get rankOfGame error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get rankOfGame  OK")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([RankOfGame].self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }
            
            for rankOfGame in resultObject {
                print("\(#line)\(rankOfGame)")
                self.rankOfGameItem.append(rankOfGame)
            }
            PrintHelper.println(tag: "d", line: 85, "rankOfGameItem = \(self.rankOfGameItem)")
            
            self.rankOfGameTVC.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    func getImage(_ image:UIImageView,_ email:String){
        communicator.getImage(url: communicator.GameDetailServlet_URL, email: email) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            
            print("UIImage data = \(data)")
            image.image = UIImage(data: data)
        }
        
    }
    
    
    func getJoinStatus(email:String, gameId:Int) {
        var joinStatus = false
        communicator.getJoinStatus(email: email, gameId: gameId) { (result, error) in
            guard let result = result ,let bool = result as? Bool else{
                print("get joinStatus nil")
                return
            }
            
            joinStatus = bool
            if joinStatus {
                self.joinBtn.isHidden = true
                self.userInfoView.isHidden = false
                self.getImage(self.userImageView, self.email)
             
                self.getUserInfo ()
            }
            print("joinStatusg;4 ======\(joinStatus)")
        }
        print("joinStatus ======\(joinStatus)")
        
    }
    
    func getUserInfo(){
        var int = 0
        
        print("rankOfGame = \(rankOfGameItem.count)")
        for rankItem in rankOfGameItem {
            int += 1
            if rankItem.emailAccount == email {
                print(" rankItem.emailAccount = \(rankItem.emailAccount) \(int) === \(rankOfGameItem[int-1].emailAccount)")
                
                userNameLabel.text = rankItem.rankName
                userRuleLabel.text = rankItem.rankKm
                userRankNumLabel.text = String(int)
                break
            }
        }
    }
    
    @IBAction func joinBtnAction(_ sender: UIButton) {
        
        guard let gameId = gameItem?.gameId else {
            print("gameId")
            return
        }
        communicator.insertGameJoinState(email: email, gameId: gameId) { (result, error) in
            print("insertGameJoinState = \(result)")
            guard let result = result ,let resultInt = result as? Int else{
                print("get joinStatus nil")
                return
            }
            
            if resultInt == 1 {
                self.joinBtn.isHidden = true
                self.userInfoView.isHidden = false
                // 找用userId 在陣列中找出user資料 show in userinfoView
                
                guard let gameId = self.gameItem?.gameId, let ruleId = self.gameItem?.ruleId else {
                    print("gameId")
                    return
                }
                self.rankOfGameItem.removeAll()
                self.getRankOfGame(gameId: gameId, ruleId: ruleId)
            }else {
                print("insertGameJoinState fail")
            }
        }
    }
    
    @IBAction func gameTextBtnAction(_ sender: UIButton) {
        
        guard let message = gameItem?.gamePreface else {
            return
        }
        showAlert(message:message)
    } 
}

extension GameDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let gameId = gameItem?.gameId
        
        getJoinStatus(email: email, gameId: gameId!)
        
        print("rankOfGameItem count = \(rankOfGameItem.count)")
        return rankOfGameItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath) as! RankTableViewCell
        
        let item = rankOfGameItem[indexPath.row]
        cell.rankImageView.layer.cornerRadius = 25
        cell.rankImageView.clipsToBounds = true
        getImage(cell.rankImageView, item.emailAccount)
        cell.rankNumLabel.text = String(item.rankNum)
        cell.rankOfUserNameLabel.text = item.rankName
        cell.rankOfRuleLabel.text = item.rankKm
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension GameDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Communicator{
    
    func insertGameJoinState(email:String,gameId:Int,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : "insertGameJoinState",
                                       "emailAccount" : email,
                                       "gameId" : gameId]
        doPost(urlString: GameDetailServlet_URL, parameters: parameters, completion:completion)
    }
    
    func getRankOfGame(gameId:Int, ruleId:Int, completion:@escaping DoneHandler){
        
        let parameters:[String:Any] = [ACTION_KEY : "getRankOfGame",
                                       "gameId" : gameId,
                                       "ruleId" : ruleId]
        doPost(urlString: GameDetailServlet_URL, parameters: parameters, completion: completion)
        
    }
    
    func getJoinStatus(email:String,gameId:Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY:"getJoinStatus",
                                       EMAIL_ACCOUNT_KEY:email,
                                       "gameId":gameId]
        
        doPost(urlString: GameDetailServlet_URL, parameters: parameters, completion: completion)
        
    }
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
