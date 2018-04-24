//
//  HomeViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 24/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TableViewCellDelegate {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    // singleton Model
    @IBOutlet weak var tableview: UITableView!
    let modelShared = Model.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        
        modelShared.getAllPeopleInPageSwapiApi (pageNumber: 1){ [unowned self] in
            self.modelShared.getAllPeopleInPageSwapiApi(pageNumber: 2){ [unowned self] in
                self.tableview.reloadData() // load 2 first pages
                
                //get 20 first images into cells
                for character in self.modelShared.people {
                    let characterName = character.name
                    DuckDuckGoSearchController.image(for: characterName) { [unowned self] result in
                        self.tableview.reloadData()
                        self.indicator.stopAnimating()
                        
                        UIView.animate(withDuration: 1, animations: {
                            self.imageView.alpha = 0
                            self.tableview.alpha = 1.0
                            
                        })
                    }
                    
                }
                
                // ** although user need to wait if he want to scroll right away he gets 2 first pages quickly than if i first load all characters into Model and then reload tbl
                if let totalPagesPeople =  self.modelShared.totalPagesOfPeopleInSwapiApi{
                    var countToEndOfPages = 3
                    while countToEndOfPages <= totalPagesPeople {
                        self.modelShared.getAllPeopleInPageSwapiApi(pageNumber: countToEndOfPages) {}
                        countToEndOfPages+=1
                    }
                }
            }
        }
        
        // TODO: maybe it will be better to load data api to Model when user click first time on cell/All Movies button, because now it's doing alot of work in the background here (in viewDidLoad)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .VEHICLES, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .HOME_WORLD, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .MOVIES, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .STAR_SHIPS, fromPage: 1, getAllNextPages: true)
        
        
        // MARK: NotificationCenter - addObserver/ listener
        /* Observe to 2 post from model:
         1. people:[Character] change and his count equal to totalNumOfPeopleInSwapiApi
         2. imageByCharacterNameDict: [String: UIImage] change and equal to people.count so he notify that all images arrived
         */
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataInTbl(notification:)), name: .reloadTbl, object: nil)
        
    }
    
    // TODO: Remove observer when class is deallocate from memory, but TVC is always live?
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Mark: NotificationCenter - Method
    func reloadDataInTbl(notification: NSNotification) {
        print("notified tbl")
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
        
        let characterInRow = Model.shared.people[indexPath.row]
        cell.titleLabelCharacterName.text = "\(characterInRow.name)"
        cell.subTitleLabelCharacterGender.text = "Gender: \(characterInRow.gender)"
        //Load the right image for each cell, if we didn't get one, set the image to be "no_image.jpg"
        for (name, characterImage) in self.modelShared.imageByCharacterNameDict {
            if name == characterInRow.name {
                cell.imageviewOfCharacter.image = characterImage
                return cell
            }
        }
        let image: UIImage = UIImage(named: "no_image.jpg")!
        cell.imageviewOfCharacter.image = image
        
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
        // performSegue is optional too - but in storyboard - instead of stretching segue line from the button, stretch it from the viewcontroller itself.. then add this extra line below 
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
    
    // If i had to deal with a lot of data i will load part of the data in viewDidload() and load more data every time user scroll to the last cell that filled
    /*func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
     let lastElement = modelShared.people.count - 1
     if indexPath.row == lastElement {
     // handle your logic here to get more items, add it to dataSource and reload tableview
     }
     
     }*/
    
}

class CharacterTableViewCell: UITableViewCell {
    
    // MARK: Delegate-Style - property
    // Add delegate property to custom cell class. Make it weak and optional.
    // Then, wire up the button action to method within the cell to call these delegate method
    
    weak var delegate:TableViewCellDelegate?
    
    @IBOutlet weak var titleLabelCharacterName: UILabel!
    
    @IBOutlet weak var subTitleLabelCharacterGender: UILabel!
    
    @IBOutlet weak var imageviewOfCharacter: UIImageView!
    
    @IBOutlet weak var allMoviesBtn: UIButton!
    
    @IBAction func allMoviesCharacterTappedBtn(_ sender: UIButton) {
        delegate?.tableViewCellDidTapAllMoviesBtn(self) // (self -> CharacterTableViewCell)
    }
    
    @IBAction func birthDayBtn(_ sender: UIButton) {
        delegate?.tableViewCellDidTapBDBtn(self)
    }
    
}

// MARK: NotificationCenter - extension to Notification.Name
extension Notification.Name {
    static let characterBirthDay = Notification.Name("characterBirthDay")
    static let reloadTbl = Notification.Name("reloadTbl")
    
}

func setView(view: UIView, hidden: Bool) {
    UIView.transition(with: view, duration: 2, options: .transitionCrossDissolve, animations: {
        view.isHidden = hidden
    })
}
