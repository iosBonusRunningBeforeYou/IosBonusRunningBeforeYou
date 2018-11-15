//
//  RunningCommunicator.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/11/15.
//  Copyright © 2018 Apple. All rights reserved.
//

////標準的singleton 寫法. 適用於多個地方要用.
//class RunningCommunicator{
//    static let shared = Communicator()
//    private init(){}
//}

//#if true // false --> test server, true --> official server.
//static let BASEURL = "http://class.softarts.cc/PushMessage/"
//#else
//static let BASEURL = "http://test.softarts.cc/PushMessage/"
//#endif

import Foundation
import Alamofire

let EMAIL = "2346@gmail.com"

// JSON Key
// step1:   準備 startTime, endTime, totalTime ,distance, email 的資料 包成 runningData
// step2:   準備 name, points, endTime, email 的資料 包成 pointData
// action  id_running_data runningData pointData email totalPoint user


let ID_KEY = "id_running_data"
let USERNAME_KEY = "user"
let POINTDATA_KEY = "pointData"
let RUNNINGDATA_KEY = "runningData"
let TOTALPOINT_KEY = "totalPoint"
let RESULT_KEY = "result"
let DATA_KEY = ""


//[String:Any]? dictionary 的型別. 因為json 拿回來的是dictionary
typealias DoneHandler = (_ result: [String:Any]?, _ error: Error?) -> Void

// 10/26 新增
typealias DownloadDoneHandler = (_ result: Data? , _ error: Error?) -> Void

//標準的singleton 寫法.
class RunningCommunicator{
    
    static let BASEURL = "http://192.168.50.246:8080/Running_MySQL_Web"
    let UPDATA_URL = BASEURL + "RunningServlet.java"
    
    
//    let RETRIVE_MESSAGES_URL = BASEURL + "retriveMessages2.php"
//    let SEND_MESSAGE_URL = BASEURL + "sendMessage.php"
//    let SEND_PHOTOMESSAGE_URL = BASEURL + "sendPhotoMessage.php"
//    let PHOTO_BASE_URL = BASEURL + "photos/"

    static let shared = RunningCommunicator()
    private init(){
    }
    
    
    // step1:   準備 startTime, endTime, totalTime ,distance, email 的資料 包成 runningData
    // step2:   準備 name, points, endTime, email 的資料 包成 pointData
    // MARK: - Public methods
    func updateLocation(completion: @escaping DoneHandler) {
        let parameters = [USERNAME_KEY: "user"]
        doPost(urlString: UPDATA_URL, parameters: parameters, completion: completion)
    }
    
    
    private func doPost(urlString: String, parameters: [String: Any], data : Data ,completion: @escaping DoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(jsonData, withName: DATA_KEY)
            // fileName: "image.jpg" 因為server 會去rename, 因此這邊可以寫死.
            formData.append(data, withName: "fileToUpload", fileName: "image.jpg", mimeType: "image/jpg")
        }, to: urlString, method: .post) { (encodingResult) in
            switch encodingResult{
            //            case .success(let request, let fromDisk, let url): // 只留下request,因為另外兩個參數用不到.
            case .success(let request, _, _):
                print("Post Encoding OK.")
                request.responseJSON { (response) in
                    self.handleJSON(response: response, completion: completion)
                }
            case .failure(let error):
                print("Post Encoding fail: \(error)")
                completion(nil, error)
            }
        }
    }
    
    private func doPost(urlString: String, parameters: [String: Any], completion: @escaping DoneHandler) {
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) //用try! 因為對
        let jsonString = String(data: jsonData, encoding: .utf8)! // 將json 轉成 .utf8
        let finalParamters : [String: Any] = [DATA_KEY: jsonString]
        
        // URLEncoding.default 會將key,value 轉成key = value , 上傳的東西是 data=.....
        // JSONEncoding.default 上傳的東西是 {"data"="....."}
        // let header = ["AuthorizarionKey":"......"]
        Alamofire.request(urlString, method: .post, parameters: finalParamters, encoding: URLEncoding.default).responseJSON { (response) in
            
            self.handleJSON(response: response, completion: completion)
        }
        
    }
    
    private func handleJSON(response: DataResponse<Any>, completion: DoneHandler)
    {
        switch response.result{
        case .success(let json): print("Get success response: \(json)")   // enum的特殊用法 (let json)
        // json 解不出來時.
        guard let finalJson = json as? [String: Any] else {
            let error = NSError(domain: "Invalid JSON object", code: -1, userInfo: nil)
            completion(nil,error)
            return
        }
        guard let result = finalJson[RESULT_KEY] as? Bool , result == true else{
            let error = NSError(domain: "Server respond false or not result.", code: -1, userInfo: nil)
            completion(nil,error)
            return
        }
        completion(finalJson, nil)
            
        case .failure(let error): print("Server respond error: \(error)")
        completion(nil,error)
        }
    }
}



