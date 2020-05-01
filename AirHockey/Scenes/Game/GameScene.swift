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
    
    var contadorPowerUps = 0
    
    
    // MARK: - Session
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
    private let maxScore = 3
    
    // MARK: Powerups
    private var powerUpActivated : PowerUpsSpeed = .fast
    private var doublePoints : Bool = false;

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
        
        print(UIScreen.main.bounds.height)
        print(appDelegate.altura! as Any)
        print(self.frame.height)
        print(UIScreen.main.bounds.width)
        print(appDelegate.anchura! as Any)
        print(self.frame.width)
        
        self.ajuste = self.altura / UIScreen.main.bounds.height

        // TODO [B04] Obten las referencias a los nodos de la escena
        //self.paddleTop = childNode(withName: "//paddleTop") as? SKSpriteNode
        self.paddle = childNode(withName: "//paddleBottom") as? SKSpriteNode
        self.puck = childNode(withName: "//puck") as? SKSpriteNode
        
        self.paddle?.scale(to: CGSize(width: (self.paddle?.size.width)! * self.ajuste, height: (self.paddle?.size.height)! * self.ajuste))
        self.puck?.scale(to: CGSize(width: (self.puck?.size.width)! * self.ajuste, height: (self.puck?.size.height)! * self.ajuste))
        
        self.paddle!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/4)
        self.puck!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/2)
        
