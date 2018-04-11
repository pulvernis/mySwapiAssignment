//
//  TableViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 30/03/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

// Make UITableViewController conform to the protocol

class TableViewController: UITableViewController, TableViewCellDelegate {
    
    // singleton Model
    let modelShared = Model.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        modelShared.getAllPeopleFromPageSwapiApi (pageNumber: 1){
            
            self.modelShared.getAllPeopleFromPageSwapiApi(pageNumber: 2){
                self.tableView.reloadData()
                self.modelShared.getTotalNumOfPeopleFromApi(completion: {
                    // continue to retrieve all characters\people from swapi api in the background
                    // use if let because i made him an optional int (not sure if i get it from api)
                    if let totalPagesPeople =  self.modelShared.totalPagesOfPeopleInSwapiApi{
                        var countToEndOfPages = 3
                        while countToEndOfPages <= totalPagesPeople {
                            if countToEndOfPages < totalPagesPeople {
                                self.modelShared.getAllPeopleFromPageSwapiApi(pageNumber: countToEndOfPages, completion: {
                                    
                                })
                            } else { // means countToEndOfPages = totalPagesPeople - so now we reload in completion all of the data to tbl
                                self.modelShared.getAllPeopleFromPageSwapiApi(pageNumber: countToEndOfPages, completion: {
                                    self.tableView.reloadData()
                                })
                            }
                            
                            countToEndOfPages+=1
                            
                        }
                    }
                })
                
            }
            
        }
        
        modelShared.getAllMoviesUrlsAndNamesFromApi()
        
        
        // MARK: NotificationCenter - addObserver
        
        NotificationCenter.default.addObserver(self, selector: #selector(characterBD(notification:)), name: .characterBirthDay, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func characterBD(notification: NSNotification) {
        print("notified")
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
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell - extension for UITableViewCell in Utility file
        // todo: change image name for each row
        //return cell.myCellDesign(cell: cell, rowNumber: indexPath.row, whichImage: "luke.jpg")
        
        lastCellClickedNum = indexPath.row
        
        let characterInRow = Model.shared.people[indexPath.row]
        cell.textLabel?.text = "\(characterInRow.name)"
        cell.detailTextLabel?.text = "Gender: \(characterInRow.gender)"
        let image: UIImage = UIImage(named: "luke.jpg")!
        cell.imageView?.image = image
        
        let cellSize = cell.frame.size
        
        let button = UIButton(frame: CGRect(x: cellSize.width*0.7, y: cellSize.height*0.1, width: cellSize.width*0.25, height: cellSize.height*0.8))
        button.setTitle("All Movies", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.red, for: .highlighted)
        button.addTarget(cell.self, action: #selector(buttonAction), for: .touchUpInside)
        
        cell.addSubview(button)*/
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CharacterTableViewCell
        
        // Set the cell’s delegate to the controller itself.
        cell.delegate = self
        
        lastCellClickedNum = indexPath.row
        
        let characterInRow = Model.shared.people[indexPath.row]
        //cell.textLabel?.text = "\(characterInRow.name)"
        cell.titleLabelCharacterName.text = "\(characterInRow.name)"
        //cell.detailTextLabel?.text = "Gender: \(characterInRow.gender)"
        cell.subTitleLabelCharacterGender.text = "Gender: \(characterInRow.gender)"
        let image: UIImage = UIImage(named: "luke.jpg")!
        cell.imageviewOfCharacter.image = image
        //cell.allMoviesBtn.titleLabel?.text = "All Movies"
        
        
        return cell
    }
    
    // The cell call this protocol method when the user taps the allMovie button
    func tableViewCellDidTapAllMoviesBtn(_ sender: CharacterTableViewCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("*\nProtocol Method - tableViewCellDidTapAllMoviesBtn() invoked:\nsender: \(sender)", "\ntappedIndexPath: \(tappedIndexPath)")
        let tappedInt = tappedIndexPath.row
        Model.shared.requestDataForCharacterMovies(rowNumberFromTbl: tappedInt )
        performSegue(withIdentifier: "toAllMoviesCharacterSegue", sender: self)
    }
    
    // load more data when scrolling
    // i did it before i used loading all characters in the background by viewDidLoad
    /*override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // 87 chatacters in total
        if indexPath.row < 80 { // means we still not scroll to the last page, in row 79 character 80
            let lastElement = modelShared.currentlyPeopleNum - 1
            if indexPath.row == lastElement { // e.g after cell 19 we want to get next page of characters (10 more characters) from 20 to 29 loading to tbl
                let nextPage = modelShared.currentlyPageNum + 1
                modelShared.getAllPeopleFromPageSwapiApi(pageNumber: nextPage){ 
                    tableView.reloadData()
                }
            }
            
        }
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // action when click on button "All Movies" from tbl
    /*func buttonAction(sender: UIButton!) {
        print("Button tapped")
        Model.shared.requestDataForCharacterMovies(rowNumberFromTbl: lastCellClickedNum )
        
    }*/
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToCharacterDetails" {
            // Setup new view controller
            

        }
        
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
    
}
