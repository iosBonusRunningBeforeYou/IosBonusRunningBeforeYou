//
//  GoFriendsViewController.swift
//  pageViewDemo
//
//  Created by Apple on 2018/11/19.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class GoFriendsViewController: UIViewController {
    var goFriendsItem = ["5","6","7","8","9"]
    @IBOutlet weak var goFriendsTVC: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        goFriendsTVC.dataSource = self
        goFriendsTVC.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "currentPageChanged"), object: 1)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension GoFriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return goFriendsItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoFriendsCell", for: indexPath)
        //        cell.coverImageView.sd_setImage(with: URL(string: movie.imageURL))
        //        cell.titleLabel.text = movie.title
        let item = goFriendsItem[indexPath.row]
        cell.textLabel?.text = item
        cell.detailTextLabel?.text = item
        return cell
    }
}

//MARK: - UITableViewDelegate
extension GoFriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
