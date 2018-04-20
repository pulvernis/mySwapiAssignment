//
//  CharacterMoviesViewController.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 08/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import UIKit

class CharacterMoviesViewController: UIViewController {
    
    var height = CGFloat(0.15)
    var cgSize: CGSize?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cgSize = view.bounds.size
        
        if let characterName = Model.shared.characterName {
            let headLine = "\(characterName) Movies"
            navigationItem.title = headLine
        }
        
        if let characterMovies = Model.shared.characterMovies {
            let orient = UIApplication.shared.statusBarOrientation
            switch orient {
            case .portrait:
                self.createLabels(characterMovies: characterMovies, mode: .PORTRAIT)
                
            case .landscapeLeft,.landscapeRight :
                self.createLabels(characterMovies: characterMovies, mode: .LANDSCAPE)
                
            default:
                print("portraitUpsideDown")
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Before rotation is completed
        // Delete all subviews (labels) and update starting height for first label
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.height = CGFloat(0.15)
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
        }, completion: { [unowned self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            // after rotation is completed
            let orient = UIApplication.shared.statusBarOrientation
            
            self.cgSize = self.view.bounds.size //update cgSize to the new size
            
            if let characterMovies = Model.shared.characterMovies {
                
                switch orient {
                    
                case .portrait:
                    self.createLabels(characterMovies: characterMovies, mode: .PORTRAIT)
                    
                case .landscapeLeft,.landscapeRight :
                    self.createLabels(characterMovies: characterMovies, mode: .LANDSCAPE)
                    
                default:
                    print("portraitUpsideDown")
                }
            }
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func createLabels(characterMovies: [String], mode: Mode) {
        
        func lblStyleAndSize(point:CGPoint, size: CGSize, movieName: String) {
            let rect = CGRect(origin: point, size: size)
            let label = UILabel(frame: rect)
            label.layer.backgroundColor  = UIColor.brown.cgColor
            label.layer.cornerRadius = 5
            label.adjustsFontSizeToFitWidth = true
            label.text = movieName
            label.textAlignment = .center
            
            self.view.addSubview(label)
        }
        
        
        for movieName in characterMovies{
            switch mode {
            case .PORTRAIT:
                let point = CGPoint(x: cgSize!.width*0.22, y: cgSize!.height*height )
                let size = CGSize(width: cgSize!.width*0.56, height: cgSize!.height*0.05)
                lblStyleAndSize(point: point, size: size, movieName: movieName)
                height += 0.065
            case .LANDSCAPE:
                let point = CGPoint(x: cgSize!.width*0.3, y: cgSize!.height*height )
                let size = CGSize(width: cgSize!.width*0.4, height: cgSize!.height*0.065)
                height += 0.08
                lblStyleAndSize(point: point, size: size, movieName: movieName)
            }
        }
        
    }
    
    enum Mode {
        case PORTRAIT
        case LANDSCAPE
    }

}




