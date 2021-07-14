import Foundation
import KeychainSwift
import Alamofire
import UIKit
import SwiftSoup

var githubURL:String=""
class LoginManager {
    
    static let shared = LoginManager()
    
    private init() {}
    private let client_id = "ac6468124c1c1e12dd21"
    private let client_secret = "a0c30c5dfaa7224a0928c3635250d3ad26bf709f"
    
    func fetch(url:String){
        AF.request(url).responseString { response in
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
                        }
                    }
                }
                
            }
            catch{
                print("error occured")
            }
        }
    }
    
    func requestCode() {
        let scope = "user"
        let urlString = "https://github.com/login/oauth/authorize?client_id=\(client_id)&scope=\(scope)"
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    func requestAccessToken(with code: String){
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
                    }
                case let .failure(error):
                    print(error)
                }
            }
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
                                self.fetch(url: url)
                            }
                            
                        }
                    }
                    
//                    if JSONSerialization.isValidJSONObject(json) {
//                            print("Valid Json")
//                        } else {
//                            print("InValid Json")
//                        }
                    
//                    let decoder = JSONDecoder()
//                    let data = jsonData // JSON을 Data로 만들기
//                    if let data = data, let myUser = try? decoder.decode(User.self, from:data) {
//                        print("myUser.url : ",myUser.url)
//                        print("myData : ", myUser)
//                    }
                    
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
