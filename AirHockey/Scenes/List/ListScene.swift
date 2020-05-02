//
//  MenuScene.swift
//  SwiftySKScrollView
//
//  Created by Dominik on 09/01/2016.
//  Copyright (c) 2016 Dominik. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class ListScene: SKScene, ButtonLabelSpriteNodeDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - MultipeerConnect
//    let connectService = MultipeerConnectService()
    var listaUsuarios : [String] = []
    var listaPeersIDs : [MCPeerID] = []

    let gifNode = SKSpriteNode(imageNamed: "loading0")
    var back = SKShapeNode()
    var fullScreenNode = SKSpriteNode()
    let buttonHeight = 80.0
    let myNameIs = SKLabelNode(fontNamed:"University")
    var buttons : [ButtonLabelSpriteNode] = []
    
    var conectando = false
    
    // MARK: - Properties
    
    /// Sprite size
    let testSpriteSize = CGSize(width: 180, height: 180)
    
    /// Scroll view
    var scrollView: SwiftySKScrollView?
    var scrollViewWidthAdjuster: CGFloat = 1
    
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
        
        
        addChild(moveableNode)
        prepareVerticalScrolling()
        appDelegate.gameScene = self
        
        appDelegate.connectService = MultipeerConnectService()
        appDelegate.connectService!.delegate=self
        
        
        let buttonBackGround = ButtonLabelSpriteNode("Back to Settings")
        buttonBackGround.name = "settings"
        buttonBackGround.size.width = self.frame.width / 1.5
        buttonBackGround.position = CGPoint(x: 0, y: (self.frame.size.height / 2) - CGFloat(self.buttonHeight) * 2.0)
        buttonBackGround.delegate = self
        self.moveableNode.addChild(buttonBackGround)
        
        myNameIs.text = "My Name is: " + self.appDelegate.myName!
        myNameIs.fontSize = 35
        myNameIs.position = CGPoint(x: 0, y: (self.frame.size.height / 2) - CGFloat(self.buttonHeight) * 4.0)
        self.moveableNode.addChild(myNameIs)
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
        self.gifNode.zPosition = 4
        
        // BACKGROUND
        self.back = SKShapeNode.init(rectOf: CGSize(width: self.frame.size.height / 5, height: self.frame.size.height / 6))
        self.back.fillColor = .black
        self.back.strokeColor = .darkGray
        self.back.alpha = 0.7
        self.back.zPosition = 3
        var corners = UIRectCorner()
        corners = corners.union(.bottomLeft)
        corners = corners.union(.bottomRight)
        corners = corners.union(.topLeft)
        corners = corners.union(.topRight)
        self.back.path = UIBezierPath(roundedRect: CGRect(x: -(self.back.frame.width / 2),y:-(self.back.frame.height / 2),width: self.back.frame.width, height: self.back.frame.height),byRoundingCorners: corners, cornerRadii: CGSize(width:20,height:20)).cgPath
        
        // FULLSCREEN NODE TO AVOID UNWANTED TAPS
        self.fullScreenNode = SKSpriteNode(color: .black, size: CGSize(width: self.frame.size.height, height: self.frame.size.height))
        self.fullScreenNode.position = CGPoint(x: 0, y: 0)
        self.fullScreenNode.alpha = 0.3
        self.fullScreenNode.zPosition = 2
        
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
        self.removeAllChildren()
        for view in self.view!.subviews {
            if view != (self.appDelegate.config as! ConfigScene).score && view != (self.appDelegate.config as! ConfigScene).powerUpsSwitch && view != (self.appDelegate.config as! ConfigScene).whoStartsSegment && view != (self.appDelegate.config as! ConfigScene).whatColorSegment{
                view.removeFromSuperview()
            }
        }
    }
    
    func didPushButton(_ sender: ButtonLabelSpriteNode) {
        if(!self.conectando){
            if let nombre = sender.name {
                if nombre == "settings" {
                    self.appDelegate.connectService!.disconnect()
                    view?.gestureRecognizers?.removeAll()
                    let reveal = SKTransition.reveal(with: .down,
                    duration: 1)
                    if let scene = SKScene(fileNamed: "ConfigScene"),
                       let view = self.view {
                        scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                        view.presentScene(scene, transition: reveal)
                    }
                } else {
                    self.conectando = true
                    AppAlert(title: "Conectar con", message: nombre, preferredStyle: .alert)
                    .addAction(title: "NO", style: .cancel) { _ in
                        self.conectando = false
                    }
                    .addAction(title: "SI", style: .default) { _ in
                        self.addLoadingGif()
                        self.appDelegate.connectService!.invite(displayName: nombre)
                    }
                    .build()
                    .showAlert(animated: true)
                }
            }
        }
    }
    
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
          options = JSONSerialization.WritingOptions.prettyPrinted
        }

        do {
          let data = try JSONSerialization.data(withJSONObject: json, options: options)
          if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
          }
        } catch {
          print(error)
        }

        return ""
    }
}

