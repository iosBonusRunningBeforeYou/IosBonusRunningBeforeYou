//
//
//  @ Justin on 2018/11/14.
//  @共用文件,我把較多共用的方法寫在這，各自需要的方法可以自己在另外用” extension 擴充Communicator“
//
//
import Foundation
import Alamofire


//共用參數
let EMAIL_ACCOUNT_KEY = "emailAccount"
let ACTION_KEY = "action"
let GET_ALL_KEY = "getAll"
let GET_IMAGE_KEY = "getImage"
let EMAIL_KEY = "email"
let IMAGE_SIZE_KEY = "imageSize"
let FIND_BY_EMAIL_KEY = "findByEmail"
let COUPON_ID = "id"

typealias DoneHandler = (_ result:Any?, _ error: Error?) -> Void
typealias DownloadDoneHandler = (_ result:Data?, _ error: Error?) -> Void

class Communicator {
    // Constants
    

    static let BASEURL = "http://192.168.50.170:8080/Running_MySQL_Web"//ip自己要再改 教室5G

//    static let BASEURL = "http://172.20.10.9:8080/Running_MySQL_Web"//ip自己要再改 手機

    //各個功能的URL
    let GameServlet_URL = BASEURL + "/GameServlet"
    let GameDetailServlet_URL = BASEURL + "/GameDetailServlet"
    let ShopServlet_URL = BASEURL + "/ShopServlet"
    let PointsRecordServlet_URL = BASEURL + "/PointsRecordServlet"
    let RunningServlet_URL = BASEURL + "/RunningServlet"
    let RunningDataServlet_URL = BASEURL + "/RunningDataServlet"
    let UserServlet_URL = BASEURL + "/UserServlet"
    let GoFriendsServlet_URL = BASEURL + "/GoFriendsServlet"
    
    static let shared = Communicator()
    private init() {
        
    }
    
    func getImage(url:String ,email:String , imageSize:Int = 1024, completion:@escaping DownloadDoneHandler ){
        let paramters:[String:Any] = [ACTION_KEY : GET_IMAGE_KEY,
                                      EMAIL_KEY : email,
                                      IMAGE_SIZE_KEY : imageSize]
        
        doPostForImage(urlString: url, parameters: paramters, completion: completion)
    }
    
    func getAll(url:String, completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : GET_ALL_KEY]
        
        doPost(urlString: url, parameters: parameters, completion: completion)
        
    }
    
    func findByEmail(url:String, eamil:String, completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : FIND_BY_EMAIL_KEY,
                                       EMAIL_KEY : eamil]
        doPost(urlString: url, parameters: parameters, completion: completion)
    }
    
    //取文字用
    func doPost(urlString: String, parameters: [String: Any], completion: @escaping DoneHandler){
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            switch response.result {
            case .success(let json):
                print("Get success response: \(json)")
                completion(json ,nil)
                
            case .failure(let error):
                print("Server respond error:\(error)")
                completion(nil,error)
            }
        }
    }
    //取圖片用
    func doPostForImage(urlString: String,
                        parameters: [String: Any],
                        completion: @escaping DownloadDoneHandler) {
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseData { (response) in
            
            self.handlePhoto(response: response, completion: completion)
        }
    }
    private func handlePhoto(response: DataResponse<Data>, completion: DownloadDoneHandler) {
        guard let data = response.data else {
            print("data is nil")
            let error = NSError(domain: "Invalid Image object.", code: -1, userInfo: nil)
            completion(nil, error)
            return
        }
        completion(data, nil)
    }
    
    func getCouponImage(url:String ,id:Int , imageSize:Int = 1024, completion:@escaping DownloadDoneHandler ){
        let paramters:[String:Any] = [ACTION_KEY : GET_IMAGE_KEY,
                                      COUPON_ID : id,
                                      IMAGE_SIZE_KEY : imageSize]
        
        doPostForImage(urlString: url, parameters: paramters, completion: completion)
    }
}
