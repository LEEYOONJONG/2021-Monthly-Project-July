import UIKit
import Alamofire
import SwiftSoup

class ViewController: UIViewController {

    let url = "https://github.com/LEEYOONJONG"
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginClicked(_ sender: Any) {
        fetch()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

extension ViewController{
    func fetch(){
        AF.request(self.url).responseString { response in
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
}

