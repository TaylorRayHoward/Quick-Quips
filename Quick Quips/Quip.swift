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
    dynamic var name = ""
    dynamic var text = ""
    dynamic var id = UUID().uuidString
    dynamic var category = ""
    dynamic var type = ""
    dynamic var frequency = 0
    dynamic var createDate = Date()

    override class func primaryKey() -> String {
        return "id"
    }

    convenience init(name: String, type: String, text: String, category: String?) {
        self.init()
        self.name = name
        self.type = type
        self.text = text
        self.category = category ?? ""
    }
}
