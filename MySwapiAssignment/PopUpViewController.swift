//
//  PopUpViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 15/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

// presentViewController offers a mechanism to display a so-called modal view controller; i.e., a view controller that will take full control of your UI by being superimposed on top of a presenting controller.

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var characterBirthYearLbl: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 10
        
        //NotificationCenter.default.addObserver(forName: .characterBirthDay, object: nil, queue: nil,
                                               //using: passingDataOfCellNumber)
        if let index = modelShared.popUpViewIndexCellTapped {
            let character = modelShared.people[index]
            characterBirthYearLbl.text = character.birthYear
        }
        
    }
    
    // TODO: deinit doesn't execute when closePopUp() by dismiss() why? maybe retain cycle but where?
    // continue: i moved NotificationCenter.default.addObserver to Model and now deallocate (deinit) works 
    deinit {
        //NotificationCenter.default.removeObserver(self)
        print("deinit called")
    }
    
    /*func passingDataOfCellNumber(notification: Notification) -> Void {
        // TODO: every click on BD Button it's like making more and more post (passingDataOfCellNumber() is execute one more time in each click on BD button) even though i removeObserver every time i closePopUp() why?
        let rowNumber = notification.userInfo!["rowNumber"] as? Int
        if let index = rowNumber {
            let character = Model.shared.people[index]
            characterBirthYearLbl.text = character.birthYear
        }
        
        
    }*/

    
    @IBAction func closePopUp(_ sender: UIButton) {
        
        //NotificationCenter.default.removeObserver(self)
        dismiss(animated: true, completion: nil)
    
    }

}
