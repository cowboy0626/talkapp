//
//  ChatRoomVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 9. 3..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Outlets
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    // 변수
    var uid: String!
    var chatRooms: [ChatModel]! = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // uid 지정
        self.uid = Auth.auth().currentUser?.uid
        
        // 데이터가져오기
        self.getChatRoomList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 탭바 이동 시 데이터 갱신내용이 그대로 잘 반영되도록 하기
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    // 내가 포함된 채팅룸 가져오기 (chatrooms 안에 내 아이디가 있는 것이 있는 것 찾아오기)
    func getChatRoomList(){
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (dataSnapshot) in
            // 초기화
            self.chatRooms.removeAll()
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                
                if let chatRoomDic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    self.chatRooms.append(chatModel!)
                }
            }
            self.chatRoomTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "ChatRoomCell", for: indexPath) as! ChatRoomCell
        
        // 상대방 정보 가져오기
        var targetUid: String?
        for item in chatRooms[indexPath.row].users {
            if(item.key != self.uid){
                targetUid = item.key
            }
        }
        Database.database().reference().child("users").child(targetUid!).observeSingleEvent(of: DataEventType.value) { (dataSnapshot) in
            // 맵핑시키기 (결과값이 프로필이미지, 유저이름 등이므로 루프를 돌지 않고 맵핑을 시킴
            let userModel = UserModel()
            userModel.setValuesForKeys(dataSnapshot.value as! [String:AnyObject])
            
            // 프로필 이미지 다운로드 및 정보맵핑하기
            cell.chatRoomNameLabel.text = userModel.userName
            let url = URL(string: userModel.profileImageUrl!)
            cell.profileImageView.layer.cornerRadius = 50 / 2
            cell.profileImageView.layer.masksToBounds = true
            cell.profileImageView.kf.setImage(with: url)
            
            let lastMessageKey = self.chatRooms[indexPath.row].comments.keys.sorted(){$0>$1} // 오름차순, 내림차순은 $0<$1
            cell.lastMessageLabel.text = self.chatRooms[indexPath.row].comments[lastMessageKey[0]]?.message
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}

class ChatRoomCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
}
