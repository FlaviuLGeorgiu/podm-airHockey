//
//  MenuScene.swift
//  SwiftySKScrollView
//
//  Created by Dominik on 09/01/2016.
//  Copyright (c) 2016 Dominik. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class ListScene: SKScene {
    
    // MARK: - MultipeerConnect
    let connectService = MultipeerConnectService()
    var listaUsuarios : [String] = []
    var listaPeersIDs : [MCPeerID] = []

    
    // MARK: - Properties
    
    /// Sprite size
    let testSpriteSize = CGSize(width: 180, height: 180)
    
    /// Scroll view
    var scrollView: SwiftySKScrollView?
    let scrollViewWidthAdjuster: CGFloat = 3
    
    /// Moveable node in the scrollView
    let moveableNode = SKNode()
    
    /// To register touches, make the sprite global.
    /// Could also give each sprite a name and than check for the name in the touches methods
    let sprite1Page1 = SKSpriteNode(color: .red, size: CGSize(width: 180, height: 180))
    
    /// Click label
    let clickLabel: SKLabelNode = { 
        $0.horizontalAlignmentMode = .center
        $0.verticalAlignmentMode = .center
        $0.text = "Tap"
        $0.fontSize = 32
        $0.position = CGPoint(x: 0, y: 0)
        return $0
    }(SKLabelNode(fontNamed: "HelveticaNeue"))
    
    // MARK: - Deinit
    
    deinit {
        print("Deinit game scene")
        
    }
    
    // MARK: - View Life Cycle
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.listaUsuarios = [String]()
        self.connectService.delegate=self
        
        addChild(moveableNode)
        prepareVerticalScrolling()
        
      /*  AppAlert(title: "Se quiere conectar un usuario", message: "PODM", preferredStyle: .alert)
        .addAction(title: "NO", style: .cancel) { _ in
            // action
        }
        .addAction(title: "SI", style: .default) { _ in
             // action
        }
        .build()
        .showAlert(animated: true)*/
        //prepareHorizontalScrolling()
    }
    
    override func willMove(from view: SKView) {
        scrollView?.removeFromSuperview()
        scrollView = nil
    }
    
    /// Touches began,
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node != moveableNode , scrollView?.isDisabled == false { // or check for spriteName  ->  if node.name == "SpriteName"
                print("TAP")
                if let nombre = node.name {
                    print(nombre)
                    AppAlert(title: "Conectar con", message: nombre, preferredStyle: .alert)
                    .addAction(title: "NO", style: .cancel) { _ in
                        // action
                    }
                    .addAction(title: "SI", style: .default) { _ in
                         // action
                        self.connectService.invite(displayName: nombre)
                    }
                    .build()
                    .showAlert(animated: true)
                }
                //loadGameScene()
            }
        }
    }
}

// MARK: - Load Game Scene

private extension ListScene {
    
    func loadGameScene() {
        /*let scene = SKScene(fileNamed: GameViewController.Scene.game.rawValue)!
        scene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1)
        view?.presentScene(scene, transition: transition)*/
        let reveal = SKTransition.reveal(with: .down,
        duration: 1)
        if let scene = SKScene(fileNamed: "GameScene"),
           let view = self.view {
            scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.gameSession = self.connectService.session
            
            view.presentScene(scene, transition: reveal)
        }
      /*  let secondScene = GameScene(size: self.size)
        
        secondScene.scaleMode = .aspectFill

//        secondScene.session = self.connectService.session //here we do the passing

        let transition = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(secondScene, transition: transition)*/
            
       
    }
}

// MARK: -Load peers data

extension ListScene : MultipeerConnectServiceDelegate {
    
    func devicesNear(devices: [MCPeerID]) {
        OperationQueue.main.addOperation {
            print(devices)
            self.listaUsuarios = devices.map({$0.displayName})
            self.listaPeersIDs = devices
            
            for peer in self.listaUsuarios {
                print(peer)
                let myLabel = SKLabelNode(fontNamed:"University")
                myLabel.name = peer
                myLabel.text = peer
                myLabel.fontSize = 30
                myLabel.position = CGPoint(x:0, y: 0)
                self.moveableNode.addChild(myLabel)
            }
        
        }
    }
    
    
    func connectedDevicesChanged(manager: MultipeerConnectService, connectedDevices: [String]) {
        print("Conectado")
        loadGameScene()
    }
    
    func sendTextService(didReceive text: String) {
        
        
    }
}
