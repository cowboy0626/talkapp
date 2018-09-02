//
//  SignupVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 8. 8..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase

class SignupVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // Outlets
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var addImageView: UIImageView!
    
    // Variables
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remote Config를 활용해서 Statusbar 색상바꿔주기
        // Status 바 추가 및 크기설정
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (maker) in
            maker.right.top.left.equalTo(self.view)
            maker.height.equalTo(20)
        }
        // 원격에서 스타일가져오기
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        signupButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
        // addPhoto이미지 이벤트핸들러 (이미지를 버튼처럼 만들기)
        addImageView.isUserInteractionEnabled = true
        addImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentImagePicker)))
        
        // 회원가입버튼 이벤트핸들러
        signupButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func signupEvent(){
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            
            if ((result?.user) != nil) {
                let uid = result?.user.uid
                
                // 이미지정보 획득 및 저장 (이미지 품질은 예제용 이미지가 크기 때문에 0.1로함, 교육내용은 old 버전임)
                let profileImage = UIImageJPEGRepresentation(self.addImageView.image!, 0.1)
                let imageRef = Storage.storage().reference().child("profileImages").child(uid!)
                imageRef.putData(profileImage!, metadata: nil, completion: { (data, error) in
                    imageRef.downloadURL(completion: { (url, error) in
                        let values = ["userName": self.nameTextField.text, "profileImageUrl" : url?.absoluteString, "uid": Auth.auth().currentUser?.uid]
                        Database.database().reference().child("users").child(uid!).setValue(values)
                        self.dismiss(animated: true, completion: nil)
                    })
                })
                
            }
            if (error != nil) {
                print(error?.localizedDescription as Any)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func cancelEvent(){
        self.dismiss(animated: true, completion: nil)
    }
    
    // 이미지 픽커뷰 표시
    @objc func presentImagePicker(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    // 이미지 선택 후 처리 프로토콜 구현
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        addImageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }

}
