//
//  ButtonSpriteNode.swift
//  AirHockey
//
//

import SpriteKit

protocol ButtonLabelSpriteNodeDelegate {
    func didPushButton(_ sender: ButtonLabelSpriteNode)
}

class ButtonLabelSpriteNode: SKSpriteNode {
    
    init(_ label : String) {
        let texture = SKTexture(imageNamed: "boton")
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.zPosition = 0
        
        let buttonLabel = SKLabelNode(fontNamed:"University")
        
        buttonLabel.text = label
        buttonLabel.zPosition = 1
        buttonLabel.fontSize = 30
        buttonLabel.position = CGPoint(x: 0, y: 0)
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        
        self.addChild(buttonLabel)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate : ButtonLabelSpriteNodeDelegate?
    
    // Indica el estado del botón
    var pressed : Bool = false
    
    // El boton siempre sera interactivo
    override var isUserInteractionEnabled: Bool {
        set {
        }
        get {
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        pressed = true
        self.run(SKAction.scale(to: 1.2, duration: 0.1))
    }
        
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        pressed = false

        self.run(SKAction.scale(to: 1.0, duration: 0.1))
        // Solo llamamos al evento si al terminar el gesto
        // seguimos dentro del boton
        for t in touches {
            if self.contains(t.location(in: self.parent!)) {
                self.run(SKAction.sequence([SKAction.scale(to: 1.0, duration: 0.1), SKAction.run {self.delegate?.didPushButton(self)}]))
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        pressed = false
        self.run(SKAction.scale(to: 1.0, duration: 0.1))
    }
}

