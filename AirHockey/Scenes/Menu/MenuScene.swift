//
//  MenuScene.swift
//  AirHockey
//
//  Created by Máster Móviles on 13/02/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
class MenuScene: SKScene, ButtonSpriteNodeDelegate{
    private var playButton : ButtonSpriteNode?
    
    func didPushButton(_ sender: ButtonSpriteNode) {
        //tipo de animacion que se aplica al cambio de escena
        let reveal = SKTransition.reveal(with: .down,
        duration: 1)
        
        if let scene = SKScene(fileNamed: "GameScene"),
           let view = self.view
        {
            //reajusta el tamaño de la pantalla al cambiar de escena
            scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            view.presentScene(scene, transition: reveal)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
    }
    
    override func didMove(to view: SKView) {
        print(self.frame)
        self.playButton = childNode(withName: "//play_button") as? ButtonSpriteNode
        self.playButton?.delegate = self
    }
}
