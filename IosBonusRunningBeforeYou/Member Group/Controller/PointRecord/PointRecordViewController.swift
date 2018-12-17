//
//  PointRecordViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class PointRecordViewController: UIViewController {
    
    @IBOutlet weak var pointRecordTableView: UITableView!
    @IBOutlet weak var totalPointLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    let communicator = Communicator.shared
    var pointRecords = [PointRecord]()
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = userDefaults.string(forKey: "email")!
        pointRecordTableView.dataSource = self
        pointRecordTableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pointRecords.removeAll()
        showTotalPoint()
        showAllRecords()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        pointRecords.removeAll()
    }
    
    func showTotalPoint() {
        
        communicator.findTotalPoint(email: email) { (result, error) in
            print("totalPoint = \(String(describing: result))")
            if let error = error {
                print("Get totalPoint error: \(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get totalPoint OK")
            
            let totalPoint = String(describing: result)
            self.totalPointLabel.text = totalPoint
            
        }
        
    }
    
    func showAllRecords() {
        
        communicator.getAllRecords(email: email) { (result, error) in
            
            if let error = error {
                print("Get records error: \(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get records OK")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([PointRecord].self, from: jsonData) else
            {
                print("Fail to decode jsonData.")
                return
            }
            
            for pointRecord in resultObject {
                if (pointRecord.record_points != 0) {
                    self.pointRecords.append(pointRecord)
                }
            }
            self.pointRecords.reverse()
            self.pointRecordTableView.reloadData()
            
        }
        
    }

}

//MARK: - UITableViewDataSource
extension PointRecordViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("pointRecords count: \(pointRecords.count)")
        return pointRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointRecordCell", for: indexPath) as! PointRecordTableViewCell
        let item = pointRecords[indexPath.row]
        if (item.record_points < 0) {
            cell.recordNameLabel.text = item.record_name
            cell.recordPointsLabel.text = "花費\(item.record_points * -1)點"
            cell.recordDateLabel.text = item.record_date
            cell.backgroundColor = UIColor.yellow
        }
        else {
            cell.recordNameLabel.text = item.record_name
            cell.recordPointsLabel.text = "獲得\(item.record_points)點"
            cell.recordDateLabel.text = item.record_date
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension PointRecordViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Communicator {
    
    
    func getAllRecords(email: String, completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "getRecords","email": email]
        doPost(urlString: PointsRecordServlet_URL, parameters: parameters, completion:completion)
    }
    
}
