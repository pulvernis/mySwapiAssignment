//
//  Utility.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 26/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation

// MARK: NotificationCenter - extension to Notification.Name
extension Notification.Name {
    static let characterBirthDay = Notification.Name("characterBirthDay")
    static let stopIndicatorReloadTbl = Notification.Name("stopIndicatorReloadTbl")
    static let reloadImagesIntoTheirCells = Notification.Name("reloadImagesIntoTheirCells")
}
