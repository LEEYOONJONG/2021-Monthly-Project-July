import UIKit
import Alamofire
import SwiftSoup
import UserNotifications
import Foundation
import KeychainSwift


class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    let userNotificationCenter = UNUserNotificationCenter.current()
    var loginManager = LoginManager()
    
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginClicked(_ sender: Any) {
            LoginManager.shared.requestCode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // design
        loginButton.layer.cornerRadius = 10
        
        //
        LoginManager.shared.callback = {[weak self] str in // [weak self]와
            guard let self = self else { return } // 이 라인 안써도 잘 작동되긴 함.
            DispatchQueue.main.async {
                self.countLabel.text = str
            }
        }
        
        //
        userNotificationCenter.delegate = self
        requestAuthorization()
        sendNotification()
    }
    func requestAuthorization(){
        
        let options = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)
        userNotificationCenter.requestAuthorization(options: options) { success, error in
            if let error = error {
                print("requestAuthorization error : ", error)
            }
        }
    }
    func sendNotification(){ // 시각 도달 시, 강제로 알림 주고 끝
        let notiContent = UNMutableNotificationContent()
        
        notiContent.title = "Ssukssuk"
        notiContent.body = "커밋하실 시각이예요!"
        
        var date = DateComponents()
        date.hour = 21
        date.minute = 59
        print("date : ",date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "LocalNoti", content: notiContent, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    
}

extension ViewController{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                completionHandler([.alert, .badge, .sound])
    }
    
}



var githubURL:String=""
class LoginManager {
    static let shared = LoginManager()
    
    init() {}
    let client_id = "ac6468124c1c1e12dd21"
    let client_secret = "a0c30c5dfaa7224a0928c3635250d3ad26bf709f"
    var commitNum:String = "데이터를 가져오는 중입니다..."
    
    //
    var callback: ((String) -> ())?
    
    //
    func fetch() {
        AF.request(githubURL).responseString { response in
            guard let responseValue = response.value else{
                return
            }
            
            do {
                let doc:Document = try SwiftSoup.parse(responseValue)
                
                // 전체 탐색
                for week in 1...53{
                    for day in 1...7{
                        let element:Elements = try doc.select("#js-pjax-container > div.container-xl.px-3.px-md-4.px-lg-5 > div > div.flex-shrink-0.col-12.col-md-9.mb-4.mb-md-0 > div:nth-child(2) > div > div.mt-4.position-relative > div.js-yearly-contributions > div > div > div > svg > g > g:nth-child(\(week)) > rect:nth-child(\(day))")
                        for i in element{
                            print(try i.attr("data-date"), try i.attr("data-count"))
                            let nowDate = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                            let stringDate = dateFormatter.string(from: nowDate)
                            if (try i.attr("data-date") == stringDate){
                                print("오늘의 commit 수는 ", try i.attr("data-count"))
                                self.commitNum = "\(Int(try i.attr("data-count")) ?? -1)"
                                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+1, execute: {
                                    let n = Int.random(in: 1...9999)
                                    self.callback?("\(self.commitNum)회입니다.")
                                })
                                // 여기서 새로운 뷰 컨트롤러로 데이터를 segue 등으로 넘겨야 할듯
                            }
                        }
                    }
                }
                
            }
            catch{
                print("error occured")
            }
        }
    }
    
    func requestCode() { // 초기 로그인을 위한
        let scope = "user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(client_id)&scope=\(scope)"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func requestAccessToken(with code: String){ // redirection 이후
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now()+1, execute: {
            let n = Int.random(in: 1...9999)
            self.callback?("계산 중입니다...")
        })
        let client_id = "ac6468124c1c1e12dd21"
        let client_secret = "a0c30c5dfaa7224a0928c3635250d3ad26bf709f"
        let url = "https://github.com/login/oauth/access_token"
        let parameters = ["client_id": client_id, "client_secret":client_secret, "code":code]
        let headers:HTTPHeaders = ["Accept": "application/json"]
        AF.request(url, method: .post, parameters:parameters, headers:headers)
            .responseJSON{(response) in
                switch response.result{
                case let .success(json):
                    if let dic = json as? [String:String]{
                        let accessToken = dic["access_token"] ?? ""
                        KeychainSwift().set(accessToken, forKey: "accessToken")
                        print(dic["access_token"])
                        print(dic["scope"])
                        print(dic["token_type"])
                        self.getUser()
//                        self.getRepo() // json 바깥을 감싸는 소괄호 제거 성공못함.
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    func getRepo(){
        let url = "https://api.github.com/users/LEEYOONJONG/repos?sort=updated"
        AF.request(url, method: .get, parameters: [:])
            .responseJSON(completionHandler: {(response) in
                switch response.result{
                case .success(let jsonData):
                    print("getRepo json : ",jsonData)
                    print("type : ", type(of: jsonData))
                    
                case .failure:
                    print("getRepo fail")
                }
            })
    }
    
    func getUser(){
        let url = "https://api.github.com/user"
        let accessToken = KeychainSwift().get("accessToken") ?? ""
        let headers:HTTPHeaders = ["Accept" : "application/vnd.github.v3+json", "Authorization":"token \(accessToken)"]
        AF.request(url, method: .get, parameters:[:], headers: headers)
            .responseJSON(completionHandler: {(response) in
                switch response.result{
                case .success(let jsonData):
//                    print(json as! [String: Any])
                    print(jsonData)
                    let jsonDictionary = [jsonData]
                    for i in jsonDictionary{
                        if let obj = i as? [String: Any]{
                            if let result = obj["html_url"]{
                                let url = String(describing: result) // Any to String
                                print("방문할 URL : ", url)
                                githubURL = url
                                self.fetch()
                            }
                            
                        }
                    }
                    
                case .failure:
                    print("getUser failure")
                }
            })
    }
}

struct User : Codable{
    var url:String;
    enum CodingKeys:String, CodingKey {
        case url = "html_url"
    }
}

