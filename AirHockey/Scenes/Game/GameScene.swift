//
//  GameScene.swift
//  AirHockey
//
//  Created by Miguel Angel Lozano Ortega on 02/08/2019.
//  Copyright © 2019 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity

enum PowerUpsSpeed {
    case normal, fast, slow
}

// TODO [D04] Implementa el protocolo `SKPhysicsContactDelegate`
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // MARK: - Referencias Session
    var session : MCSession? = nil
    var connectService : MultipeerConnectService?
    var estoyEnCampo = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Referencias a nodos de la escena
    private var paddle : SKSpriteNode?
    //private var paddleTop : SKSpriteNode?
    private var puck : SKSpriteNode?
    private var scoreboard : SKLabelNode?
    private var labelWins : SKLabelNode?
    
    private var powerUpTop : SKSpriteNode?
    private var powerUpBottom : SKSpriteNode?
    private var powerUp : SKSpriteNode?

    // MARK: Marcadores de los jugadores
    private var score : Int = 0
    //private var scoreTop : Int = 0
    
    // MARK: Powerups
    private var powerUpActivated : PowerUpsSpeed = .fast
    private var doublePoints : Bool = false;
    private var contadorPowerUps = 0

    // MARK: Colores de los jugadores
    private var color = #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)

    // MARK: Categorias de los objetos fisicos
    private let paddleCategoryMask : UInt32 = 0b00001
    private let puckCategoryMask : UInt32 = 0b00010
    private let limitsCategoryMask : UInt32 = 0b00100
    private let midfieldCategoryMask : UInt32 = 0b01000
    private let powerUpsCategoryMask : UInt32 = 0b10000

    // MARK: Efectos de sonido
    // TODO [D02] Crear acciones para reproducir "goal.wav" y "hit.wav"
    private let actionSoundGoal =  SKAction.playSoundFileNamed("goal.wav", waitForCompletion: false)
    private let actionSoundHit =  SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)

    // MARK: Mapa de asociacion de touches con palas
    private var activeTouches : [UITouch : SKNode] = [:]
    
    private var diffHeight : CGFloat = 0.0
    private var altura : CGFloat = 0.0
    private var anchura : CGFloat = 0.0
    private var minAnchuraUIScreenEnValorFrame : CGFloat = 0.0
    private var ajuste : CGFloat = 0.0
    // MARK: - Inicializacion de la escena
    
    override func didMove(to view: SKView) {
    
        self.appDelegate.gameScene = self
        
        self.session = appDelegate.gameSession
        self.connectService = appDelegate.connectService
        self.connectService?.gameDelegate = self
        
        
        self.diffHeight = UIScreen.main.bounds.height - appDelegate.altura!
        self.altura = appDelegate.altura!
        self.anchura = appDelegate.anchura!
        self.minAnchuraUIScreenEnValorFrame = self.frame.minX + self.convertWidth(w: (UIScreen.main.bounds.width - self.anchura))
        
//       Calculo de la diferencia de altura entre dispositivos distintos
        self.ajuste = self.altura / UIScreen.main.bounds.height

        self.configGame()
        self.createSceneLimits()
        self.updateScore()

    }
    