//        self.powerUpTop = childNode(withName: "//powerUpTop") as? SKSpriteNode
//        self.powerUpTop?.scale(to: CGSize(width: (self.powerUpTop?.size.width)! * self.ajuste, height: (self.powerUpTop?.size.height)! * self.ajuste))
//        self.powerUpTop!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/4)
//        self.powerUpTop?.isHidden = true
//
//        self.powerUpBottom = childNode(withName: "//powerUpBottom") as? SKSpriteNode
//        self.powerUpBottom?.scale(to: CGSize(width: (self.powerUpBottom?.size.width)! * self.ajuste, height: (self.powerUpBottom?.size.height)! * self.ajuste))
//        self.powerUpBottom!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/4)
//        self.powerUpBottom?.isHidden = true

        
        self.scoreboard = childNode(withName: "//score_bottom") as? SKLabelNode
        self.scoreboard?.fontSize = self.scoreboard!.fontSize * self.ajuste
        self.scoreboard!.position.x = minAnchuraUIScreenEnValorFrame + self.convertWidth(w: self.anchura/2)
        
        if !(self.connectService?.isBrowser ?? false){
            self.puck?.position = CGPoint(x: self.frame.maxX + 50, y: 0)
            self.estoyEnCampo = false
            self.color = #colorLiteral(red: 1, green: 0.2156862766, blue: 0.3725490272, alpha: 1)
            //self.puck?.removeFromParent()
            self.paddle?.texture = SKTexture(imageNamed: "paddle_red")
            self.scoreboard?.fontColor = self.color
        }

        // TODO [D05] Establece esta clase como el contact delegate del mundo fisico de la escena
        self.physicsWorld.contactDelegate = self
                
        self.createSceneLimits()
        self.updateScore()
        
        //self.physicsWorld.gravity = CGVector.zero
    }
    
    func createSceneLimits() {

        // TODO [C03] Define los limites del escenario como un cuerpo físico con forma edge loop de las dimensiones de la escena
        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // TODO [C11] Define los limites del escenario dejando los huecos de las porterias. Puedes utilizar dos cuerpos que definan cada uno de los laterales del escenario a partir de un path, y combinarlos en un unico cuerpo compuesto.
        
        // MARK: - PORTERIA
        // TODO [C12] Dibuja las dos porterias (rectangulos) y la linea de medio campo mediante nodos SKShapeNode
        let porteriaLado = SKShapeNode(rect: CGRect(x: self.minAnchuraUIScreenEnValorFrame - 20, y: -self.convertHeight(h: self.altura/4), width: self.convertWidth(w: self.anchura/4), height: self.convertHeight(h: self.altura/2)))
        if self.connectService?.isBrowser ?? false {
            porteriaLado.strokeColor = UIColor.blue
        }else {
            porteriaLado.strokeColor = UIColor.red
        }
        porteriaLado.glowWidth = 4.0  * self.ajuste
        self.addChild(porteriaLado)
        
        // MARK: - COSOS NEGROS
        //let rectanguloNegroSuperior = CGRect(x: self.minAnchuraUIScreenEnValorFrame, y: self.convertHeight(h:UIScreen.main.bounds.height), width: self.convertWidth(w: self.anchura), height: self.convertHeight(h:UIScreen.main.bounds.height - self.altura))
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
            //UIColor(red: 0, green: 0, blue: 0, alpha: 1)
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
        if self.connectService?.isBrowser ?? false {
            drawableTopLeft.strokeColor = UIColor.blue
        }else{
            drawableTopLeft.strokeColor = UIColor.red
        }
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
        if self.connectService?.isBrowser ?? false {
            drawableBottomLeft.strokeColor = UIColor.blue
        }else{
            drawableBottomLeft.strokeColor = UIColor.red
        }
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
        // TODO [C13] Define limites fisicos para cada uno de los dos campos de juego, y asocialos a nodos de la escena.
        let rectanguloInferior = CGRect(x: self.minAnchuraUIScreenEnValorFrame, y: -self.convertHeight(h:self.altura/2), width: self.convertWidth(w: self.anchura), height: self.convertHeight(h:self.altura))
        let campoInferiorBody = SKPhysicsBody(edgeLoopFrom: rectanguloInferior)
        porteriaLado.physicsBody = campoInferiorBody
        
        // MARK: - Asignar
        // TODO [C14] Asigna los cuerpos fisicos de limites de la escena y de cada campo su correspondiente categoria (categoryBitMask). En caso de cuerpos compuestos, solo es necesaria asociarla al cuerpo "padre"
        self.physicsBody?.categoryBitMask = self.limitsCategoryMask
        porteriaLado.physicsBody?.categoryBitMask = self.midfieldCategoryMask
        
        
    }
    
    // MARK: -Funciones de los powerups
    
    func loadTexture(_ node: SKSpriteNode) {
        
         self.addChild(node)
    }
    
    func crearPowerUp() {

        self.powerUp = SKSpriteNode()
                
        self.powerUp?.size = CGSize(width: (self.paddle?.size.width)! * self.ajuste, height: (self.paddle?.size.height)! * self.ajuste)
        
        self.powerUp!.position.x = CGFloat.random(in: self.convertWidth(w: self.anchura/3)..<self.convertWidth(w: self.anchura/3)+2)
        self.powerUp!.position.y = CGFloat.random(in: self.convertHeight(h: self.altura/4) / 2..<self.convertHeight(h: self.altura/4))
    
        
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
        
        self.powerUp?.physicsBody?.isDynamic = false
        self.powerUp?.physicsBody?.categoryBitMask = self.powerUpsCategoryMask
        self.addChild(self.powerUp!)
     
    }
    

    // MARK: - Metodos del ciclo del juego
    
    override func update(_ currentTime: TimeInterval) {
        
        if self.contadorPowerUps == 200 {
            print("Creando powerup")

            self.powerUp?.removeFromParent()
            self.powerUp = nil
            crearPowerUp()
            self.contadorPowerUps = 0
        }else{
            self.contadorPowerUps += 1
        }
        
        
        if let puck = self.puck{
                        // TODO [D01] Comprobamos si alguno de los jugadores ha metido gol (si la posición y del disco es superior a frame.maxY o inferior a frame.minY)
            if ((puck.position.x) < self.minAnchuraUIScreenEnValorFrame){
            //  - Incrementa la puntuacion del jugador correspondiente
//                self.scoreBottom = self.scoreBottom + 1

            //  - Define el punto de regeneracion del disco (en la mitad del campo del jugador contrario)
                let spawnPos = CGPoint(x:self.frame.midX,
                y:self.frame.midY)
                print("GOLAAAAAAAASO")
                self.doublePoints = false
                self.connectService?.send(text: "goal")
          
                resetPuck(pos: spawnPos)
                
              /*  goal(score: self.scoreBottom,marcador: self.scoreboardBottom!,
                textoWin: "BLUE WINS!",colorTexto: self.colorBotton,
                spawnPos: spawnPos)*/
            }else if ((puck.position.x) > self.frame.maxX) && self.estoyEnCampo {
                 print("Cambio de mapa")
                
                let data: [String: CGFloat] = [
                    "y" : (self.frame.maxY - self.puck!.position.y),
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
        // TODO [B05] Poner como texto de las etiquetas scoreboardTop y scoreboardBottom los valores scoreTop y scoreBottom respectivamente
        //self.scoreboardTop?.text = String(scoreTop)
        self.scoreboard?.text = String(score)
    }
    
    func resetPuck(pos : CGPoint) {
        // TODO [D08]
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
    // MARK: GOTOTITLE
    func goToTitle() {
        
        self.connectService?.session.disconnect()
        self.connectService?.disconnect()
        self.appDelegate.connectService?.disconnect()
        
        // TODO [D10] Cargamos la escena `MenuScene`, con modo aspectFill, y la presentamos mediante ua transicion de tipo `flipHorizontal` que dure 0.25s.
        let flip = SKTransition.flipHorizontal(withDuration: 0.25)
        
        if let scene = SKScene(fileNamed: "MenuScene"),
           let view = self.view
        {
            //reajusta el tamaño de la pantalla al cambiar de escena
            //scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            scene.scaleMode = .aspectFill
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
        // TODO [C05]
        print("tap")
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
        // TODO [C06]
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
        // TODO [C07]
        //  - Elimina la entrada t del diccionario self.activeTouches.
        //activeTouches[t] = nil
        
        // TODO [C10] Comprueba si hay algun nodo vinculado a t, y en tal caso eliminalo de la escena
        if((activeTouches[t]) != nil){
            activeTouches[t]?.removeFromParent()
            activeTouches[t] = nil
        }
    }
    
    func createDragNode(linkedTo paddle: SKNode) -> SKNode {
        // TODO [C08]
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
    
    // TODO [D06] Define el método didBegin(:). En caso de que alguno de los cuerpos que intervienen en el contacto sea el disco (' puck'), reproduce el audio `actionSoundHit`
    func didBegin(_ contact: SKPhysicsContact) {

    
        if (contact.bodyA.node?.name == "fast"
            && contact.bodyB.node?.name == "puck" && !contact.bodyA.node!.isHidden){
            print("Tocado top")
            contact.bodyA.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! * 3, dy: (self.puck!.physicsBody?.velocity.dy)! * 3)

        }else if (contact.bodyB.node?.name == "fast"
        && contact.bodyA.node?.name == "puck" && !contact.bodyB.node!.isHidden){
            print("Tocado top")
            contact.bodyB.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! * 3, dy: (self.puck!.physicsBody?.velocity.dy)! * 3)
        }else if (contact.bodyA.node?.name == "ice"
            && contact.bodyB.node?.name == "puck" && !contact.bodyA.node!.isHidden){
            print("Tocado bottom")
            contact.bodyA.node!.isHidden = true
            self.puck!.physicsBody?.velocity = CGVector(dx: (self.puck!.physicsBody?.velocity.dx)! / 3, dy: (self.puck!.physicsBody?.velocity.dy)! / 3)
        }else if (contact.bodyB.node?.name == "ice"
        && contact.bodyA.node?.name == "puck" && !contact.bodyB.node!.isHidden){
            print("Tocado bottom")
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
        if(self.score >= self.maxScore){
            
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
        
            // TODO [D07]
            //  - Crear una acción que repita 3 veces: escalar a 1.2 durante 0.1s, escalar a 1.0 durante 0.01s
            let escalaGrande = SKAction.scale(to: 1.2, duration: 0.1)
            let escalaPequeno = SKAction.scale(to: 1, duration: 0.01)
            let sequence = SKAction.sequence([escalaGrande, escalaPequeno])
            let actionRepeat =  SKAction.repeat(sequence, count: 3)
            self.scoreboard!.run(actionRepeat)
           
        }
    }
    
    func puckService(didReceive text: String) {
//        print("Hola desde puckService")
        let data = text.data(using: .utf8)!
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:CGFloat]
            {
                self.puck?.position.x = self.frame.maxX - 1
                self.puck?.position.y = self.frame.minY + jsonArray["y"]!
                self.puck?.physicsBody?.velocity = CGVector(dx: jsonArray["dx"]! * -1, dy: jsonArray["dy"]! * -1)
                self.estoyEnCampo = true
                
            } else {
                print("bad json")
            }
        } catch let error as NSError {
            print(error)
        }
    }
}
