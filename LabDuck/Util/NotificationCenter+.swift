//
//  NotificationCenter+.swift
//  LabDuck
//
//  Created by 정종인 on 5/24/24.
//

import Foundation

extension Notification.Name {
    static let documentsChanged = Notification.Name("documentsChanged")
}

extension NotificationCenter {
    public func sendDocumentsChanged() {
        self.post(name: .documentsChanged, object: nil, userInfo: [:])
    }
}
