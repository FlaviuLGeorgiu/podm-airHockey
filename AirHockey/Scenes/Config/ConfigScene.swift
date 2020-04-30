//
//  ConfigScene.swift
//  AirHockey
//
//  Created by Máster Móviles on 30/04/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import Foundation
import SpriteKit

class ConfigScene: SKScene, ButtonLabelSpriteNodeDelegate{
    
   // private var playButton : ButtonSpriteNode?
    //private var airHockey : SKLabelNode?
    //private var forTwo : SKLabelNode?
    let red = #colorLiteral(red: 1, green: 0.2156862766, blue: 0.3725490272, alpha: 1)
    let blue = #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)
    let items = ["Me" , "Opponent"]
    var segmentedControl : UISegmentedControl?
    var plus : ButtonLabelSpriteNode!
    var minus : ButtonLabelSpriteNode!
    var score : UITextField!
    var scoreValue = 2

    var myColor =  #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)
    var startWithPuck = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textInput : UITextField?
    
    override func didMove(to view: SKView) {
        print(self.frame)
        //self.playButton = childNode(withName: "//play_button") as? ButtonSpriteNode
        //self.airHockey = childNode(withName: "//airHockey") as? SKLabelNode
        //self.forTwo = childNode(withName: "//forTwo") as? SKLabelNode
        
        //self.playButton?.delegate = self
        
        // MARK: ODIO ESTO.....
        let width = UIScreen.main.bounds.width//self.rootView.frame.size.width
        let height = UIScreen.main.bounds.height
        
        /*self.airHockey?.position = CGPoint(x: 0, y: self.frame.height/10 * 2 )
        self.airHockey?.horizontalAlignmentMode = .center
        
        self.forTwo?.position = CGPoint(x: 0, y: self.frame.height/10 * 1.5  )
        self.forTwo?.horizontalAlignmentMode = .center*/
        
        let title = SKLabelNode(fontNamed:"University")
        title.text = "Config Screen"
        title.fontSize = 50
        title.position = CGPoint(x:self.frame.midX, y: self.frame.maxY - height/6)
        self.addChild(title)

        let scoreTitle = SKLabelNode(fontNamed:"University")
        scoreTitle.text = "Score to Win"
        scoreTitle.fontSize = 35
        scoreTitle.position = CGPoint(x:self.frame.midX, y: title.frame.minY - height/6)
        self.addChild(scoreTitle)
        
        self.minus = ButtonLabelSpriteNode("-")
        self.minus.name = "minus"
        self.minus.size.width = 100
        self.minus.position = CGPoint(x:self.frame.midX - 150, y: scoreTitle.frame.minY - scoreTitle.frame.size.height * 3)
        self.minus.delegate = self
        self.addChild(self.minus)
        
        self.score = UITextField()
        self.score?.textAlignment = .center
        self.score?.backgroundColor = .lightGray
        self.score?.textColor = .white
        self.score?.font = UIFont(name: "University", size: 35)
        self.score?.layer.cornerRadius = 10.0
        self.score?.text = String(self.scoreValue)
        self.score?.frame.size.width = 100
        self.score?.frame.size.height = 80
        self.score?.isUserInteractionEnabled = false
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.score?.center = CGPoint(x: width/2 ,y: self.convertHeight(h: 20 + scoreTitle.position.y + scoreTitle.frame.size.height * 3))
        } else {
            self.score?.center = CGPoint(x: width/2 ,y: self.convertHeight(h: scoreTitle.position.y + scoreTitle.frame.size.height * 3) - self.score.frame.size.height/2)
        }
        self.view!.addSubview(self.score!)
        
        self.plus = ButtonLabelSpriteNode("+")
        self.plus.name = "plus"
        self.plus.size.width = 100
        self.plus.position = CGPoint(x:self.frame.midX + 150, y: scoreTitle.frame.minY - scoreTitle.frame.size.height * 3)
        self.plus.delegate = self
        self.addChild(self.plus)
        
        let powerTitle = SKLabelNode(fontNamed:"University")
        powerTitle.text = "Activate Power-Ups?"
        powerTitle.fontSize = 35
        powerTitle.position = CGPoint(x:self.frame.midX, y: scoreTitle.frame.minY - height/4)
        self.addChild(powerTitle)
        
        let powerUpsSwitch = UISwitch(frame:CGRect(x: width/2, y: powerTitle.position.y, width: 0, height: 0))
        powerUpsSwitch.isOn = true
        powerUpsSwitch.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        powerUpsSwitch.onTintColor = self.blue
        powerUpsSwitch.center = CGPoint(x:width/2, y: self.convertHeight(h: self.frame.height/2 - powerTitle.position.y) + powerUpsSwitch.frame.size.height)
        powerUpsSwitch.setOn(true, animated: true)
        powerUpsSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        self.view!.addSubview(powerUpsSwitch)
        
        /*segmentedControl = UISegmentedControl(items : self.items)
        segmentedControl!.center = self.scene!.view!.center
        segmentedControl!.selectedSegmentIndex = 0
        segmentedControl!.addTarget(self, action: #selector(ConfigScene.indexChanged(_:)), for: .valueChanged)

        segmentedControl!.layer.cornerRadius = 5.0
        segmentedControl!.backgroundColor = self.blue
        segmentedControl!.tintColor = self.red

        self.view!.addSubview(segmentedControl!)*/
        
    }
    
    func didPushButton(_ sender: ButtonLabelSpriteNode) {
        if let name = sender.name{
            switch name {
            case "plus":
                if self.scoreValue < 10 {
                    self.scoreValue += 1
                    self.appDelegate.maxScore = scoreValue
                    self.score?.text = String(self.scoreValue)
                }
            case "minus":
                if self.scoreValue > 1 {
                    self.scoreValue -= 1
                    self.appDelegate.maxScore = scoreValue
                    self.score?.text = String(self.scoreValue)
                }
            default:
                self.score?.text = String(self.scoreValue)
            }
        }
    }
    
    func convertHeight(h : CGFloat) -> CGFloat{
        return  UIScreen.main.bounds.height * h / self.frame.height
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                print("iOS");
            case 1:
                print("Android")
            default:
                break
            }
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn == true){
            self.appDelegate.powerUps = true
        }
        else{
            self.appDelegate.powerUps = false
        }
    }
}