//    MARK: -Configuracion del juego
    func configGame(){
        
        self.color = self.appDelegate.myColor
        
        self.paddle = childNode(withName: "//paddleBottom") as? SKSpriteNode
        self.puck = childNode(withName: "//puck") as? SKSpriteNode
        
        self.paddle?.scale(to: CGSize(width: (self.paddle?.size.width)! * self.ajuste, height: (self.paddle?.size.height)! * self.ajuste))
        self.puck?.scale(to: CGSize(width: (self.puck?.size.width)! * self.ajuste, height: (self.puck?.size.height)! * self.ajuste))
        
        self.paddle!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/4)
        self.puck!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/2)

        self.scoreboard = childNode(withName: "//score_bottom") as? SKLabelNode
        self.scoreboard?.fontSize = self.scoreboard!.fontSize * self.ajuste
        self.scoreboard!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/2)
        
        if !self.appDelegate.startWithPuck {
            self.puck?.position = CGPoint(x: self.frame.maxX + 50, y: 0)
            self.estoyEnCampo = false
        }
        
        
        if self.appDelegate.myColor == #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1){
            self.paddle?.texture = SKTexture(imageNamed: "paddle_blue")
            self.scoreboard?.fontColor = self.color
        }else{
            self.paddle?.texture = SKTexture(imageNamed: "paddle_red")
            self.scoreboard?.fontColor = self.color
        }
        self.physicsWorld.contactDelegate = self
    }
    
    func createSceneLimits() {
        // MARK: - PORTERIA
        let porteriaLado = SKShapeNode(rect: CGRect(x: self.minAnchuraUIScreenEnValorFrame - 20, y: -self.convertHeight(h: self.altura/4), width: self.convertWidth(w: self.anchura/4), height: self.convertHeight(h: self.altura/2)))
        porteriaLado.strokeColor = self.color
        porteriaLado.glowWidth = 4.0  * self.ajuste
        self.addChild(porteriaLado)
        
        // MARK: - MARGENES
        let rectanguloNegroSuperior = SKShapeNode(rectOf: CGSize(width: self.frame.width*2, height: self.convertHeight(h:UIScreen.main.bounds.height - self.altura)))
        rectanguloNegroSuperior.fillColor = .darkGray
        rectanguloNegroSuperior.strokeColor = .darkGray
        rectanguloNegroSuperior.position = CGPoint(x:  self.frame.minX,y: self.convertHeight(h: UIScreen.main.bounds.height/2))
        self.addChild(rectanguloNegroSuperior)
        
        let rectanguloNegroInferior = SKShapeNode(rectOf: CGSize(width: self.frame.width*2, height: self.convertHeight(h:UIScreen.main.bounds.height - self.altura)))
        rectanguloNegroInferior.fillColor = .darkGray
        rectanguloNegroInferior.strokeColor = .darkGray
        rectanguloNegroInferior.position = CGPoint(x:  self.frame.minX,y: -self.convertHeight(h: UIScreen.main.bounds.height/2))
        self.addChild(rectanguloNegroInferior)
        
        if self.anchura != UIScreen.main.bounds.width {
            let rectanguloNegroLateral = SKShapeNode(rectOf: CGSize(width: self.convertWidth(w: UIScreen.main.bounds.width), height: self.convertHeight(h:UIScreen.main.bounds.height*2)))
            rectanguloNegroLateral.fillColor = .darkGray
            rectanguloNegroLateral.strokeColor = .darkGray
            rectanguloNegroLateral.position = CGPoint(x: -self.convertWidth(w: self.anchura),y: -self.convertHeight(h: UIScreen.main.bounds.height/2))
            self.addChild(rectanguloNegroLateral)
        }
        
        
        // MARK: - LINEA SUPERIOR: (LIMITE SUPERIOR PORTERIA - LIMITE SUPERIOR IZUIERDO - LIMITE SUPERIOR DERECHO)

        // Definimos las referencias de las esquinas de la escena
        
        let goalTopLeft = CGPoint(x: self.minAnchuraUIScreenEnValorFrame, y: self.convertHeight(h:self.altura/4))
        let topLeft = CGPoint(x: self.minAnchuraUIScreenEnValorFrame,  y: self.convertHeight(h: self.altura/2))
        let topMiddle = CGPoint(x: self.frame.maxX, y: self.convertHeight(h:self.altura/2))

        // Definimos el path lateral top irquierdo
        let pathTopLeft = CGMutablePath()
        pathTopLeft.addLines(between: [goalTopLeft, topLeft, topMiddle])
        
        let drawableTopLeft = SKShapeNode(path: pathTopLeft)
        drawableTopLeft.strokeColor = self.color
        drawableTopLeft.lineWidth = 10 * self.ajuste
        self.addChild(drawableTopLeft)

        // Definimos el cuerpo top irquierdo
        let bodyTopLeft = SKPhysicsBody(edgeChainFrom: pathTopLeft)
        
        // MARK: - LINEA INFERIOR: (LIMITE INFERIOR PORTERIA - LIMITE INFERIOR IZUIERDO - LIMITE INFERIOR DERECHO)
        // Definimos las referencias de las esquinas de la escena
        
        let goalBottomLeft = CGPoint(x: self.minAnchuraUIScreenEnValorFrame, y: self.convertHeight(h:-self.altura/4))
        let bottomLeft = CGPoint(x: self.minAnchuraUIScreenEnValorFrame,  y: self.convertHeight(h:-self.altura/2))
        let bottomMiddle = CGPoint(x: self.frame.maxX, y: self.convertHeight(h:-self.altura/2))

        // Definimos el path lateral top irquierdo
        let pathBottomLeft = CGMutablePath()
        pathBottomLeft.addLines(between: [goalBottomLeft, bottomLeft, bottomMiddle])
        
        let drawableBottomLeft = SKShapeNode(path: pathBottomLeft)
        drawableBottomLeft.strokeColor = self.color
        drawableBottomLeft.lineWidth = 10 * self.ajuste
        self.addChild(drawableBottomLeft)

        // Definimos el cuerpo top irquierdo
        let bodyBottomLeft = SKPhysicsBody(edgeChainFrom: pathBottomLeft)
        
        // MARK: - Físicas
        self.physicsBody = SKPhysicsBody.init(bodies: [bodyTopLeft, bodyBottomLeft])
        //tenemos que indicar que no sea dinamico para que no le afecten fuerzas como la gravedad y se quede fijo en la escena, sino caería y no tendríamos límites
        self.physicsBody?.isDynamic = false
        
        // MARK: - Centro del campo
        
        let Circle = SKShapeNode(circleOfRadius: 150 * self.ajuste) // Size of Circle
        Circle.position = CGPoint(x: self.frame.maxX, y: self.frame.midY)  //Middle of Screen
        Circle.strokeColor = .black
        Circle.glowWidth = 2.0 * self.ajuste
        self.addChild(Circle)
        
        let puntoSuperiorLinea = CGPoint(x: self.frame.maxX, y: self.convertHeight(h:self.altura/2))
        let puntoInferiorLinea = CGPoint(x: self.frame.maxX, y: self.convertHeight(h:-self.altura/2))
        let lineaPath = CGMutablePath()
        lineaPath.addLines(between: [puntoSuperiorLinea, puntoInferiorLinea])
        let lineaMedio = SKShapeNode(path: lineaPath)
        lineaMedio.strokeColor = .black
        lineaMedio.lineWidth = 10 * self.ajuste
        self.addChild(lineaMedio)
        
        // MARK: - Límites físicos
        let rectanguloInferior = CGRect(x: self.minAnchuraUIScreenEnValorFrame, y: -self.convertHeight(h:self.altura/2), width: self.convertWidth(w: self.anchura), height: self.convertHeight(h:self.altura))
        let campoInferiorBody = SKPhysicsBody(edgeLoopFrom: rectanguloInferior)
        porteriaLado.physicsBody = campoInferiorBody
        
        // MARK: - Asignar
        self.physicsBody?.categoryBitMask = self.limitsCategoryMask
        porteriaLado.physicsBody?.categoryBitMask = self.midfieldCategoryMask
        
        
    }
    
    // MARK: -Funciones de los powerups
    
    func crearPowerUp() {

        self.powerUp = SKSpriteNode()
                
        self.powerUp?.size = CGSize(width: (self.paddle?.size.width)!, height: (self.paddle?.size.height)!)
        
        self.powerUp!.position.x = CGFloat.random(in: self.anchura/3..<self.anchura/2)
        self.powerUp!.position.y = CGFloat.random(in: (-self.altura/2)-50..<(self.altura/2)+50)
    
        
         let power = Int.random(in: 1..<4)
         if power == 1 {
             //fast
             self.powerUp!.name = "fast"
             self.powerUp!.texture = SKTexture(imageNamed: "fast")
         } else if power == 2{
             //slow
             self.powerUp!.name = "ice"
             self.powerUp!.texture = SKTexture(imageNamed: "ice")
         } else {
             //double points
             if !self.doublePoints {
                 self.powerUp!.name = "double"
                 self.powerUp!.texture = SKTexture(imageNamed: "double")
                 
             }
         }
        
        self.powerUp?.physicsBody = SKPhysicsBody(circleOfRadius: ((self.paddle?.size.width)! / 2) * self.ajuste)
        self.powerUp?.zRotation = -1.5708 //90 grados en radianes
        self.powerUp?.physicsBody?.isDynamic = false
        self.powerUp?.physicsBody?.categoryBitMask = self.powerUpsCategoryMask
        self.addChild(self.powerUp!)
     
    }
    

    // MARK: - Metodos del ciclo del juego
    
    override func update(_ currentTime: TimeInterval) {
        
        if self.appDelegate.powerUps {
            if self.contadorPowerUps == 200 {

                self.powerUp?.removeFromParent()
                self.powerUp = nil
                crearPowerUp()
                self.contadorPowerUps = 0
            }else{
                self.contadorPowerUps += 1
            }
        }
        
        if let puck = self.puck{
            if ((puck.position.x) < self.minAnchuraUIScreenEnValorFrame){
            //  - Incrementa la puntuacion del jugador correspondiente
//                self.scoreBottom = self.scoreBottom + 1

            //  - Define el punto de regeneracion del disco (en la mitad del campo del jugador contrario)
                let spawnPos = CGPoint(x:self.frame.midX,
                y:self.frame.midY)
                self.doublePoints = false
                self.connectService?.send(text: "goal")
          
                resetPuck(pos: spawnPos)
                
            }else if ((puck.position.x) > self.frame.maxX) && self.estoyEnCampo {
               
                
                let data: [String: Any] = [
                    "y" : self.convertHeightInverso(h: self.puck!.position.y),
                    "dx": self.puck!.physicsBody!.velocity.dx,
                    "dy": self.puck!.physicsBody!.velocity.dy
                ]
                let jsonString = stringify(json: data, prettyPrinted: true)
               
                self.estoyEnCampo = false
                self.connectService?.send(text: jsonString)
                
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

    func updateScore() {
        self.scoreboard?.text = String(score)
    }
    
    func resetPuck(pos : CGPoint) {
        self.puck?.physicsBody?.angularVelocity = 0
        self.puck?.physicsBody?.velocity = .zero
        //  - Situa el disco "puck" en pos

        self.puck!.position = CGPoint(x: minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/2), y: self.frame.midY)
        //  - Escalalo a 4.0
        self.puck?.physicsBody?.isDynamic = false
        self.puck?.setScale(4)
        //  - Pon la velocidad lineal y angular de su cuerpo físico a 0
        
        //  - Ejecuta una acción que lo escale a 1.0 durante 0.25s
        let scaleSmall = SKAction.scale(to: 1 * self.ajuste, duration: 0.25)
        let dynamicTrueAction = SKAction.run {
            self.puck?.physicsBody?.isDynamic = true
         }
        let sequence = SKAction.sequence([scaleSmall, dynamicTrueAction])
        self.puck?.run(sequence)
    }
    // MARK: -goToTitle
    func goToTitle() {
        
        self.connectService?.session.disconnect()
        self.connectService?.disconnect()
        self.appDelegate.connectService?.disconnect()
        
        let flip = SKTransition.flipHorizontal(withDuration: 0.25)
        
        if let scene = SKScene(fileNamed: "MenuScene"),
           let view = self.view
        {
            //reajusta el tamaño de la pantalla al cambiar de escena
            scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            view.presentScene(scene, transition: flip)
        }
    }

    // MARK: - Eventos de la pantalla tactil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(withTouch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(withTouch: t) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(withTouch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(withTouch: t) }
    }
    
    func touchDown(withTouch t : UITouch) {
                //  - Obten las coordenadas de t en la escena
        let position = t.location(in: self)
        //  - Comprueba si hay algun nodo en dichas coordenadas
        let nodoTocado = self.atPoint(position)
        //  - Si hay un nodo, y es paddleTop o paddleBottom, asocia a dicho nodo mediante el diccionario self.activeTouches.
        if(nodoTocado == paddle){ //|| nodoTocado == paddleTop){
            //self.activeTouches[t] = nodoTocado
            activeTouches[t] = createDragNode(linkedTo: nodoTocado)
        }
      
    }
    
    func touchMoved(withTouch t : UITouch) {
        //  - Obten las coordenadas de t en la escena
        let position = t.location(in: self)
        //  - Comprueba si hay algun nodo vinculado a t en self.activeTouches
        let nodoTocado = activeTouches[t]
        //  - Si es asi, mueve el nodo a la posicion de t
        if((nodoTocado) != nil){
            nodoTocado?.position = position
        }
        
    }
    
    func touchUp(withTouch t : UITouch) {
        
        if((activeTouches[t]) != nil){
            activeTouches[t]?.removeFromParent()
            activeTouches[t] = nil
        }
    }
    
    func createDragNode(linkedTo paddle: SKNode) -> SKNode {
        //  - Crea un nodo de tipo forma circular con radio `20`, situado en la posición del nodo paddle, añadelo a la escena.
        let resorte = SKShapeNode(circleOfRadius: 20)
        resorte.position = paddle.position
        self.addChild(resorte)
        //  - Asocia a dicho nodo un cuerpo físico estático, y desactiva su propiedad `isUserInteractionEnabled`
        resorte.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        resorte.physicsBody?.isDynamic = false
        resorte.isUserInteractionEnabled = false
        //  - Crea una conexión de tipo `SKPhysicsJointSpring` que conecte el nodo creado con paddle, con frequency 100.0 y damping 10.0.
        let conection = SKPhysicsJointSpring.joint(withBodyA: resorte.physicsBody!, bodyB: paddle.physicsBody!, anchorA: resorte.position, anchorB: paddle.position)
        conection.frequency = 100
        conection.damping = 10
        //  - Agrega la conexión al `physicsWorld` de la escena.
        self.physicsWorld.add(conection)
        //  - Devuelve el nodo que hemos creado
        return resorte
    }
    
    
    // MARK: - Metodos de SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {

//        Comprobamos todas las posibilidades de colisiones que hay
        if (contact.bodyA.node?.name == "fast"
            && contact.bodyB.node?.name == "puck" && !contact.bodyA.node!.isHidden){
            
            contact.bodyA.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! * 3, dy: (self.puck!.physicsBody?.velocity.dy)! * 3)

        }else if (contact.bodyB.node?.name == "fast"
        && contact.bodyA.node?.name == "puck" && !contact.bodyB.node!.isHidden){
            
            contact.bodyB.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! * 3, dy: (self.puck!.physicsBody?.velocity.dy)! * 3)
        }else if (contact.bodyA.node?.name == "ice"
            && contact.bodyB.node?.name == "puck" && !contact.bodyA.node!.isHidden){
            
            contact.bodyA.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! / 3, dy: (self.puck!.physicsBody?.velocity.dy)! / 3)
        }else if (contact.bodyB.node?.name == "ice"
        && contact.bodyA.node?.name == "puck" && !contact.bodyB.node!.isHidden){
            
            contact.bodyB.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! / 3, dy: (self.puck!.physicsBody?.velocity.dy)! / 3)
        }else if (contact.bodyA.node?.name == "double"
            && contact.bodyB.node?.name == "puck" && !contact.bodyA.node!.isHidden){
            contact.bodyA.node!.isHidden = true
            self.doublePoints = true
            self.connectService?.send(text: "double")

        }else if (contact.bodyB.node?.name == "double"
        && contact.bodyA.node?.name == "puck" && !contact.bodyB.node!.isHidden){
            contact.bodyB.node!.isHidden = true
            self.doublePoints = true
            self.connectService?.send(text: "double")
        }else if (contact.bodyA.node?.name == "puck"){
            contact.bodyA.node?.run(self.actionSoundHit)
        }else if (contact.bodyB.node?.name == "puck"){
            contact.bodyB.node?.run(self.actionSoundHit)
        }
    }
    
    func convertHeight(h : CGFloat) -> CGFloat{
        return (self.frame.height * h) / UIScreen.main.bounds.height
    }
    
    func convertHeightInverso(h : CGFloat) -> CGFloat{
        return (UIScreen.main.bounds.height * h) / self.frame.height
    }
    
    
    func convertWidth(w : CGFloat) -> CGFloat{
        return (self.frame.width * w) / UIScreen.main.bounds.width
    }
    
    func correctXPosition(p : CGFloat) -> CGFloat{
        return self.anchura * p / self.frame.width
    }

}

