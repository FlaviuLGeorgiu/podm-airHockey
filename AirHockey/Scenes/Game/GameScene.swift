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

// TODO [D04] Implementa el protocolo `SKPhysicsContactDelegate`
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Session
    var session : MCSession? = nil
    var connectService : MultipeerConnectService?
    
    var estoyEnCampo = true
    
    
    // MARK: - Referencias a nodos de la escena
    private var paddle : SKSpriteNode?
    //private var paddleTop : SKSpriteNode?
    private var puck : SKSpriteNode?
    private var scoreboard : SKLabelNode?
    private var labelWins : SKLabelNode?

    // MARK: Marcadores de los jugadores
    private var score : Int = 0
    //private var scoreTop : Int = 0
    private let maxScore = 2

    // MARK: Colores de los jugadores
    private var color = #colorLiteral(red: 0.3727632761, green: 0.3591359258, blue: 0.8980184197, alpha: 1)

    // MARK: Categorias de los objetos fisicos
    private let paddleCategoryMask : UInt32 = 0b0001
    private let puckCategoryMask : UInt32 = 0b0010
    private let limitsCategoryMask : UInt32 = 0b0100
    private let midfieldCategoryMask : UInt32 = 0b1000

    // MARK: Efectos de sonido
    // TODO [D02] Crear acciones para reproducir "goal.wav" y "hit.wav"
    private let actionSoundGoal =  SKAction.playSoundFileNamed("goal.wav", waitForCompletion: false)
    private let actionSoundHit =  SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)

    // MARK: Mapa de asociacion de touches con palas
    private var activeTouches : [UITouch : SKNode] = [:]
    
    private var diffHeight : CGFloat = 0.0
    private var altura : CGFloat = 0.0
    private var anchura : CGFloat = 0.0
    // MARK: - Inicializacion de la escena
    
    override func didMove(to view: SKView) {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.session = appDelegate.gameSession
        self.connectService = appDelegate.connectService
        self.connectService?.gameDelegate = self
        
        self.diffHeight = UIScreen.main.bounds.height - appDelegate.altura!
        self.altura = appDelegate.altura!
        self.anchura = appDelegate.anchura!
        print(UIScreen.main.bounds.height)
        print(appDelegate.altura)
        print(self.frame.height)
        
        // TODO [B04] Obten las referencias a los nodos de la escena
        //self.paddleTop = childNode(withName: "//paddleTop") as? SKSpriteNode
        self.paddle = childNode(withName: "//paddleBottom") as? SKSpriteNode
        self.puck = childNode(withName: "//puck") as? SKSpriteNode
        
        self.scoreboard = childNode(withName: "//score_bottom") as? SKLabelNode
        
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
        let goalWidthLado = self.altura / 2
        // MARK: - Top Left
        // Definimos las referencias de las esquinas de la escena
        
        let goalTopLeft = CGPoint(x: self.frame.minX, y: self.convertHeight(h:self.altura/4))
        let topLeft = CGPoint(x: self.frame.minX,  y: self.convertHeight(h: self.altura/2))
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
        drawableTopLeft.lineWidth = 10
        self.addChild(drawableTopLeft)

        // Definimos el cuerpo top irquierdo
        let bodyTopLeft = SKPhysicsBody(edgeChainFrom: pathTopLeft)
        
        // MARK: - Bottom Left
        // Definimos las referencias de las esquinas de la escena
        
        let goalBottomLeft = CGPoint(x: self.frame.minX, y: self.convertHeight(h:-self.altura/4))
        let bottomLeft = CGPoint(x: self.frame.minX,  y: self.convertHeight(h:-self.altura/2))
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
        drawableBottomLeft.lineWidth = 10
        self.addChild(drawableBottomLeft)

        // Definimos el cuerpo top irquierdo
        let bodyBottomLeft = SKPhysicsBody(edgeChainFrom: pathBottomLeft)
        
        // MARK: - Físicas
        self.physicsBody = SKPhysicsBody.init(bodies: [bodyTopLeft, bodyBottomLeft])
        //tenemos que indicar que no sea dinamico para que no le afecten fuerzas como la gravedad y se quede fijo en la escena, sino caería y no tendríamos límites
        self.physicsBody?.isDynamic = false
        
        // MARK: - Pinta Porterías
        // TODO [C12] Dibuja las dos porterias (rectangulos) y la linea de medio campo mediante nodos SKShapeNode
        let porteriaLado = SKShapeNode(rect: CGRect(x: self.convertWidth(w: -self.anchura), y: -self.convertHeight(h: self.altura/4), width: self.convertWidth(w: self.anchura*3/4), height: self.convertHeight(h: self.altura/2)))
        if self.connectService?.isBrowser ?? false {
            porteriaLado.strokeColor = UIColor.blue
        }else {
            porteriaLado.strokeColor = UIColor.red
        }
        porteriaLado.glowWidth = 4.0
        self.addChild(porteriaLado)
        
        let Circle = SKShapeNode(circleOfRadius: 150 ) // Size of Circle
        Circle.position = CGPoint(x: self.frame.maxX, y: self.frame.midY)  //Middle of Screen
        Circle.strokeColor = .black
        Circle.glowWidth = 2.0
        self.addChild(Circle)
        
        let puntoSuperiorLinea = CGPoint(x: self.frame.maxX, y: self.frame.maxY)
        let puntoInferiorLinea = CGPoint(x: self.frame.maxX, y: self.frame.minY)
        let lineaPath = CGMutablePath()
        lineaPath.addLines(between: [puntoSuperiorLinea, puntoInferiorLinea])
        let lineaMedio = SKShapeNode(path: lineaPath)
        lineaMedio.strokeColor = .black
        lineaMedio.lineWidth = 10
        self.addChild(lineaMedio)
        
        // MARK: - Límites físicos
        // TODO [C13] Define limites fisicos para cada uno de los dos campos de juego, y asocialos a nodos de la escena.
        
        let rectanguloInferior = CGRect(x: self.frame.minX, y: self.frame.maxY, width: self.frame.width, height: self.frame.height)
        let campoInferiorBody = SKPhysicsBody(edgeLoopFrom: rectanguloInferior)
        porteriaLado.physicsBody = campoInferiorBody
        
        // MARK: - Asignar
        // TODO [C14] Asigna los cuerpos fisicos de limites de la escena y de cada campo su correspondiente categoria (categoryBitMask). En caso de cuerpos compuestos, solo es necesaria asociarla al cuerpo "padre"
        self.physicsBody?.categoryBitMask = self.limitsCategoryMask
        porteriaLado.physicsBody?.categoryBitMask = self.midfieldCategoryMask
        
        
    }

    // MARK: - Metodos del ciclo del juego
    
    override func update(_ currentTime: TimeInterval) {
        
        
        
        
        if let puck = self.puck{
            // TODO [D01] Comprobamos si alguno de los jugadores ha metido gol (si la posición y del disco es superior a frame.maxY o inferior a frame.minY)
            if ((puck.position.x) < self.frame.minX){
            //  - Incrementa la puntuacion del jugador correspondiente
//                self.scoreBottom = self.scoreBottom + 1

            //  - Define el punto de regeneracion del disco (en la mitad del campo del jugador contrario)
                let spawnPos = CGPoint(x:self.frame.midX,
                y:self.frame.midY)
                //self.puck?.position = spawnPos
            //  - Llama a `goal` indicando los datos del marcador que debe resaltar, el texto a mostrar en pantalla en caso de ganar la partida, su color, y el punto de regeneracion del disco.
                print("GOLAAAAAAAASO")
                
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
            
            /*if ((puck.position.y) < self.frame.minY){
            //  - Incrementa la puntuacion del jugador correspondiente
                self.scoreTop = self.scoreTop + 1

            //  - Define el punto de regeneracion del disco (en la mitad del campo del jugador contrario)
                let spawnPos = CGPoint(x:self.frame.midX,
                y:self.frame.origin.y +
                  self.frame.size.height * 0.25)
                //self.puck?.position = spawnPos
            //  - Llama a `goal` indicando los datos del marcador que debe resaltar, el texto a mostrar en pantalla en caso de ganar la partida, su color, y el punto de regeneracion del disco.
                goal(score: self.scoreTop,marcador: self.scoreboardTop!,
                textoWin: "RED WINS!",colorTexto: self.colorTop,
                spawnPos: spawnPos)
            }*/
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
        self.puck?.position = pos
        //  - Escalalo a 4.0
        self.puck?.physicsBody?.isDynamic = false
        self.puck?.setScale(4)
        //  - Pon la velocidad lineal y angular de su cuerpo físico a 0
        
        //  - Ejecuta una acción que lo escale a 1.0 durante 0.25s
        let scaleSmall = SKAction.scale(to:1, duration: 0.25)
        let dynamicTrueAction = SKAction.run {
            self.puck?.physicsBody?.isDynamic = true
         }
        let sequence = SKAction.sequence([scaleSmall, dynamicTrueAction])
        self.puck?.run(sequence)
    }
    
    func goToTitle() {
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
        
        // TODO [C09] En lugar de asociar en self.activeTouches el nodo encontrado a t, llama a createDragNode(linkedTo:) para crear un nuevo nodo conectado a la pala, y asocia dicho nodo al touch
        
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
        if (contact.bodyA.node?.name == "puck"){
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

}

extension GameScene : GameControl {
    func didWin(_ win: String) {
    
        self.scoreboard?.zPosition = 2
        self.labelWins = childNode(withName: "//label_wins") as? SKLabelNode
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
        self.score += 1
        self.updateScore()
        
        self.run(self.actionSoundGoal)
        if(self.score == self.maxScore){
            
            self.connectService?.send(text: "win")
            
            self.scoreboard?.zPosition = 2
            self.labelWins = childNode(withName: "//label_wins") as? SKLabelNode
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
