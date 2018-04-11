//
//  moviesLabel.swift
//  MySwapiAssignment
//
//  Created by Ran Pulvernis on 10/04/2018.
//  Copyright © 2018 RanPulvernis. All rights reserved.
//

import Foundation
import UIKit

class MoviesLabelView: UIView {
    
    var height = CGFloat(0.1)
    
//    var moviesName: [String] = Model.shared.characterMovies! { // every name added to array will add also  a label
//        didSet {
//            //setNeedsDisplay() // called to draw() again (override it)
//            //setNeedsLayout() // called to layoutSubviews() again (override it)
//        }
//    }
    
    private func createLabel(movieName: String) {
        let point = CGPoint(x: frame.size.width*0.1, y: frame.size.height*height )
        let size = CGSize(width: frame.size.width*0.8, height: frame.size.height*0.1)
        let rect = CGRect(origin: point, size: size)
        let label = UILabel(frame: rect)
        label.text = movieName
        label.textAlignment = .center
        
        height += 0.05
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let characterMovies = Model.shared.characterMovies {
            print("*\nCharacterMoviesViewController - getDataUpdate() characterMovies\n\(characterMovies)")
            for movieName in characterMovies {
                createLabel(movieName: movieName)
            }
            
        }
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: 16.0)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        
        
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        setNeedsDisplay()
//        setNeedsLayout()
//    }
    
    
    
    
}
