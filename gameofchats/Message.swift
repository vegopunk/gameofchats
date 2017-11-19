//
//  Message.swift
//  gameofchats
//
//  Created by Денис Попов on 17.11.2017.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit
import Firebase

class Message : NSObject {
    @objc var fromId : String?
    @objc var text : String?
    @objc var timestamp : NSNumber?
    @objc var toId : String?
    
    @objc var imageUrl : String?
    @objc var imageHeight : String?
    @objc var imageWidth : String?
    
    @objc var videoUrl : String?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
     }
    
    init(dictionary: [String: Any]) {
        super.init()
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? String
        imageWidth = dictionary["imageWidth"] as? String
        
        videoUrl = dictionary["videoUrl"] as? String
    }
    
}
