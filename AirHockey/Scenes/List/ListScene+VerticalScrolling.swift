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
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height * scrollViewWidthAdjuster) // * 3 makes it 3times as long as screen
        view?.addSubview(scrollView)
        
        // ScrollView Sprites for each page in scrollView
        // Makes positioning your actual stuff later much easier.
        let page1ScrollView = SKSpriteNode(color: .clear, size: scrollView.frame.size)
        page1ScrollView.position = CGPoint(x: frame.midX, y: frame.midY)
        moveableNode.addChild(page1ScrollView)
        
        let page2ScrollView = SKSpriteNode(color: .clear, size: scrollView.frame.size)
        page2ScrollView.position = CGPoint(x: frame.midX, y: frame.midY - (scrollView.frame.height))
        moveableNode.addChild(page2ScrollView)
        
        let page3ScrollView = SKSpriteNode(color: .clear, size: scrollView.frame.size)
        page3ScrollView.position = CGPoint(x: frame.midX, y: frame.midY - (scrollView.frame.height * 2))
        moveableNode.addChild(page3ScrollView)
       /*
        // Test sprites page 1
        sprite1Page1.position = CGPoint(x: 0, y: 0)
        page1ScrollView.addChild(sprite1Page1)
        
        // Click label
        sprite1Page1.addChild(clickLabel)
        
        // Test sprites page 1
        let sprite2Page1 = SKSpriteNode(color: .red, size: testSpriteSize)
        sprite2Page1.position = CGPoint(x: sprite1Page1.position.x, y: sprite1Page1.position.y - sprite2Page1.size.height * 1.5)
        sprite1Page1.addChild(sprite2Page1)
        
        let sprite3Page1 = SKSpriteNode(color: .blue, size: testSpriteSize)
        sprite3Page1.position = CGPoint(x: sprite1Page1.position.x, y: sprite1Page1.position.y - sprite2Page1.size.height * 3)
        sprite1Page1.addChild(sprite3Page1)
        
        let sprite4Page1 = SKSpriteNode(color: .blue, size: testSpriteSize)
        sprite4Page1.position = CGPoint(x: sprite1Page1.position.x, y: sprite1Page1.position.y - sprite2Page1.size.height * 5)
        sprite1Page1.addChild(sprite4Page1)
        
        // Test sprites page 2
        /*let sprite1Page2 = SKSpriteNode(color: .blue, size: testSpriteSize)
        sprite1Page2.position = CGPoint(x: 0, y: 0)
        page2ScrollView.addChild(sprite1Page2)
        
        let sprite2Page2 = SKSpriteNode(color: .blue, size: testSpriteSize)
        sprite2Page2.position = CGPoint(x: sprite1Page2.position.x, y: sprite1Page2.position.y - (sprite2Page2.size.height * 1.5))
        sprite1Page2.addChild(sprite2Page2)
        
        /// Test sprites page 2
        let sprite1Page3 = SKSpriteNode(color: .green, size: testSpriteSize)
        sprite1Page3.position = CGPoint(x: 0, y: 0)
        page3ScrollView.addChild(sprite1Page3)
        
        let sprite2Page3 = SKSpriteNode(color: .green, size: testSpriteSize)
        sprite2Page3.position = CGPoint(x: sprite1Page3.position.x, y: sprite1Page3.position.y - (sprite2Page3.size.height * 1.5))
        sprite1Page3.addChild(sprite2Page3)*/
 */
    }
}
