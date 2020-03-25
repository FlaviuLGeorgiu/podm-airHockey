//
//  GameViewController.swift
//  AirHockey
//
//  Created by Miguel Angel Lozano Ortega on 02/08/2019.
//  Copyright © 2019 Miguel Angel Lozano Ortega. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Carga la escena desde 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // TODO [A03] Prueba con diferentes estrategias de escalado de la escena.
                //scene.scaleMode = .aspectFill
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)

                // Presenta la escena
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
