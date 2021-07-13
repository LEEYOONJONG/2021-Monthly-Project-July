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
                let elements:Elements = try doc.select("#js-pjax-container > div.container-xl.px-3.px-md-4.px-lg-5 > div > div.flex-shrink-0.col-12.col-md-9.mb-4.mb-md-0 > div:nth-child(2) > div > div.mt-4.position-relative > div.js-yearly-contributions > div > div > div > svg > g > g:nth-child(43) > rect:nth-child(4)")
                print(elements)
                for i in elements{
                    print("-->", i)
                }
            }
            catch{
                print("error occured")
            }
        }
    }
}

