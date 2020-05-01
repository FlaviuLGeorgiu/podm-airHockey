//
//  ConfigScene.swift
//  AirHockey
//
//  Created by Máster Móviles on 30/04/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import Foundation
import SpriteKit

class ConfigScene: SKScene, ButtonSpriteNodeDelegate{

    private var scoreLabel : SKLabelNode?
    private var powerUpsLabel : SKLabelNode?
    private var puckLabel : SKLabelNode?
    private var colorsLabel : SKLabelNode?
    private var plusButton : ButtonSpriteNode?
    private var minusButton : ButtonSpriteNode?
    private var playButton : ButtonSpriteNode?
    
    let red = #colorLiteral(red: 1, green: 0.2156862766, blue: 0.3725490272, alpha: 1)
    let blue = #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)
    let darkBlue = #colorLiteral(red: 0.2274509804, green: 0.3764705882, blue: 0.4980392157, alpha: 1)
    let items = ["Me" , "Opponent"]
    var plus : ButtonLabelSpriteNode!
    var minus : ButtonLabelSpriteNode!
    var score : UITextField!
    var scoreValue = 2
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var textInput : UITextField?
    
    override func didMove(to view: SKView) {
        
        self.scoreValue = self.appDelegate.maxScore
        
        self.plusButton = childNode(withName: "//plusButton") as? ButtonSpriteNode
        self.minusButton = childNode(withName: "//minusButton") as? ButtonSpriteNode
        self.playButton = childNode(withName: "//playButton") as? ButtonSpriteNode
        self.scoreLabel = childNode(withName: "//scoreLabel") as? SKLabelNode
        self.powerUpsLabel = childNode(withName: "//powerUpsLabel") as? SKLabelNode
        self.puckLabel = childNode(withName: "//puckLabel") as? SKLabelNode
        self.colorsLabel = childNode(withName: "//colorsLabel") as? SKLabelNode
        
        self.playButton?.delegate = self
        self.plusButton?.delegate = self
        self.minusButton?.delegate = self
        
        // MARK: ODIO ESTO.....
        let width = UIScreen.main.bounds.width
        let font = UIFont(name: "University", size: 20)
        let whiteAttributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.white ]
        let blackAttributes = [ NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.black ]
        
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
        self.score?.center = CGPoint(x:width/2, y: self.convertHeight(h: self.frame.height/2 - self.minusButton!.position.y))
        self.view!.addSubview(self.score!)
        
        let powerUpsSwitch = UISwitch(frame:CGRect(x: width/2, y: self.powerUpsLabel!.position.y, width: 0, height: 0))
        powerUpsSwitch.isOn = self.appDelegate.powerUps
        powerUpsSwitch.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        powerUpsSwitch.onTintColor = self.darkBlue
        powerUpsSwitch.center = CGPoint(x:width/2, y: self.convertHeight(h: self.frame.height/2 - self.powerUpsLabel!.position.y) + powerUpsSwitch.frame.size.height)
        powerUpsSwitch.setOn(self.appDelegate.powerUps, animated: true)
        powerUpsSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        self.view!.addSubview(powerUpsSwitch)
        
        let whoStartsSegment = UISegmentedControl(items : self.items)
        whoStartsSegment.frame.size.width = self.convertWidth(w: self.puckLabel!.frame.size.width)
        whoStartsSegment.frame.size.height = whoStartsSegment.frame.size.height*1.8
        whoStartsSegment.center = CGPoint(x:width/2, y: self.convertHeight(h: self.frame.height/2 - self.puckLabel!.position.y) + whoStartsSegment.frame.size.height)
        whoStartsSegment.selectedSegmentIndex = self.appDelegate.startWithPuck ? 0 : 1
        whoStartsSegment.addTarget(self, action: #selector(ConfigScene.indexChanged(_:)), for: .valueChanged)
        whoStartsSegment.layer.cornerRadius = 5.0
        whoStartsSegment.backgroundColor = self.darkBlue
        whoStartsSegment.setTitleTextAttributes(whiteAttributes as [NSAttributedString.Key : Any], for: .normal)
        whoStartsSegment.setTitleTextAttributes(blackAttributes as [NSAttributedString.Key : Any], for: .selected)
        whoStartsSegment.tintColor = self.red
        self.view!.addSubview(whoStartsSegment)
        
        let whatColorSegment = UISegmentedControl(items : self.items)
        whatColorSegment.frame.size.width = self.convertWidth(w: self.puckLabel!.frame.size.width)
        whatColorSegment.frame.size.height = whatColorSegment.frame.size.height*1.8
        whatColorSegment.center = CGPoint(x:width/2, y: self.convertHeight(h: self.frame.height/2 - self.colorsLabel!.position.y) + whatColorSegment.frame.size.height)
        whatColorSegment.selectedSegmentIndex = self.appDelegate.myColor == #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1) ? 0 : 1
        whatColorSegment.addTarget(self, action: #selector(ConfigScene.indexChangedColor(_:)), for: .valueChanged)
        whatColorSegment.layer.cornerRadius = 5.0
        whatColorSegment.setTitleTextAttributes(whiteAttributes as [NSAttributedString.Key : Any], for: .selected)
        whatColorSegment.setTitleTextAttributes(blackAttributes as [NSAttributedString.Key : Any], for: .normal)
        whatColorSegment.backgroundColor = self.red
        if #available(iOS 13.0, *) {
            whatColorSegment.selectedSegmentTintColor = self.blue
        } else {
            whatColorSegment.tintColor = self.blue
        }
        self.view!.addSubview(whatColorSegment)
        
    }
    
    func didPushButton(_ sender: ButtonSpriteNode) {
        if let name = sender.name{
            switch name {
            case "plusButton":
                if self.scoreValue < 11 {
                    self.scoreValue += 1
                    self.appDelegate.maxScore = scoreValue
                    self.score?.text = String(self.scoreValue)
                }
            case "minusButton":
                if self.scoreValue > 1 {
                    self.scoreValue -= 1
                    self.appDelegate.maxScore = scoreValue
                    self.score?.text = String(self.scoreValue)
                }
            case "playButton":
                for view in self.view!.subviews {
                    view.removeFromSuperview()
                }
                view?.gestureRecognizers?.removeAll()
                let reveal = SKTransition.reveal(with: .down,
                duration: 1)
                if let scene = SKScene(fileNamed: "ListScene"),
                   let view = self.view {
                    scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                    view.presentScene(scene, transition: reveal)
                }
            default:
                self.score?.text = String(self.scoreValue)
            }
        }
    }
    
    func convertHeight(h : CGFloat) -> CGFloat{
        return  UIScreen.main.bounds.height * h / self.frame.height
    }
    
    func convertWidth(w : CGFloat) -> CGFloat{
        return  UIScreen.main.bounds.width * w / self.frame.width
    }
    
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                self.appDelegate.startWithPuck = true
            case 1:
                self.appDelegate.startWithPuck = false
            default:
                break
            }
    }
    
    @objc func indexChangedColor(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
                self.appDelegate.myColor = self.blue
            case 1:
                self.appDelegate.myColor = self.red
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
