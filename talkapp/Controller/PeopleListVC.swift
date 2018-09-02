//
//  PeopleListVC.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 8. 25..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class PeopleListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // 변수
    var friendsArray: [UserModel] = []
    var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블뷰 및 테이블뷰셀 코드로 생성
        friendsTableView = UITableView()
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(PeopleCell.self, forCellReuseIdentifier: "FriendCell")
        self.view.addSubview(friendsTableView)
        
        // 테이블뷰 코드로 디자인
        friendsTableView.snp.makeConstraints { (maker) in
            // 상단 20에 위치
            maker.top.equalTo(view).offset(20)
            maker.left.right.bottom.equalTo(view)
        }
        
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
                self.friendsTableView.reloadData()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 셀 생성
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! PeopleCell
        
        // 이미지뷰 구성
        let profileImageView = cell.profileImageView!
        profileImageView.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(cell)
            maker.left.equalTo(cell).offset(10) // margin 10
            maker.height.width.equalTo(50)
        }
        URLSession.shared.dataTask(with: URL(string: friendsArray[indexPath.row].profileImageUrl!)!) { (data, response, error) in
            DispatchQueue.main.async {
                profileImageView.image = UIImage(data: data!)
                profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
                profileImageView.clipsToBounds = true
            }
            }.resume()
        
        // 성명 레이블 구성
        let nameLabel = cell.userNameLabel!
        nameLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(cell)
            maker.left.equalTo(profileImageView.snp.right).offset(30)
        }
        nameLabel.text = friendsArray[indexPath.row].userName
        
        return cell
        
    }
    
    // 행선택 시 링크
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 뷰컨트롤러 정의
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC
        
        // 다음VC에 선택한 대상인자값으로 넘기기
        chatVC?.targetUid = self.friendsArray[indexPath.row].uid
        
        // 링크걸기 (navigation controller를 이용하기 때문에 push, pop을 이용 - 이렇게 하면 왼쪽에서 밀려서 나옴)
        self.navigationController?.pushViewController(chatVC!, animated: true)
        
    }
    
    // 행 높이 코드로 조절하기
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

// 셀 클래스 정의 (재사용을 통해 메모리 낭비를 막을 수 있음. 기존 방법에 비해) 
class PeopleCell: UITableViewCell {
    
    var profileImageView: UIImageView! = UIImageView()
    var userNameLabel: UILabel! = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(profileImageView)
        self.addSubview(userNameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
