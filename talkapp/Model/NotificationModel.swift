//
//  NotificationModel.swift
//  talkapp
//
//  Created by muhyunkim on 2018. 9. 5..
//  Copyright © 2018년 muhyunkim. All rights reserved.
//

import ObjectMapper

class NotificationModel: Mappable {
    
    public var to: String?
    public var notification: Notification = Notification()
    public var data: Data = Data()
    
    init(){
        
    }
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    // 푸시알림 
    class Notification: Mappable {
        public var title: String?
        public var text: String?
        
        init() {
            
        }
        required init?(map: Map) {
            
        }
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }
    
    // 푸시메시지에서 보낼 데이터
    class Data: Mappable {
        public var title: String?
        public var text: String?
        init() {
            
        }
        required init?(map: Map) {
            
        }
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }

}
