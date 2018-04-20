//
//  PassDataExplanation.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 19/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

/*
 Delegate - By Protocol:
 Somebody Feed Me: baby and mom
 Baby incapable of cooking food. he needs his mom’s help.
 
 1. Mom needs to know how to cook first.
 protocol TableViewCellDelegate : class {
    func tableViewCellDidTapBDBtn(_ sender: CharacterTableViewCell)
 }
 
 2. Create a mom who conforms to the Cook protocol
 class TableViewController: UITableViewController, TableViewCellDelegate {
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        3. Create a real baby in Mom and assign the delegate as the mom
        let cell = CharacterTableViewCell()
        cell.delegate = self
    }
    4. Mom do some functionality cooking for her baby when he want to eat
    func tableViewCellDidTapBDBtn(_ sender: CharacterTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let characterIndexTapped = tappedIndexPath.row
 
        // It took me quite a while to realize that I had to present the next view before i use NotificationCenter.default.post(), i understand now that the next viewcontroller must be initialized itself and the addObserver() that it could observe before post is sending to him
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PopUpVCID")
        self.present(controller, animated: true, completion: nil)
 
        NotificationCenter.default.post(name: .characterBirthDay, object: nil, userInfo: ["rowNumber":characterIndexTapped])
    }
 
 }
 
 class CharacterTableViewCell: UITableViewCell {
    5. Add an adult (delegate) to Baby who can cook for him instead.
    weak var delegate:TableViewCellDelegate?
    6. Now the baby can eat
    @IBAction func birthDayBtn(_ sender: UIButton) {
        delegate?.tableViewCellDidTapBDBtn(self)
    }
 }
 
 */

