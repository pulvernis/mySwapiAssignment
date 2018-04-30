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
        
        SwapiSearch.getAllPeopleInPageSwapiApi (fromPage: 1, getAllNextPages: false){ 
            SwapiSearch.getAllPeopleInPageSwapiApi(fromPage: 2, getAllNextPages: false){
                modelShared.firstLoadingPeopleAmount = modelShared.people.count // 2 pages = 20 characters
                
                // Two Ways of getting rest characters:
                // 1. more efficient way - iterate the number of pages and make call api (but assume 10 characters in each page)
                if let totalPagesPeople =  modelShared.totalPagesOfPeopleInSwapiApi{
                    var countToEndOfPages = 3
                    while countToEndOfPages <= totalPagesPeople {
                        SwapiSearch.getAllPeopleInPageSwapiApi(fromPage: countToEndOfPages, getAllNextPages: false){}
                        countToEndOfPages+=1
                    }
                 }
                // 2. less efficient way - after every call check if "next" in swapi page contain next page url and just then call it (slow loading)
                //SwapiSearch.getAllPeopleInPageSwapiApi(fromPage: 3, getAllNextPages: true){}
                
                //get 20 first images:
                if let firstLoadingPeopleAmount = modelShared.firstLoadingPeopleAmount {
                    for index in 0..<firstLoadingPeopleAmount {
                        let characterName = modelShared.people[index].name
                        DuckDuckGoSearchImage.image(for: characterName) { _ in
                            // Each image added by name into dict called imageByCharacterNameDict in ModelShared automatically by this func
                            // when it get filled with amount of firstLoadingPeopleAmount, if it happened after all 87 people arrived - i stop indicator, reload tbl, and replace image alpha with tbl (show tbl) or if it will happened before all people arrived i will do it in people didSet by Notification post
                            if modelShared.imageByCharacterNameDict.count == firstLoadingPeopleAmount &&
                                modelShared.people.count == modelShared.totalNumOfPeopleInSwapiApi {
                                NotificationCenter.default.post(name: .stopIndicatorReloadMyTbl, object: nil)
                            }
                        }
                    }
                }
            }
        }
        
        // TODO: maybe it will be better to load data api to ModelShared when user click first time on cell/All Movies button, because now it's doing alot of work in the background here (in viewDidLoad), on the other hand it will make user to wait on every time he click on cell/All Movie btn
        SwapiSearch.getSwapiTypeFromUrlPage(swapiType: .VEHICLES, fromPage: 1, getAllNextPages: true)
        SwapiSearch.getSwapiTypeFromUrlPage(swapiType: .HOME_WORLD, fromPage: 1, getAllNextPages: true)
        SwapiSearch.getSwapiTypeFromUrlPage(swapiType: .MOVIES, fromPage: 1, getAllNextPages: true)
        SwapiSearch.getSwapiTypeFromUrlPage(swapiType: .STAR_SHIPS, fromPage: 1, getAllNextPages: true)
        
        
        // MARK: NotificationCenter - addObserver/ listener
        // 1. Observe to ModelShared people:[Characters] and to DuckDuckGoSearchImage.image in viewDidLoad() when get all people && 20 first images
        // 2. Observe to ModelShared people:[Characters] when get all the rest images
        NotificationCenter.default.addObserver(self, selector: #selector(stopIndicatorReloadMyTbl(notification:)), name: .stopIndicatorReloadMyTbl, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMyTbl(notification:)), name: .reloadMyTbl, object: nil)
    }
    
    // TODO: Remove observer when class is deallocate from memory, but HVC is always live?
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Mark: NotificationCenter -  Two Methods
    func stopIndicatorReloadMyTbl(notification: NSNotification) {
        tableview.reloadData()
        self.indicator.stopAnimating()
        
        UIView.animate(withDuration: 1, animations: {
            self.imageView.alpha = 0
            self.tableview.alpha = 1.0
        })
    }
    
    func reloadMyTbl(notification: NSNotification) {
        tableview.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelShared.people.count
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


