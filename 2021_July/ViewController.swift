import UIKit
import Alamofire
import SwiftSoup
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginClicked(_ sender: Any) {
        LoginManager.shared.requestCode()
        //        LoginManager.shared.fetch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        date.minute = 08
        print("date : ",date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "LocalNoti", content: notiContent, trigger: trigger)
        
        let a = 1;
        if (a==1){
            userNotificationCenter.add(request) { error in
                if let error = error {
                    print(error)
                }
            }
        }

    }
    
}

extension ViewController{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.list, .badge, .sound, .banner])
                completionHandler([.alert, .badge, .sound])
    }
    
}
