//
// Created by Taylor Howard on 5/29/17.
// Copyright (c) 2017 Taylor Howard. All rights reserved.
//

import RealmSwift
import Foundation

enum Environment {
    case Application
    case Test
}

class DBHelper {
    var realm: Realm
    static let sharedInstance = DBHelper(inEnvironment: .Application)
    static let testInstance = DBHelper(inEnvironment: .Test)

    init(inEnvironment env: Environment) {
        if (env == .Application) {
            realm = try! Realm()
        } else if (env == .Test) {
            realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TestRealm"))
        } else {
            realm = try! Realm()
        }
    }

    func getAll(ofType type: Object.Type) -> Results<Object> {
        return realm.objects(type)
    }

    func writeObject(objects: [Object]) {
        try! realm.write {
            for o in objects {
                realm.add(o)
            }
        }
    }
    
    func getQuips() -> Results<Quip> {
        return realm.objects(Quip.self)
    }
    
    func deleteObject(_ object: [Object]) {
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func incrementFrequency(for quip: Quip){
        try! realm.write {
            quip.frequency += 1
        }
    }
}
