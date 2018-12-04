//
//  JoinPeopleCollectionViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/12/3.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

import UIKit
import SVProgressHUD
private let reuseIdentifier = "Cell"

class JoinPeopleCollectionViewController: UICollectionViewController {


    var userInfo = [GoFriendItem]()
    let communicator = Communicator.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
    }

    func getImage (_ image:UIImageView,_ email:String){
        communicator.getImage(url: communicator.GameDetailServlet_URL, email: email) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            image.image = UIImage(data: data)
            //            print("json = \(data)")
            SVProgressHUD.dismiss()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return userInfo.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "joinPeopleCell", for: indexPath) as! JoinPeopleCollectionViewCell
        let item = userInfo[indexPath.row]
        cell.userName.text = item.name
     
        guard let email = item.emailAccount else{
            return cell
        }
        getImage(cell.userPhoto, email)
        // Configure the cell
//    cell.layer.frame.height

        return cell
    }

   
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
extension JoinPeopleCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 20, height: collectionView.frame.width)
    }
}
