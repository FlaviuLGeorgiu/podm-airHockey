//
//  ButtonSpriteNode.swift
//  AirHockey
//
//  Created by Máster Móviles on 13/02/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit

protocol ButtonSpriteNodeDelegate {
    func didPushButton(_ sender: ButtonSpriteNode)
}

class ButtonSpriteNode: SKSpriteNode {
    
    var delegate : ButtonSpriteNodeDelegate?
    
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

        self.run(SKAction.scale(to: 1, duration: 0.1))
        // Solo llamamos al evento si al terminar el gesto
        // seguimos dentro del boton
        for t in touches {
            if self.contains(t.location(in: self.parent!)) {
                self.run(SKAction.sequence([SKAction.scale(to: 1, duration: 0.1), SKAction.run {self.delegate?.didPushButton(self)}]))
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>,
                                   with event: UIEvent?) {
        pressed = false
    }
}
