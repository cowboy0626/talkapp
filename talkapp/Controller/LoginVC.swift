//
//  LoginVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 8. 8..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    // 원격에서 스타일가져오기
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 기본으로 로그아웃되기
        try! Auth.auth().signOut()
        
        // Status bar 추가하기
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (maker) in
            maker.right.top.left.equalTo(self.view)
            maker.height.equalTo(20)
        }
        
        // 원격에서 스타일가져오기
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signupButton.backgroundColor = UIColor(hex: color)

        // 버튼에 이벤트 걸기
        signupButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
        // 로그인버튼에 로그인이벤트 핸들러 연결하기
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        
        // 로그인 후 다음화면으로 연결하기
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil){
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainTBC") as! UITabBarController
                self.present(view, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 회원가입 링크걸기
    @objc func presentSignup(){
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.present(vc, animated: true, completion: nil)
        
    }

    // 로그인 처리 이벤트 핸들러
    @objc func loginEvent(){
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            // 에러상황에만 alert 처리함 (로그인 된 경우에는 리스너를 이용해서 처리할 것이므로)
            if(error != nil) {
                let alert = UIAlertController(title: "로그인 에러", message: error.debugDescription, preferredStyle: .alert)
                
                // 확인버튼 추가
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                
                // Alert 표시
                self.present(alert, animated: true, completion: nil)
            }
        }
    }


}
