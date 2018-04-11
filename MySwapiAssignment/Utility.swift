//
//  Utility.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 03/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

extension UITableViewCell {

    func myCellDesign(cell: UITableViewCell, rowNumber row: Int, whichImage imageName: String) -> UITableViewCell {
        
        let characterInRow = Model.shared.people[row]
        cell.textLabel?.text = "\(characterInRow.name)"
        cell.detailTextLabel?.text = "Gender: \(characterInRow.gender)"
        let image: UIImage = UIImage(named: imageName)!
        cell.imageView?.image = image
        
        let cellSize = cell.frame.size
        
        let button = UIButton(frame: CGRect(x: cellSize.width*0.7, y: cellSize.height*0.1, width: cellSize.width*0.25, height: cellSize.height*0.8))
        button.setTitle("All Movies", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.red, for: .highlighted)
        button.addTarget(cell.self, action: #selector(buttonAction), for: .touchUpInside)
        
        cell.addSubview(button)
        
        return cell
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        //Model.shared.requestDataForCharacterMovies(rowNumberFromTbl: <#T##Int#>)
    }

}

