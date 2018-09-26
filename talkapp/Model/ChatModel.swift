//
//  ChatModel.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 8. 28..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    
    /* 1:1 채팅만 가능한 모델
    var uid: String?
    var targetUid: String? */
    
    public var users: Dictionary<String, Bool> = [:] // 채팅방에 참여한 사람들의 목록
    public var comments: Dictionary<String, Comment> = [:] // 채팅방 대화내용
    
    // Mapper 처리
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment: Mappable {
        public var uid: String?
        public var message: String?
        public var readUsers: Dictionary<String, Bool> = [:]
        public var timeStamp: Int?
        public required init?(map: Map) {
            
        }
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timeStamp <- map["time-stamp"]
            readUsers <- map["readUsers"]
        }
    }
    
}
