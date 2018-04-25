//
//  Quip.swift
//  Quick Quips
//
//  Created by Taylor Howard on 5/29/17.
//  Copyright © 2017 Taylor Howard. All rights reserved.
//

import Foundation
import RealmSwift


class Quip: Object {
    @objc dynamic var name = ""
    @objc dynamic var text = ""
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var category = ""
    @objc dynamic var type = ""
    @objc dynamic var frequency = 0
    @objc dynamic var createDate = Date()

    override class func primaryKey() -> String {
        return "id"
    }

    @objc convenience init(name: String, type: String, text: String, category: String?) {
        self.init()
        self.name = name
        self.type = type
        self.text = text
        self.category = category ?? ""
    }
}
