//
//  SelectedFriendVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 9. 26..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectedFriendVC: UIViewController, UITableViewDataSource, UITableViewDelegate, BEMCheckBoxDelegate {

    // Outlets
    @IBOutlet weak var friendListTableView: UITableView!
    @IBOutlet weak var createRoomButton: UIButton!
    
    // Variables
    var friendsArray: [UserModel] = []
    var selectedFriends = Dictionary<String,Bool>() // 선택/비선택 친구상태목록정보
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 친구목록정보 가져오기
        // 데이터 가져와서 반영하기
        Database.database().reference().child("users").observe(DataEventType.value) { (dataSnapshot) in
            
            // 자기자신 UID확인 (목록에서 자기자신은 제외하기 위함)
            let myUid = Auth.auth().currentUser?.uid
            
            // 기존목록 초기화
            self.friendsArray.removeAll()
            
            // 새 데이터 가져오기
            for data in dataSnapshot.children {
                
                let friendData = data as! DataSnapshot
                let friendModel = UserModel()
                
                friendModel.setValuesForKeys(friendData.value as! [String : Any])
                
                // 내 아이디 걸르기 로직
                if(friendModel.uid == myUid){
                    continue
                }
                self.friendsArray.append(friendModel)
                
            }
            
            // 테이블 리로드하기 (이걸해야 업데이트된 데이터가 테이블에 반영됨)
            DispatchQueue.main.async {
                self.friendListTableView.reloadData()
            }
        }
        
        createRoomButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.friendListTableView.dequeueReusableCell(withIdentifier: "SelectedFriendCell", for: indexPath) as! SelectedFriendCell
        cell.nameLabel.text = friendsArray[indexPath.row].userName
        cell.profileImageView.kf.setImage(with: URL(string: friendsArray[indexPath.row].profileImageUrl!))
        // 체크박스설정
        cell.isSelectedCheckBox.delegate = self
        cell.isSelectedCheckBox.tag = indexPath.row
        
        return cell
    }
    
    // Checkbox 체크되었을 때 처리로직
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on {
            selectedFriends[self.friendsArray[checkBox.tag].uid!] = true
        } else {
            selectedFriends.removeValue(forKey: self.friendsArray[checkBox.tag].uid!)
        }
    }
    
    // 방생성
    @objc func createRoom(){
        var myUid = Auth.auth().currentUser?.uid
        selectedFriends[myUid!] = true
        let nsDic = selectedFriends as! NSDictionary
        Database.database().reference().child("chatrooms").childByAutoId().child("users").setValue(nsDic)
    }
    
}

// 셀클래스 정의
class SelectedFriendCell: UITableViewCell {
    @IBOutlet weak var isSelectedCheckBox: BEMCheckBox!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}
