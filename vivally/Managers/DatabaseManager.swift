//
//  DatabaseManager.swift
//  vivally
//
//  Created by Ryan Levels on 9/13/23.
//

import UIKit

protocol DatabaseManagerDelegate {
    func sessionDBFinishedLoading()
}

class DatabaseManager: NSObject {
    static let sharedInstance = DatabaseManager()

    var delegate: DatabaseManagerDelegate? = nil

    func sessionDBLoadComplete() {
        delegate?.sessionDBFinishedLoading()
    }
}