// MARK: - Load Game Scene

private extension ListScene {
    
    func loadGameScene() {
       
        OperationQueue.main.addOperation {
            let reveal = SKTransition.reveal(with: .down,
            duration: 1)
            if let scene = GameScene(fileNamed: "GameScene"),
               let view = self.view {
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                
                self.appDelegate.connectService!.disconnect()
                view.presentScene(scene, transition: reveal)
            }
        }
    }
}

// MARK: -Load peers data

extension ListScene : MultipeerConnectServiceDelegate {
    func notConnected() {
        OperationQueue.main.addOperation {
            self.removeLoadingGif()
            self.conectando = false
        }
    }
    
    func didReciveSize(didReceive text: String) {
        let data = text.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
            {
                var altura = UIScreen.main.bounds.height
                var anchura = UIScreen.main.bounds.width
                if (jsonArray["height"] as! CGFloat) <= altura {
                    altura = jsonArray["height"] as! CGFloat
                }
                if (jsonArray["width"] as! CGFloat) <= anchura{
                    anchura = jsonArray["width"] as! CGFloat
                }
                self.appDelegate.altura = altura
                               self.appDelegate.anchura = anchura
                
//                Comprobamos los datos que recibimos solo si somos el invitado (comunicacion cruzada)
                if !self.appDelegate.connectService!.isBrowser{
                    let color = jsonArray["color"] as! Bool
                   
                    self.appDelegate.myColor = color ? #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1) : #colorLiteral(red: 1, green: 0.2156862766, blue: 0.3725490272, alpha: 1)
                    
                    self.appDelegate.startWithPuck = jsonArray["start"] as! Bool
                    
                    self.appDelegate.maxScore = jsonArray["maxscore"] as! Int
                    
                    self.appDelegate.powerUps = jsonArray["powerups"] as! Bool
                }
               
                
                removeLoadingGif()
                loadGameScene()
                
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    
    func devicesNear(devices: [MCPeerID]) {
        OperationQueue.main.addOperation {
            
            for button in self.buttons {
                button.removeFromParent()
            }
            self.buttons.removeAll()

            self.listaPeersIDs.removeAll()
            self.listaUsuarios.removeAll()
            for device in devices {
                if device.displayName != self.appDelegate.myName{
                    self.listaUsuarios.append(device.displayName)
                    self.listaPeersIDs.append(device)
                }
            }
            
            
            
            var auxY = self.myNameIs.position.y;
            let totalHeight = Double(self.listaUsuarios.count + 3) * 2.0 * self.buttonHeight
            let adjuster = (totalHeight / Double(self.frame.size.height))
            self.scrollViewWidthAdjuster = CGFloat(adjuster)
            self.prepareVerticalScrolling()
            
            for peer in self.listaUsuarios {
                let buttonBackGround = ButtonLabelSpriteNode(peer)
                buttonBackGround.name = peer
                buttonBackGround.size.width = self.frame.width / 1.5
                buttonBackGround.position = CGPoint(x: 0, y: auxY - (2 * buttonBackGround.frame.size.height))
                buttonBackGround.delegate = self
                self.moveableNode.addChild(buttonBackGround)
                self.buttons.append(buttonBackGround)
                auxY = buttonBackGround.position.y
            }
        
        }
    }
    
    
    func connectedDevicesChanged(manager: MultipeerConnectService, connectedDevices: [String]) {
        let data: [String: Any] = [
            "height" : UIScreen.main.bounds.height,
            "width" : UIScreen.main.bounds.width,
            "color" : self.appDelegate.myColor == #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1) ? false : true,
            "start" : !self.appDelegate.startWithPuck,
            "maxscore" : self.appDelegate.maxScore,
            "powerups" : self.appDelegate.powerUps
        ]
        let jsonString = stringify(json: data, prettyPrinted: true)
        self.appDelegate.connectService!.send(text: jsonString)
    }
    
}
