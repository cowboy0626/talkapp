//
//  ChatVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 8. 27..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    // Variables
    var uid: String?
    var chatRoomId: String?
    public var targetUid: String? // 채팅대상ID
    var targetModel: UserModel? // 채팅대상정보 저장용 모델
    var comments: [ChatModel.Comment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UID 설정
        self.uid = Auth.auth().currentUser?.uid
        
        // 채팅룸 중복여부 체크
        checkRoomDuplication()
            
        // 전송버튼에 createRoom 이벤트핸들러 연결하기
        sendButton.addTarget(self, action: #selector(createRoomOrSendMessage), for: .touchUpInside)
        
        // 탭바 숨기기
        self.tabBarController?.tabBar.isHidden = true
        
        // 다른곳 누르면 키보드 숨기기 처리
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 옵저버 삭제처리
        NotificationCenter.default.removeObserver(self)
        // 탭바 보이기
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 키보드 통제옵저버
    override func viewWillAppear(_ animated: Bool) {
        // 키보드 나타날때 확인하는 로직
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        // 키보드 사라질 때 확인하는 로직
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 공간만들기 함수 (채팅을 처음 시작하면 Room을 만듦)
    @objc func createRoomOrSendMessage(){
        
        // 딕셔너리형태로 데이터 만들기
        let roomInfo: Dictionary<String, Any> = [ "users" : [
                uid!: true,
                targetUid!: true
            ]
        ]
        
        // 채팅방 중복체크 후 방이 없을 경우에는 방을 생성하고, 방이 있을 경우에는 해당 방에 메시지 내용을 추가함
        if(chatRoomId == nil) {
            
            // 메시지 버튼비활성화 (중복체크 후 활성화시킴)
            self.sendButton.isEnabled = false
            
            // 첫번째 방법을 쓰면 방을 만들고 난후 다시 나왔다 들어가야 반영이 됨. 방 만들고 나서 callback 함수로 만드는 것이 좋은 방법임
            // Database.database().reference().child("chatrooms").childByAutoId().setValue(roomInfo)
            Database.database().reference().child("chatrooms").childByAutoId().setValue(roomInfo) { (err, ref) in
                if(err == nil){
                    self.checkRoomDuplication()
                }
            }
        } else {
            let message: Dictionary<String,Any> = [
                "uid": uid!,
                "message": self.inputTextField.text!
            ]
            
            // 코멘트데이터 추가
            Database.database().reference().child("chatrooms").child(chatRoomId!).child("comments").childByAutoId().setValue(message) { (err, ref) in
                if(err == nil){
                    self.inputTextField.text = ""
                }
            }
        }
        
    }
    
    // 채팅룸 중복체크하기 (유저이름으로 로그인해서 해당 유저의 이름으로 
    func checkRoomDuplication(){
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (dataSnapshot) in
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                
                // 룸정보 확인 (내아이디로 만들어진 채팅방 중 상대방 이름이 있는지여부 체크)
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    if(chatModel?.users[self.targetUid!] == true){
                        // 방키를 받아 온 후 메시지 보내기 버튼 활성화
                        self.chatRoomId = item.key
                        self.sendButton.isEnabled = true
                        // self.getMessageList() // 기존 사용자와 무관하게 그냥 메시지 목록 가져오는 것
                        // 대화상대방 정보를 가져오면서 그에 맞는 메시지 목록 가져오기
                        self.getTargetInfo()
                    }
                }
            }
        }
    }
    
    // 대화상대방 정보가져온 후 그에 맞는 목록을 가져오기
    func getTargetInfo(){
        Database.database().reference().child("users").child(self.targetUid!).observeSingleEvent(of: DataEventType.value) { (dataSnapshot) in
            self.targetModel = UserModel()
            self.targetModel?.setValuesForKeys(dataSnapshot.value as! [String:Any])
            self.getMessageList()
        }
    }
    
    // 메시지 가져오기
    func getMessageList(){
        Database.database().reference().child("chatrooms").child(self.chatRoomId!).child("comments").observe(DataEventType.value) { (dataSnapshot) in
            // 목록 초기화
            self.comments.removeAll()
            
            // 목록 가져오기
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.messageTableView.reloadData()
            self.scrollMessage()
        }
    }
    
    // 테이블 그리기 프로토콜 구현
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 작성자ID에 따라 분기
        if(self.comments[indexPath.row].uid == self.uid){
            let cell = messageTableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.messageLabel?.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0 // 여러줄이 나오도록
            return cell
        } else {
            let cell = messageTableView.dequeueReusableCell(withIdentifier: "TargetMessageCell", for: indexPath) as! TargetMessageCell
            // 프로필이미지 표시
            let profileImageUrl = URL(string: (self.targetModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: profileImageUrl!) { (data, res, err) in
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data: data!)
                    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2 // 원형처리
                    cell.profileImageView.clipsToBounds = true // 이미지 크기 사이즈에 맞게 들어가게
                }
            }.resume()
    
            cell.userNameLabel.text = self.targetModel?.userName
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 내용에 맞게 row height 자동조정
        return UITableViewAutomaticDimension
    }
    
    // 메시지 입력후 처리로직
    func afterMessageSent(){
        self.inputTextField.text = ""
    }
    
    // 키보드 보이기 처리
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.scrollMessage()
        }
    }
    // 키보드 숨기기 처리
    @objc func keyboardWillHide(notification: Notification){
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    // 키보드 숨기기 처리
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    // 페이지 사이즈에 맞게 스크롤하기
    func scrollMessage(){
        if self.comments.count > 0 {
            self.messageTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    
}

class TargetMessageCell: UITableViewCell{
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
}
