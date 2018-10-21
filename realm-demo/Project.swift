//
//  Project.swift
//  realm-demo
//
//  Created by Patrick Laplante on 10/21/18.
//  Copyright © 2018 Patrick Laplante. All rights reserved.
//

import Foundation
import RealmSwift

/*
 ProjectName, ClientName, InspectorName and Comments (memo)
 */

class Project: Object {
    
    @objc dynamic var projectId: String = UUID().uuidString
    @objc dynamic var owner: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var clientName: String = ""
    @objc dynamic var inspectorName: String = ""
    @objc dynamic var comments: String = ""
    @objc dynamic var timestamp: Date = Date()

    override static func primaryKey() -> String? {
        return "projectId"
    }
}
