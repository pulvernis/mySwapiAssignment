//
//  HomeViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 24/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

let modelShared = ModelShared.shared

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        
        SwapiApiCharacterDetails.getAllPeopleInPageSwapiApi (fromPage: 1, getAllNextPages: true){}
        
        SwapiApiTypeDetails.getSwapiTypeFromUrlPage(swapiType: .VEHICLES, fromPage: 1, getAllNextPages: true)
        SwapiApiTypeDetails.getSwapiTypeFromUrlPage(swapiType: .HOME_WORLD, fromPage: 1, getAllNextPages: true)
        SwapiApiTypeDetails.getSwapiTypeFromUrlPage(swapiType: .STAR_SHIPS, fromPage: 1, getAllNextPages: true)
        SwapiApiTypeDetails.getSwapiTypeFromUrlPage(swapiType: .MOVIES, fromPage: 1, getAllNextPages: true)
        
        // MARK: NotificationCenter - addObserver/ listener
        NotificationCenter.default.addObserver(self, selector: #selector(stopIndicatorReloadTbl(notification:)), name: .stopIndicatorReloadTbl, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadImagesIntoTheirCells(notification:)), name: .reloadImagesIntoTheirCells, object: nil)
        
    }
    
    // Remove observer when class is deallocate from memory
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Mark: NotificationCenter -  Two Methods
    func stopIndicatorReloadTbl(notification: NSNotification) {
        self.indicator.stopAnimating()
        tableview.reloadData()
        modelShared.lastRowsUpdateWithImages = modelShared.imageByCharacterNameDict.count
        
        UIView.animate(withDuration: 1, animations: {
            self.imageView.alpha = 0
            self.tableview.alpha = 1.0
        })
    }
    
    func reloadImagesIntoTheirCells(notification: NSNotification) {
        var rowsIndexPathsForUpdate:[IndexPath] = []
        
        let startRowReload = modelShared.lastRowsUpdateWithImages
        let endRowReload = modelShared.imageByCharacterNameDict.count
        for index in startRowReload..<endRowReload {
            let rowIndexPathToUpdate = IndexPath(row: index, section: 0)
            rowsIndexPathsForUpdate.append(rowIndexPathToUpdate)
        }
        print(rowsIndexPathsForUpdate)
        tableview.reloadRows(at: rowsIndexPathsForUpdate, with: .automatic)
        modelShared.lastRowsUpdateWithImages = modelShared.imageByCharacterNameDict.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return modelShared.people.count
        return modelShared.totalNumOfPeopleInSwapiApi ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CharacterTableViewCell
        
        // MARK: Delegate-Style - Set the cell’s delegate to the controller itself.
        cell.delegate = self
        
        let characterInRow = modelShared.people[indexPath.row]
        cell.titleLabelCharacterName.text = "\(characterInRow.name)"
        cell.subTitleLabelCharacterGender.text = "Gender: \(characterInRow.gender)"
        // first optional if that key exist (character name)
        if let imageData = modelShared.imageByCharacterNameDict[characterInRow.name] {
            // second optional because value is Data? (can be nil)
            if let characterImageData = imageData {
                if let image = UIImage(data: characterImageData) {
                    cell.imageviewOfCharacter.image = image
                } else {
                    cell.imageviewOfCharacter.image = UIImage(named: "no_image.jpg")!
                }
            }
        } else {
            cell.imageviewOfCharacter.image = UIImage(named: "no_image.jpg")!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelShared.charcterRowTapped = modelShared.people[indexPath.row]
    }
    
    // MARK: Delegate-Style - The cell call this protocol method when the user taps the allMovie button
    func tableViewCellDidTapAllMoviesBtn(_ sender: CharacterTableViewCell) {
        guard let tappedIndexPath = tableview.indexPath(for: sender) else{ return }
        let tappedInt = tappedIndexPath.row
        modelShared.requestDataForCharacterMovies(rowNumberFromTbl: tappedInt )
        // performSegue is optional for using - in storyboard - instead of stretching segue line from the button, stretch it from the viewcontroller itself.. then add this extra line below 
        //performSegue(withIdentifier: "toAllMoviesCharacterSegue", sender: self)
    }
    
    func tableViewCellDidTapBDBtn(_ sender: CharacterTableViewCell) {
        guard let tappedIndexPath = tableview.indexPath(for: sender) else{ return }
        let characterIndexTapped = tappedIndexPath.row
        
        // MARK: PopUp by BD btn - NotificationCenter - post when click on BD btn
        // First.. post to observer in Model, then move to PopUpVC
        NotificationCenter.default.post(name: .characterBirthDay, object: nil, userInfo: ["rowNumber":characterIndexTapped])
        // MARK: Instantiate PopUpViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PopUpVCID")
        self.present(controller, animated: true, completion: nil)
    }
}


