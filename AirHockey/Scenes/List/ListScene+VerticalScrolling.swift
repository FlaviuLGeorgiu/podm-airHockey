//
//  MenuScene+VerticalScrolling.swift
//  CustomScrollView
//
//  Created by Dominik on 11/10/2017.
//  Copyright © 2017 Dominik. All rights reserved.
//

import SpriteKit

extension ListScene {
    
    func prepareVerticalScrolling() {
        
        // Set up scrollView
        scrollView = SwiftySKScrollView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), moveableNode: moveableNode, direction: .vertical)
        
        guard let scrollView = scrollView else { return }
        
        scrollView.center = CGPoint(x: frame.midX, y: frame.midY)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height * scrollViewWidthAdjuster) // * el % de altura necesaria
        view?.addSubview(scrollView)
        
    }
}
