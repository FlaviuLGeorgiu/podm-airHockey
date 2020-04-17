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
    private var airHockey : SKLabelNode?
    private var forTwo : SKLabelNode?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textInput : UITextField?
    
    func didPushButton(_ sender: ButtonSpriteNode) {
        //tipo de animacion que se aplica al cambio de escena
        if(self.textInput?.text != ""){
            appDelegate.myName = self.textInput?.text
            UserDefaults.standard.set(self.textInput?.text, forKey: "myName")
            textInput?.removeFromSuperview()
            view?.gestureRecognizers?.removeAll()
            let reveal = SKTransition.reveal(with: .down,
            duration: 1)
            if let scene = SKScene(fileNamed: "ListScene"),
               let view = self.view {
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                view.presentScene(scene, transition: reveal)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
    }
    
    override func didMove(to view: SKView) {
        print(self.frame)
        self.playButton = childNode(withName: "//play_button") as? ButtonSpriteNode
        self.airHockey = childNode(withName: "//airHockey") as? SKLabelNode
        self.forTwo = childNode(withName: "//forTwo") as? SKLabelNode
        
        self.playButton?.delegate = self
        
        self.hideKeyboard()
        
        // MARK: ODIO ESTO.....
        let width = UIScreen.main.bounds.width//self.rootView.frame.size.width
        let height = UIScreen.main.bounds.height
        
        self.airHockey?.position = CGPoint(x: 0, y: self.frame.height/10 * 2 )
        self.airHockey?.horizontalAlignmentMode = .center
        
        self.forTwo?.position = CGPoint(x: 0, y: self.frame.height/10 * 1.5  )
        self.forTwo?.horizontalAlignmentMode = .center
        
        let myLabel = SKLabelNode(fontNamed:"University")
        myLabel.text = "Your Name:"
        myLabel.fontSize = 30
        myLabel.position = CGPoint(x:self.frame.midX, y: self.frame.height/10 * 0.2)
        self.addChild(myLabel)

        self.textInput = UITextField()
        self.textInput?.textAlignment = .center
        self.textInput?.backgroundColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1)
        self.textInput?.textColor = .white
        self.textInput?.font = UIFont(name: "University", size: 30)
        self.textInput?.layer.cornerRadius = 10.0
        self.textInput?.frame.size.width = width/1.2
        self.textInput?.frame = CGRect(x: width/2 - (self.textInput?.frame.size.width)!/2,y: height/2, width: width/1.2, height: 50)
        
        if let name = UserDefaults.standard.string(forKey: "myName") {
            self.textInput?.text = name
        }else{
            self.textInput?.text = "Player-" + String(Int.random(in: 1000 ..< 9999))
        }
        
        self.view!.addSubview(textInput!)
        
        self.playButton?.position = CGPoint(x: 0, y: -self.frame.height/10 * 1.2 )
    }
    
    /*override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { let location = touch.location(in: self) }
    }*/
}
