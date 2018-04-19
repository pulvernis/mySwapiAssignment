//
//  TableViewCellDelegate.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 08/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation

// MARK: Delegate-Style - protocol

// Delegate-style protocol for cell class
// Weak reference to the delegate object - Since weak references can only be used on classes, our protocol will have to declare “class” conformance.

// Add a delegate method for each action you want to track - in my case allMovie button. 
// I want to know when button is tapped, so I create a delegate function for him.

protocol TableViewCellDelegate : class {
    func tableViewCellDidTapAllMoviesBtn(_ sender: CharacterTableViewCell)
    func tableViewCellDidTapBDBtn(_ sender: CharacterTableViewCell)
    
}
