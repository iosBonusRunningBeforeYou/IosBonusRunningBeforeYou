//
//  ViewController.swift
//  text
//
//  Created by Apple on 2018/10/6.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SocialViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var tablVC: UITableView!
    @IBOutlet weak var colVC: UICollectionView!
    @IBOutlet weak var textImage: UIImageView!
    let screenSize = Int(UIScreen.main.bounds.size.width)/4 // 取得螢幕尺寸？

    var page:Int?
    var goFriendItem:[String] = ["6","5","4","3"]
    
    let communicator = Communicator.shared
    var gameItem = [GameItem]()
    
    let cellIds = ["Game Cell","GoFriend Cell"]
//    let cellSizes = Array( repeatElement(CGSize(width:170, height:80), count: 2))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleView()
        showAllGame()
       image ()
    }
    
    func image (){
        communicator.getImage(url: communicator.GameDetailServlet_URL, email: "123@gamil.com") { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            self.textImage.image = UIImage(data: data)
//            print("json = \(data)")
        }
    }
    
    
    func handleView(){
        colVC.delegate = self
        colVC.dataSource = self
        tablVC.dataSource = self
        tablVC.delegate = self
        if let layout = colVC?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 15, left: 10, bottom: 0, right: 10)
            let size = CGSize(width:(colVC!.bounds.width-30)/2, height: 30)
            layout.itemSize = size
        }
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
            print("Get all  OK")
            
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
            self.tablVC.reloadData()
//            print("gameItem = \(self.gameItem)")
        }
    }


    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellIds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell( withReuseIdentifier: cellIds[indexPath.item], for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        print("User tapped on \(cellIds[indexPath.row])")
        if indexPath.row == 0 {
            page = 1
            tablVC.reloadData()
        }else{
            page = 2
            tablVC.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if page == 1{
            return gameItem.count
        }else if page == 2{
            return goFriendItem.count
        }else{
            return gameItem.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        if page == 1{
            let item = self.gameItem[indexPath.row]
            
            cell.textLabel?.text = item.gameName
            return cell
        }else if page == 2 {
            let item = self.goFriendItem[indexPath.row]
            cell.textLabel?.text = item
            return cell
        }else {
            let item = self.gameItem[indexPath.row]
            cell.textLabel?.text = item.gameName
            return cell
        }
    }
}

