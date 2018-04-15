//
//  TableViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 30/03/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

/* about this project:
    - Model:
    1. Class Using Singleton:
    2. Struct of Character - get append to property class (array of Characters called people)
    3. Using Alamofire:
        A. getAllPeopleInPageSwapiApi() - method with @escaping closure
        B. getAllMoviesUrlsAndNamesFromApi()
 
 
*/

import UIKit

// Make UITableViewController conform to the protocol

class TableViewController: UITableViewController, TableViewCellDelegate {
    
    // singleton Model
    let modelShared = Model.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelShared.getAllPeopleInPageSwapiApi (pageNumber: 1){
            self.modelShared.getAllPeopleInPageSwapiApi(pageNumber: 2){
                self.tableView.reloadData() // reload 2 pages
                // ** there is problem here because user need to wait if he want to scroll,
                // ** on the other hand, user get 2 first pages quickly then if i don't reload tbl in here.
                if let totalPagesPeople =  self.modelShared.totalPagesOfPeopleInSwapiApi{
                    var countToEndOfPages = 3
                    while countToEndOfPages <= totalPagesPeople {
                        self.modelShared.getAllPeopleInPageSwapiApi(pageNumber: countToEndOfPages) {}
                        countToEndOfPages+=1
                    }
                }
            }
        }
        
        // TODO: maybe it will be better to load data api to Model when user click first time on cell/All Movies button, because doing too much work on background here (in viewDidLoad)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .VEHICLES, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .HOME_WORLD, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .MOVIES, fromPage: 1, getAllNextPages: true)
        modelShared.getSwapiTypeFromUrlPage(swapiType: .STAR_SHIPS, fromPage: 1, getAllNextPages: true)
        
        
        // MARK: NotificationCenter - addObserver/ listener
        
        NotificationCenter.default.addObserver(self, selector: #selector(characterBD(notification:)), name: .characterBirthDay, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(allCharactersArrived(notification:)), name: .allCharactersArrivedFromSwapiToModel, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Mark: NotificationCenter - Methods
    
    func characterBD(notification: NSNotification) {
        print("notified")
    }
    
    func allCharactersArrived(notification: NSNotification) {
        print("notified tbl")
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelShared.people.count
    }
    
    var lastCellClickedNum: Int = 0
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CharacterTableViewCell
        
        // Set the cell’s delegate to the controller itself.
        cell.delegate = self
        
        lastCellClickedNum = indexPath.row
        
        let characterInRow = Model.shared.people[indexPath.row]
        cell.titleLabelCharacterName.text = "\(characterInRow.name)"
        cell.subTitleLabelCharacterGender.text = "Gender: \(characterInRow.gender)"
        // TODO: load the right image for each cell
        let image: UIImage = UIImage(named: "luke.jpg")!
        cell.imageviewOfCharacter.image = image
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelShared.charcterRowTapped = modelShared.people[indexPath.row]
    }
    
    // The cell call this protocol method when the user taps the allMovie button
    func tableViewCellDidTapAllMoviesBtn(_ sender: CharacterTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("*\nProtocol Method - tableViewCellDidTapAllMoviesBtn() invoked:\nsender: \(sender)", "\ntappedIndexPath: \(tappedIndexPath)")
        let tappedInt = tappedIndexPath.row
        Model.shared.requestDataForCharacterMovies(rowNumberFromTbl: tappedInt )
        performSegue(withIdentifier: "toAllMoviesCharacterSegue", sender: self)
    }
    
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
        delegate?.tableViewCellDidTapAllMoviesBtn(self) // (sender: TableViewCellDelegate)
    }
    
}

// MARK: NotificationCenter - extension to Notification.Name
extension Notification.Name {
    static let characterBirthDay = Notification.Name("characterBirthDay")
    static let allCharactersArrivedFromSwapiToModel = Notification.Name("allCharactersFromSwapiInModel")
    
}
