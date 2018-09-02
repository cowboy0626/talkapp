//
//  ViewController.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 7. 29..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit

// UI 프로그램으로 그리기 위한 모듈
import SnapKit

// Remote config 사용위해 firebase 모듈 import
import Firebase

class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 서버에 설정값 받아오는 간격으로 0이면 앱을 켤때마다 값을 받아옴, 3600을 넣으면 1시간 마다 요청
        let expirationDuration = 0
        
        // 원격설정코드
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings
        
        // 서버와 연결이 안될 경우 원격설정기본값으로 사용할 값 설정
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // 서버로부터 설정값 받아와서 처리하기 (이렇게 한번 가져오면 앱의 다른 컨트롤러에서도 사용할 수 있음)
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        
        // 박스만들어서 센터에 위치시키기
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        
        box.image = #imageLiteral(resourceName: "loading-icon")
        // self.view.backgroundColor = UIColor(hex: "#000000")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayWelcome(){

        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        // 값이 있을 경우 앱종료하고 그렇지 않으면 로그인버튼 표시
        if caps {
            print("값있음")
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                // 앱종료
                exit(0)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.present(loginVC, animated: false, completion: nil)
        }
        self.view.backgroundColor = UIColor(hex: color!)
        
    }


}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        
        // 기존은 0인데, #다음부터 읽기 위해 1로 바꿈
        scanner.scanLocation = 1
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
