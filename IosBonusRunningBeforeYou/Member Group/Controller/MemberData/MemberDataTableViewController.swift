//
//  MemberDataTableViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MemberDataTableViewController: UITableViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet var memberDataTableView: UITableView!
    
    let communicator = Communicator.shared
    var userData = UserData()
    let userDefaults = UserDefaults.standard
    var email = String()
    var age = 0
    var height = 0
    var weight = Float()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email = userDefaults.string(forKey: "email")!
        memberDataTableView.isScrollEnabled = false
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showUserData()
    }
    
    func showUserData() {
        
        communicator.findByEmail(email: email) { (result, error) in
            print("userData = \(String(describing: result))")
            
            if let error = error {
                print("Get userData error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get userData OK")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(UserData.self, from: jsonData) else {
                print("Fail to decode jsonData.")
                return
            }
            
            self.emailLabel.text = resultObject.email_account
            self.nameLabel.text = resultObject.name
            if (resultObject.gender == 1) {
                self.genderLabel.text = "男性"
            }
            else if (resultObject.gender == 2) {
                self.genderLabel.text = "女性"
            }
            
            self.age = resultObject.age
            self.height = resultObject.height
            self.weight = resultObject.weight
            
            self.ageLabel.text = String(self.age)
            self.heightLabel.text = String(self.height)
            self.weightLabel.text = String(self.weight)
            
            self.userDefaults.set(resultObject.name, forKey: "name")
            self.userDefaults.set(resultObject.age, forKey: "age")
            self.userDefaults.set(resultObject.height, forKey: "height")
            self.userDefaults.set(resultObject.weight, forKey: "weight")
        }
        
    }
    
}

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


