import UIKit
import Alamofire
import SwiftSoup

class ViewController: UIViewController {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginClicked(_ sender: Any) {
        LoginManager.shared.requestCode()
//        LoginManager.shared.fetch()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