// MARK: draw footStamp
//private void  getAllById(){
//    if (Common.networkConnected(this)) {
//        String url = Common.URL + "/RunningServlet";
//        List<Running> runnings = null; //準備容器.
//        JsonObject jsonObject = new JsonObject();
//        jsonObject.addProperty("action", "getAllById");
//        jsonObject.addProperty("id_running_data", trackId);
//        String jsonOut = jsonObject.toString();
//        commonTask = new CommonTask(url, jsonOut);
//        try {
//        //execute()執行CommonTask的doInBackground.
//        //spotGetAllTask.execute().get(). 會讓CommonTask(String url, String outStr) 去server拿資料.
//        String jsonIn = commonTask.execute().get(); //若要拿的資料很大量,則用execute(). 不呼叫get()去拿. 會拖慢速度.
//        Type listType = new TypeToken<List<Running>>() {
//        }.getType();
//        runnings = new Gson().fromJson(jsonIn, listType);
//
//
//
//        } catch (Exception e) {
//        Log.e("error", e.toString());
//        }
//        if (runnings == null || runnings.isEmpty()) {
//            Common.showToast(this, R.string.msg_InsertFail);
//        } else {
//            //                Common.showToast(this, R.string.msg_InsertSuccess);
//            for(int i = 0 ; i < runnings.size()-1 ; i++ ) {
//                recoedLastNkut = new LatLng(runnings.get(i).getLatitude(), runnings.get(i).getLongitude());
//                recordNkut = new LatLng(runnings.get(i+1).getLatitude(), runnings.get(i+1).getLongitude());
//                Polyline polyline = map.addPolyline(
//                    new PolylineOptions()
//                        .add(recoedLastNkut, recordNkut) //緯經度放這邊. 根據記錄,描繪各個點把軌跡呈現.
//                        .width(10)
//                        .color(Color.GRAY)
//                        .zIndex(25)); //z軸,數字越大,高度越高. default值為零.
//
//                polyline.setWidth(15);
//            }
//        }
//    } else {
//        Common.showToast(this, R.string.msg_NoNetwork);
//    }
//}


// MARK: 跑步資料表, 點數資料表
// server:  url = Common.URL + "/RunningDataServlet"
// step1:   準備 startTime, endTime, totalTime ,distance, email 的資料 包成 runningData
// step2:   準備 name, points, endTime, email 的資料 包成 pointData

// step3:   jsonObject.addProperty("action", "runningDataInsert");
//          jsonObject.addProperty("runningData", new Gson().toJson(runningData));
//          jsonObject.addProperty("pointData", new Gson().toJson(pointData));

// step4:   try catch String result = new CommonTask(url, jsonObject.toString()).execute().get();

//private  void  thansToData(long startTime , long endTime ,long totalTime , double distance , String name , int points ,String email){
//    // TODO: 2018/9/19 mail為外鍵,需要用share preference取代.
//    if(email.equals("")) {
//        //            email = "123@gamil.com";
//        //            String password = "12345";
//
//        email = "2346@gmail.com";
//        String password = "23456";
//    }
//
//
//    if (Common.networkConnected(getActivity())) {
//        String url = Common.URL + "/RunningDataServlet";
//        Running runningData = new Running(startTime, endTime, totalTime ,distance, email);
//        Running pointData = new Running(name, points,  endTime ,  email);
//        //            Running memberData = new Running(email, points, distance);
//
//        JsonObject jsonObject = new JsonObject();
//        jsonObject.addProperty("action", "runningDataInsert");
//        jsonObject.addProperty("runningData", new Gson().toJson(runningData));
//        jsonObject.addProperty("pointData", new Gson().toJson(pointData));
//        //            jsonObject.addProperty("memberData", new Gson().toJson(memberData));
//
//        int count = 0;
//        try {
//        String result = new CommonTask(url, jsonObject.toString()).execute().get();
//        count = Integer.valueOf(result);
//        } catch (Exception e) {
//        //Log.e(TAG, e.toString());
//        }
//        if (count == 0) {
//            Common.showToast(getContext(), R.string.msg_InsertFail);
//        } else {
//            //                Common.showToast(getContext(), R.string.msg_InsertSuccess);
//        }
//    } else {
//        Common.showToast(getContext(), R.string.msg_NoNetwork);
//    }
//}



// MARK: 更新點數
// server: url = Common.URL + "/RunningDataServlet"
// step1:   jsonObject.addProperty("action", "findTotalPoint");
//          jsonObject.addProperty("email", email);
// step2:   renewTotalPoint = totalPoints + points;

// step3:   jsonObject.addProperty("action", "updateTotalPoint");
//          jsonObject.addProperty("email", email);
//          jsonObject.addProperty("totalPoint", renewTotalPoint);

// step4:   try catch String result = new CommonTask(url, jsonObject.toString()).execute().get();

