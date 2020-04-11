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

    let gifNode = SKSpriteNode(imageNamed: "loading0")
    var back = SKShapeNode()
    var fullScreenNode = SKSpriteNode()
    
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.gameScene = self
        
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
    
    func addLoadingGif(){
        
        // GIF
        self.gifNode.position = CGPoint(x: 0, y: 0)
        var gifTextures: [SKTexture] = []
        for i in 0...11 {
            gifTextures.append(SKTexture(imageNamed: "loading\(i)"))
        }
        self.gifNode.run(SKAction.repeatForever(SKAction.animate(with: gifTextures, timePerFrame: 1/30)))
        self.gifNode.size.height = self.frame.size.height / 10
        self.gifNode.size.width =  self.frame.size.height / 10
        self.gifNode.zPosition = 1
        
        // BACKGROUND
        self.back = SKShapeNode.init(rectOf: CGSize(width: self.frame.size.height / 5, height: self.frame.size.height / 6))
        self.back.fillColor = .black
        self.back.strokeColor = .darkGray
        self.back.alpha = 0.7
        self.back.zPosition = 1
        var corners = UIRectCorner()
        corners = corners.union(.bottomLeft)
        corners = corners.union(.bottomRight)
        corners = corners.union(.topLeft)
        corners = corners.union(.topRight)
        self.back.path = UIBezierPath(roundedRect: CGRect(x: -(self.back.frame.width / 2),y:-(self.back.frame.height / 2),width: self.back.frame.width, height: self.back.frame.height),byRoundingCorners: corners, cornerRadii: CGSize(width:20,height:20)).cgPath
        
        // FULLSCREEN NODE TO AVOID UNWANTED TAPS
        self.fullScreenNode = SKSpriteNode(color: .darkGray, size: CGSize(width: self.frame.size.height, height: self.frame.size.height))
        self.fullScreenNode.position = CGPoint(x: 0, y: 0)
        self.fullScreenNode.alpha = 0.1
        self.fullScreenNode.zPosition = 1
        
        // ADD TO ROOT NODE
        addChild(self.fullScreenNode)
        addChild(self.back)
        addChild(self.gifNode)
    }
    
    func removeLoadingGif(){
        self.gifNode.removeAllActions()
        self.gifNode.removeFromParent()
        self.fullScreenNode.removeFromParent()
        self.back.removeFromParent()
    }
    
    override func willMove(from view: SKView) {
        scrollView?.removeFromSuperview()
        scrollView = nil
    }
    
    var auuuux = false;
    
    /// Touches began,
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node != moveableNode, node != back, node != fullScreenNode, node != gifNode, scrollView?.isDisabled == false { // or check for spriteName  ->  if node.name == "SpriteName"
                print("TAP")
                if let nombre = node.name {
                    print(nombre)
                    AppAlert(title: "Conectar con", message: nombre, preferredStyle: .alert)
                    .addAction(title: "NO", style: .cancel) { _ in
                        // action
                    }
                    .addAction(title: "SI", style: .default) { _ in
                         // action
                        self.addLoadingGif()
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
        OperationQueue.main.addOperation {
            let reveal = SKTransition.reveal(with: .down,
            duration: 1)
            if let scene = SKScene(fileNamed: "GameScene"),
               let view = self.view {
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.gameSession = self.connectService.session
                
                view.presentScene(scene, transition: reveal)
            }
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
        removeLoadingGif()
        loadGameScene()
    }
    
    func sendTextService(didReceive text: String) {
        
        
    }
}
