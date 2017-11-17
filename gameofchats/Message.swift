//
//  Message.swift
//  gameofchats
//
//  Created by Денис Попов on 17.11.2017.
//  Copyright © 2017 Денис Попов. All rights reserved.
//

import UIKit

class Message : NSObject {
    @objc var fromId : String?
    @objc var text : String?
    @objc var timestamp : String?
    @objc var toId : String?
}
