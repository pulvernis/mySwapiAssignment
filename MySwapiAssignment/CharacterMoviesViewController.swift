//
//  CharacterMoviesViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 08/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

class CharacterMoviesViewController: UIViewController {
    
    @IBOutlet weak var titleName: UINavigationItem!
    
    var height = CGFloat(0.15)
    var cgSize: CGSize?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cgSize = view.bounds.size
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        if let characterMovies = Model.shared.characterMovies {
            print("*\nCharacterMoviesViewController - getDataUpdate() characterMovies\n\(characterMovies)")
            for movieName in characterMovies {
                createLabelPortraitMode(movieName: movieName)
            }
            
        }
        
        if let characterName = Model.shared.characterName {
            let headLine = "\(characterName) Movies"
            navigationItem.title = headLine
        }
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Delete all subviews before view is on
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.height = CGFloat(0.15)
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
                
            case .portrait:
                
                print("Portrait")
                
            case .landscapeLeft,.landscapeRight :
                
                print("Landscape")
                
            default:
                
                print("Anything But Portrait")
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            //refresh view once rotation is completed (in here) and not in will transition as it returns incorrect frame size.Refresh (also change cgSize Global var to new size)
            self.cgSize = self.view.bounds.size
            
            if let characterMovies = Model.shared.characterMovies {
                print("*\nCharacterMoviesViewController - getDataUpdate() characterMovies\n\(characterMovies)")
                
                switch orient {
                    
                case .portrait:
                    
                    for movieName in characterMovies {
                        self.createLabelPortraitMode(movieName: movieName)
                    }
                    
                case .landscapeLeft,.landscapeRight :
                    
                    for movieName in characterMovies {
                        self.createLabelLandScapeMode(movieName: movieName)
                    }
                    
                default:
                    
                    print("Anything But Portrait")
                }
                
            }
            
        })
        
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    func createLabelPortraitMode(movieName: String) {
        let point = CGPoint(x: cgSize!.width*0.22, y: cgSize!.height*height )
        let size = CGSize(width: cgSize!.width*0.56, height: cgSize!.height*0.05)
        let rect = CGRect(origin: point, size: size)
        let label = UILabel(frame: rect)
        label.layer.backgroundColor  = UIColor.brown.cgColor
        label.layer.cornerRadius = 5
        label.adjustsFontSizeToFitWidth = true
        label.text = movieName
        label.textAlignment = .center
        
        self.view.addSubview(label)
        height += 0.065
    }
    
    func createLabelLandScapeMode(movieName: String) {
        let point = CGPoint(x: cgSize!.width*0.3, y: cgSize!.height*height )
        let size = CGSize(width: cgSize!.width*0.4, height: cgSize!.height*0.065)
        let rect = CGRect(origin: point, size: size)
        let label = UILabel(frame: rect)
        label.layer.backgroundColor  = UIColor.brown.cgColor
        label.layer.cornerRadius = 5
        label.adjustsFontSizeToFitWidth = true
        label.text = movieName
        label.textAlignment = .center
        
        self.view.addSubview(label)
        height += 0.08
    }
    
    
    
    

    

}




