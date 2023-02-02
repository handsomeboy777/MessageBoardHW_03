//
//  LocalDatabase.swift
//  MessageBoard
//
//  Created by imac-2437 on 2023/1/18.
//

import Foundation
import RealmSwift

class LocalDatabase: NSObject {
    static let shared = LocalDatabase()
    
    func addMessage(message: Message) {
        let realm = try! Realm()
        
        let table = MessageTable()
        table.name = message.name
        table.content = message.content
        table.timestamp = message.timestap
        
        do {
            try realm.write {
                realm.add(table)
                print("File URL：\(String(describing: realm.configuration.fileURL?.absoluteString))")
            }
        } catch {
            print("Realm Add Failed：\(error.localizedDescription)")
        }
    }
    
    
    func deleteMessage(message: Message) {
        let realm = try! Realm()
        let deleteMessage = realm.objects(MessageTable.self).filter {
            $0.timestamp == message.timestap
        }.first
        
        do {
            try realm.write {
                realm.delete(deleteMessage!)
            }
        } catch {
            print("Realm Delete Failed：\(error.localizedDescription)")
        }
    }

}

class MessageTable: Object {
    
    @Persisted var name: String
    
    @Persisted var content: String
    
    @Persisted var timestamp: Int64
}
