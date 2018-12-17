//
//  GameViewController.swift
//  pageViewDemo
//
//  Created by Apple on 2018/11/19.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

import UIKit
import SVProgressHUD
class GameViewController: UIViewController {
    @IBOutlet weak var gameTVC: UITableView!
    
    var image = ["medal_red2","medal_green","medal_blue"]
    let communicator = Communicator.shared
    var gameItem = [GameItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        gameTVC.dataSource = self
        gameTVC.delegate = self
        
    }
    func showAllGame() {
        
        communicator.getAll(url: communicator.GameServlet_URL) { (result, error) in
            if let error = error {
                print("Get all error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get all OK")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([GameItem].self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }
            
            for game in resultObject {
                //                print("\(#line)\(game)")
                self.gameItem.append(game)
            }
            DispatchQueue.main.async {
                self.gameTVC.reloadData()
            }
            
            //            print("gameItem = \(self.gameItem)")
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "currentPageChanged"), object: 0)
        gameItem.removeAll()

        SVProgressHUD.show()
        showAllGame()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        gameItem.removeAll()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let gameDetailVC = segue.destination as! GameDetailViewController
        guard var index = gameTVC.indexPathForSelectedRow else{
            print("get gameItem index fail")
            return
        }
        print("prepare index = \(index.row)")
        gameDetailVC.gameItem = gameItem[index.row]
    }
}

//MARK: - UITableViewDataSource
extension GameViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("gameitem count \(gameItem.count)")
        return gameItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameTableViewCell
        //        cell.coverImageView.sd_setImage(with: URL(string: movie.imageURL))
        //        cell.titleLabel.text = movie.title
          print("\(self.image.count)  ================   \(indexPath.row)")
        if(indexPath.row > gameItem.count-1) || (indexPath.row > image.count-1) {
            print("(indexPath.row > gameItem.count-1)")
            return UITableViewCell()
        }else{
                let item = self.gameItem[indexPath.row]
                print("\(self.image.count)  ================   \(indexPath.row)")
                cell.userImageView.image = UIImage(named: self.image[indexPath.row])
                cell.titleLabel.text = item.gameName
                cell.finalTimeLabel.text = "\(item.lastDay)\(item.lastHour)\(item.lastMinute)"
                cell.joinPeopleLabel.text = item.gameJoinPeople
            return cell
        }
        
    }
}

//MARK: - UITableViewDelegate
extension GameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
