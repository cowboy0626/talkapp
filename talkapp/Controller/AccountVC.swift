//
//  AccountVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 9. 8..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase

class AccountVC: UIViewController {

    // Outlets
    @IBOutlet weak var inputStatusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //메시지 상태보기버튼 이벤트핸들러 추가
        inputStatusButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showAlert(){
        let alertController = UIAlertController(title: "상태메시지", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "상태메시지를 입력해주세요"
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            
            // 상태메시지 입력필드 생성
            if let textField = alertController.textFields?.first {
                let dic = ["comment" : textField.text]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        
        // 동작정의
        self.present(alertController, animated: true, completion: nil)
    }


}