extension GameScene : GameControl {
    
    func setPowerUp(didReceive text: String) {
        self.doublePoints = true
    }
    
    
    func disconnect() {
        OperationQueue.main.addOperation {
            self.goToTitle()
        }
    }
    
    func didWin(_ win: String) {
        
        self.puck?.removeFromParent()
        self.doublePoints = false
    
        self.scoreboard?.zPosition = 2
        self.labelWins = childNode(withName: "//label_wins") as? SKLabelNode
        self.labelWins?.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura*3/4)
        self.labelWins?.fontSize = self.labelWins!.fontSize * self.ajuste
        self.labelWins?.fontColor = self.color
        self.labelWins?.text = "Has perdido"
        self.labelWins?.isHidden = false
        
        let bigScaleAction = SKAction.scale(to: 1.2, duration: 0.5)
        let originScaleAction = SKAction.scale(to: 1, duration: 0.5)
        let sequence = SKAction.sequence([bigScaleAction, originScaleAction])
        let actionRepeat = SKAction.repeat(sequence, count: 3)
        let actionRun = SKAction.run {
            self.goToTitle()
        }
        let finishSequence = SKAction.sequence([actionRepeat,actionRun])
        self.scoreboard!.run(finishSequence)
    
    }
    
    
    
    func didGoal(_ goal: String) {
        
        if self.doublePoints{
            self.score += 1
        }
        self.score += 1
        self.updateScore()
        self.doublePoints = false
        
        self.run(self.actionSoundGoal)
        if(self.score >= self.appDelegate.maxScore){
            
            self.connectService?.send(text: "win")
            
            self.scoreboard?.zPosition = 2
            self.labelWins = childNode(withName: "//label_wins") as? SKLabelNode
            self.labelWins?.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura*3/4)
            self.labelWins?.fontSize = self.labelWins!.fontSize * self.ajuste
            self.labelWins?.fontColor = self.color
            self.labelWins?.text = "Has ganado"
            self.labelWins?.isHidden = false
            
            self.puck?.removeFromParent()
            self.puck = nil
            let bigScaleAction = SKAction.scale(to: 1.2, duration: 0.5)
            let originScaleAction = SKAction.scale(to: 1, duration: 0.5)
            let sequence = SKAction.sequence([bigScaleAction, originScaleAction])
            let actionRepeat = SKAction.repeat(sequence, count: 3)
            let actionRun = SKAction.run {
                self.goToTitle()
            }
            let finishSequence = SKAction.sequence([actionRepeat,actionRun])
            
            self.scoreboard!.run(finishSequence)
            
        }else{
        
            let escalaGrande = SKAction.scale(to: 1.2, duration: 0.1)
            let escalaPequeno = SKAction.scale(to: 1, duration: 0.01)
            let sequence = SKAction.sequence([escalaGrande, escalaPequeno])
            let actionRepeat =  SKAction.repeat(sequence, count: 3)
            self.scoreboard!.run(actionRepeat)
           
        }
    }
    
    func puckService(didReceive text: String) {
        let data = text.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]
            {
                self.puck?.position.x = self.frame.maxX - 1
                self.puck?.position.y = self.convertHeight(h: jsonArray["y"] as! CGFloat * -1)
                self.puck?.physicsBody?.velocity = CGVector(dx: jsonArray["dx"] as! CGFloat * -1, dy: jsonArray["dy"] as! CGFloat * -1)
                self.estoyEnCampo = true
                
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