//private void sumToTotalPoint(String email , int points) {
//    if(email.equals("")) {
//        //            email = "123@gamil.com";
//        //            String password = "12345";
//
//        email = "2346@gmail.com";
//        String password = "23456";
//    }
//
//    if (Common.networkConnected(getActivity())) {
//        String url = Common.URL + "/PointsRecordServlet";
//        int totalPoints = 0;
//        JsonObject jsonObject = new JsonObject();
//        jsonObject.addProperty("action", "findTotalPoint");
//        jsonObject.addProperty("email", email);
//        String jsonOut = jsonObject.toString();
//        getPointsTask = new CommonTask(url, jsonOut);
//        try {
//        String jsonIn = getPointsTask.execute().get();
//        totalPoints = new Gson().fromJson(jsonIn, int.class);
//        renewTotalPoint = totalPoints + points;
//        } catch (Exception e) {
//        Log.e(TAG, e.toString());
//        }
//
//        int count = 0;
//        jsonObject.addProperty("action", "updateTotalPoint");
//        jsonObject.addProperty("email", email);
//        jsonObject.addProperty("totalPoint", renewTotalPoint);
//        jsonOut = jsonObject.toString();
//        getPointsTask = new CommonTask(url, jsonOut);
//        try {
//        String result = new CommonTask(url, jsonObject.toString()).execute().get();
//        count = Integer.valueOf(result);
//
//        } catch (Exception e) {
//        Log.e(TAG, e.toString());
//        }
//        if (count == 0) {
//            Common.showToast(getContext(), R.string.msg_InsertFail);
//        } else {
//            //                Common.showToast(getContext(), R.string.msg_InsertSuccess);
//        }
//    } else {
//        Common.showToast(getContext(), R.string.msg_NoNetwork);
//    }
//}


// MARK: 更新點數
// server: url = Common.URL + "/UserServlet"
// step1:   jsonObject.addProperty("action", "findByEmail");
//          jsonObject.addProperty("email", email);
// step2:   user  = new Gson().fromJson(jsonIn, User.class);
//          dayilyMetre = user.getTarget_daily();
//          weeklyMetre = user.getTarget_weekly();
//          monthlyMetre = user.getTarget_monthly()
// step3:   jsonObject.addProperty("action", "updateTotalPoint");
//          jsonObject.addProperty("email", email);
//          jsonObject.addProperty("totalPoint", renewTotalPoint);
//          this.dayilyMetre += odometer.distanceInKilometers;
//          this.weeklyMetre += odometer.distanceInKilometers;
//          this.monthlyMetre += odometer.distanceInKilometers;
// step4:   jsonObject.addProperty("action", "updateTarget");
//          jsonObject.addProperty("user",  new Gson().toJson(user));
// step5:   try catch String result = new CommonTask(url, jsonObject.toString()).execute().get();

//private void sumToTotalmetra(String email) {
//    if(email.equals("")) {
//        //            email = "123@gamil.com";
//        //            String password = "12345";
//
//        email = "2346@gmail.com";
//        String password = "23456";
//    }
//
//    if (Common.networkConnected(getActivity())) {
//        String url = Common.URL + "/UserServlet";
//
//        JsonObject jsonObject = new JsonObject();
//        jsonObject.addProperty("action", "findByEmail");
//        jsonObject.addProperty("email", email);
//        String jsonOut = jsonObject.toString();
//        getPointsTask = new CommonTask(url, jsonOut);
//        try {
//        String jsonIn = getPointsTask.execute().get();
//        user  = new Gson().fromJson(jsonIn, User.class);
//        dayilyMetre = user.getTarget_daily();
//        weeklyMetre = user.getTarget_weekly();
//        monthlyMetre = user.getTarget_monthly();
//        this.dayilyMetre += odometer.distanceInKilometers;
//        this.weeklyMetre += odometer.distanceInKilometers;
//        this.monthlyMetre += odometer.distanceInKilometers;
//        this.user = new User(dayilyMetre ,weeklyMetre ,monthlyMetre , email);
//
//
//        } catch (Exception e) {
//        Log.e(TAG, e.toString());
//        }
//
//
//        int count = 0;
//        jsonObject.addProperty("action", "updateTarget");
//        jsonObject.addProperty("user",  new Gson().toJson(user));
//
//        jsonOut = jsonObject.toString();
//        getPointsTask = new CommonTask(url, jsonOut);
//        try {
//        String result = new CommonTask(url, jsonObject.toString()).execute().get();
//        count = Integer.valueOf(result);
//
//        } catch (Exception e) {
//        Log.e(TAG, e.toString());
//        }
//        if (count == 0) {
//            Common.showToast(getContext(), R.string.msg_InsertFail );
//        } else {
//            //                Common.showToast(getContext(), R.string.msg_InsertSuccess);
//        }
//    } else {
//        Common.showToast(getContext(), R.string.msg_NoNetwork);
//    }
//}

