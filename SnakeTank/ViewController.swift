//
//  ViewController.swift
//  SnakeTank
//
//  Created by Jenn Halvorsen on 8/30/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, refreshDelegate, BrothersUIAutoLayout, UIGestureRecognizerDelegate {
    
    let cover = UIView()
    var score = UILabel()
    var scoreInt = Int() {didSet{score.text = String(scoreInt); Global.points = scoreInt}}
    let view3 = SKView()
    let instructionLabel = UILabel()
    var timer = Timer()
    var myScheme: ColorScheme?
    var wrapper = SCNNode()
    var snakeTail = [SCNNode]()
    var timer1 = Timer()
    var timer2 = Timer()
    var timer3 = Timer()
    var swipeUp = UISwipeGestureRecognizer()
    var swipeDown = UISwipeGestureRecognizer()
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var tap = UITapGestureRecognizer()
    var foodArray = [SCNNode]()
   // var foodLabels = [SCNLabelNode]()
    let foodSize: CGFloat = 3.5
    var snakeHead = SCNNode()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myScheme = ColorScheme(rawValue: UserDefaults.standard.integer(forKey: "colorScheme"))
        CustomColor.changeCustomColor(colorScheme: myScheme!)
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/snake.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        score.frame = CGRect(x: 0, y: 20*sh, width: 375*sw, height: 86*sh)
        score.font = UIFont(name: "HelveticaNeue-Bold", size: 72*fontSizeMultiplier)
        score.textColor = CustomColor.color3
        score.alpha = 1.0
        score.textAlignment = .center
        score.text = String(Global.points)
        view3.addSubview(score)
        
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        wrapper = scene.rootNode.childNode(withName: "wrapper", recursively: false)!
        snakeHead = wrapper.childNode(withName: "headHinge", recursively: false)!.childNode(withName: "head", recursively: false)!
    }
    
    private func startScene() {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goUp(_:)))
        swipeUp.direction = .up
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goDown(_:)))
        swipeDown.direction = .down
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goRight(_:)))
        swipeRight.direction = .right
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.goLeft(_:)))
        swipeLeft.direction = .left
        
        for _ in 0...6 {
            addFood(value: 2)
        }
        //snake tail time
        timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(ViewController.followFunc), userInfo: nil, repeats: true)
        //monster timer
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.monsterFunc), userInfo: nil, repeats: true)
        //add monster timer
        timer3 = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(ViewController.addRandomMonster), userInfo: nil, repeats: true)
    }
    
    func changeScore(amount: Int) {
        
        scoreInt += amount
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sceneView.addGestureRecognizer(swipeUp)
        sceneView.addGestureRecognizer(swipeDown)
        sceneView.addGestureRecognizer(swipeRight)
        sceneView.addGestureRecognizer(swipeLeft)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.fireFunc(_:)))
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    var myGameOverView = GameOverView()
    var once = true
    func gameOver() {
        if once {
            once = false
            if Global.points > Global.topScore {
                Global.topScore = Global.points
                UserDefaults.standard.set(Global.points, forKey: "snakeTopScore")
                // GCHelper.sharedInstance.reportLeaderboardIdentifier("highscore123654", score: Global.points)
            }
            
            myGameOverView = GameOverView(backgroundColor: .black, buttonsColor: .white, bestScore: Global.topScore, thisScore: Global.points, colorScheme: myScheme!, vc: self)
         
            view.addSubview(myGameOverView)
            Global.delay(bySeconds: 5.0) {
                self.once = true
            }
            
            
            
        }
    }
    
    private func addSphere() {
       
        let shape = SCNSphere(radius: 1)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.green
        shape.materials = [sphereMaterial]
        let sphere = SCNNode(geometry: shape)
        sphere.position =  SCNVector3(x: 0, y: 0, z: 0)
        let physShape = SCNPhysicsShape(geometry: shape, options: nil)
        
        let sphereBodys = SCNPhysicsBody(type: .kinematic, shape: physShape)
        sphere.physicsBody = sphereBodys
        
        sphere.physicsBody?.isAffectedByGravity = false
        sphere.physicsBody?.categoryBitMask = 25
        sphere.physicsBody?.collisionBitMask = 0
      //  sphere.physicsBody?.contactTestBitMask = 5 | 25
        
        sceneView.scene.rootNode.addChildNode(sphere)
        snakeTail.append(sphere)
        
    }
    
    var activityView = UIActivityIndicatorView()
    private func purchase(productId: String = "muskrat.IAP.something") {
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView.center = self.view.center
        activityView.startAnimating()
        activityView.alpha = 0.0
        self.view.addSubview(activityView)
        //        SwiftyStoreKit.purchaseProduct(productId) { result in
        //            switch result {
        //            case .success( _):
        //                Global.isPremium = true
        //                UserDefaults.standard.set(true, forKey: "isPremiumMember")
        //                self.activityView.removeFromSuperview()
        //            case .error(let error):
        //
        //                print("error: \(error)")
        //                print("Purchase Failed: \(error)")
        //                self.activityView.removeFromSuperview()
        //            }
        //        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
//    private func addFood(value: Int) {
//        let randomX = CGFloat(arc4random_uniform(370))*sw
//        let randomY = CGFloat(arc4random_uniform(662))*sh
//        let rect = CGRect(x: 0, y: 0, width: foodSize*ballRadius*sw, height: foodSize*ballRadius*sw)
//        let food = SKShapeNode(rect: rect, cornerRadius: sw)
//        
//        food.position = CGPoint(x: randomX, y: randomY)
//        food.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
//        food.physicsBody?.categoryBitMask = 10
//        food.physicsBody?.collisionBitMask = 0
//        
//        
//        food.zPosition = 10000
//        
//        let myLabel = SKLabelNode(fontNamed:"HelveticaNeue-Bold")
//        myLabel.text = String(value)
//        myLabel.fontSize = 7*fontSizeMultiplier
//        myLabel.horizontalAlignmentMode = .center
//        myLabel.verticalAlignmentMode = .center
//        myLabel.position = CGPoint(x: 0.5*foodSize*ballRadius*sw, y: foodSize*ballRadius*sw/2)
//        myLabel.zPosition = 10001
//        myLabel.fontColor = .white
//        foodArray.append(food)
//        foodLabels.append(myLabel)
//        
//        food.addChild(myLabel)
//        addChild(food)
//    }
    
    let monsterDictionary : [Int:Monster] = [
        0:.zombie,
        1:.eagle,
        2:.butterfly,
        3:.tiger,
        4:.mouse,
        5:.deer
    ]
    
    @objc private func addRandomMonster() {
        
        let random = Int(arc4random_uniform(6))
        addMonster(type: monsterDictionary[random]!)
        if monsterDictionary[random]! == .zombie {
            addMonster(type: .zombie)
            addMonster(type: .zombie)
        } else if monsterDictionary[random]! == .butterfly {
            addMonster(type: .butterfly)
        }
    }
    
    var isFirstTap = true
    @objc func fireFunc(_ tapOnScreen: UITapGestureRecognizer) {
        print("tap!")
        
            guard snakeTail.count > 0 else {return}
            let shotSpeed = duration/6
            //addSphereToFire()
        
            switch direction! {
            case .up:
                break
                //shoot up
            case .down:
                break
                //shoot down
            case .right:
                break
                //shoot right
            case .left:
                break
                //shoot left
            default:
                break
            }
        
        
    }
    
    let timeInterval = 0.05
    let trailTime = 0.05
    let snakeSpeed: CGFloat = 1200
    @objc func followFunc() {
        guard snakeTail.count > 0 else {return}
        for i in 1..<snakeTail.count {
            let moveObject = SCNAction.move(to: snakeTail[i-1].position, duration: trailTime)
            snakeTail[i].runAction(moveObject)
        }
        let moveObject = SCNAction.move(to: CGPoint(x: snakeHead.position.x - ballRadius*sw, y: snakeHead.position.y - ballRadius*sh), duration: trailTime + 0.01)
        snakeTail[0].runAction(moveObject)
        
    }
    
    enum Facing {
        case up,down,left,right
    }
    var direction: Facing? = .up
    var duration: Double = 10
    @objc private func goUp(_ swipe: UISwipeGestureRecognizer?) {
        print("swipeup")
        let moveObject = SCNAction.move(to: CGPoint(x:snakeHead.position.x, y:snakeHead.position.y + snakeSpeed*sh), duration: duration)
        snakeHead.runAction(moveObject)
        if direction == .down {
            snakeHead.removeAllActions()
        }
        direction = .up
    }
    @objc private func goDown(_ swipe: UISwipeGestureRecognizer?) {
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x, y:snakeHead.position.y - snakeSpeed*sh), duration: duration)
        snakeHead.run(moveObject)
        if direction == .up {
            snakeHead.removeAllActions()
        }
        direction = .down
        
    }
    @objc private func goRight(_ swipe: UISwipeGestureRecognizer?) {
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x + snakeSpeed*sh, y:snakeHead.position.y), duration: duration)
        snakeHead.run(moveObject)
        if direction == .left {
            snakeHead.removeAllActions()
        }
        direction = .right
        
    }
    @objc private func goLeft(_ swipe: UISwipeGestureRecognizer?) {
        
        let moveObject = SKAction.move(to: CGPoint(x:snakeHead.position.x - snakeSpeed*sh, y:snakeHead.position.y), duration: duration)
        snakeHead.run(moveObject)
        if direction == .right {
            snakeHead.removeAllActions()
        }
        direction = .left
        
    }
    
    private func delayAdd() {
        let myDouble = Double(arc4random_uniform(5)) + 1.0
        Global.delay(bySeconds: myDouble) {
            let random = Int(arc4random_uniform(2))
            if random == 0 {
                self.addFood(value: Int(arc4random_uniform(UInt32(self.topFoodAmount))) + 1)
            } else {
                self.addFood(value: Int(arc4random_uniform(2)) + 1)
            }
        }
    }
    
    
    private func addTails(amount: Int) {
        
        for i in 0..<amount {
            
            let tail = addOneTail()
            tail.zPosition = 10000 - CGFloat(i)
            tail.physicsBody?.categoryBitMask = 5
            //  tail.physicsBody?.contactTestBitMask = 666
            tail.physicsBody?.affectedByGravity = false
            snakeTail.append(tail)
            addChild(tail)
        }
        
    }
    
    private func addOneTail() -> SKShapeNode {
        let rect = CGRect(x: 0, y: 0, width: 2*ballRadius*sw, height: 2*ballRadius*sw)
        let tail = SKShapeNode(rect: rect, cornerRadius: sw)
        tail.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rect.size.width, height: rect.size.height), center: CGPoint(x: tail.frame.midX, y: tail.frame.midY))
        //    tail.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: rect.size.width + 2, height: rect.size.height + 2))
        //tail.physicsBody = SKPhysicsBody(edgeLoopFrom: rect)
        tail.physicsBody?.affectedByGravity = false
        // tail.physicsBody?.contactTestBitMask = 666
        tail.physicsBody?.collisionBitMask = 0
        tail.position = CGPoint(x: snakeHead.position.x - ballRadius*sw, y: snakeHead.position.y - ballRadius*sw)
        tail.fillColor = .white
        return tail
    }
    
    enum Monster {
        case zombie, eagle, butterfly, tiger, mouse, deer
    }
    
    enum MonsterEnterance {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    @objc func monsterFunc() {
        
        for (node,type) in monsters {
            var sign:CGFloat = -1
            let random = arc4random_uniform(2)
            if random == 1 {
                sign = 1
            }
            var sign2:CGFloat = -1
            let random2 = arc4random_uniform(2)
            if random2 == 1 {
                sign2 = 1
            }
            
            
            switch type {
            case .zombie:
                let distance: CGFloat = abs(node.position.x - snakeHead.position.x) + abs(node.position.y - snakeHead.position.y)
                let moveObject = SKAction.move(to: CGPoint(x: snakeHead.position.x, y: snakeHead.position.y), duration: Double(distance/15))
                node.run(moveObject)
            case .eagle:
                var locationX = CGFloat()
                var locationY = CGFloat()
                if node.position.x > 60 && node.position.x < 315 {
                    
                    locationX = node.position.x - 50*sign
                    
                } else if node.position.x > 60 {
                    locationX = node.position.x - 50
                } else {
                    locationX = node.position.x + 50
                }
                if node.position.y > 60 && node.position.y < 607 {
                    
                    locationY = node.position.y - 50*sign2
                    
                } else if node.position.y > 60 {
                    locationY = node.position.y - 50
                } else {
                    locationY = node.position.y + 50
                }
                
                let moveObject = SKAction.move(to: CGPoint(x: locationX, y: locationY), duration: 0.5)
                node.run(moveObject)
            case .butterfly:
                var locationX = CGFloat()
                var locationY = CGFloat()
                if node.position.x > 60 && node.position.x < 315 {
                    
                    locationX = node.position.x - 50*sign
                    
                } else if node.position.x > 60 {
                    locationX = node.position.x - 50
                } else {
                    locationX = node.position.x + 50
                }
                if node.position.y > 60 && node.position.y < 607 {
                    
                    locationY = node.position.y - 50*sign2
                    
                } else if node.position.y > 60 {
                    locationY = node.position.y - 50
                } else {
                    locationY = node.position.y + 50
                }
                
                let moveObject = SKAction.move(to: CGPoint(x: locationX, y: locationY), duration: 1.0)
                node.run(moveObject)
            case .tiger:
                let distance: CGFloat = abs(node.position.x - snakeHead.position.x) + abs(node.position.y - snakeHead.position.y)
                let moveObject = SKAction.move(to: CGPoint(x: snakeHead.position.x, y: snakeHead.position.y), duration: Double(distance/75))
                node.run(moveObject)
            case .mouse:
                let x = node.position.x
                let y = node.position.y
                if (x > 325 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 355, y: 20), duration: 5.0)
                    node.run(moveObject)
                    
                } else if (x < 50 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 647), duration: 2.5)
                    node.run(moveObject)
                } else if (x > 325 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 20), duration: 5.0)
                    node.run(moveObject)
                } else if (x < 50 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 355, y: 647), duration: 2.5)
                    node.run(moveObject)
                }
                
            case .deer:
                let x = node.position.x
                let y = node.position.y
                if (x > 325 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 20), duration: 15.0)
                    node.run(moveObject)
                    
                } else if (x < 50 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 335, y: 20), duration: 7.5)
                    node.run(moveObject)
                } else if (x > 325 && y < 50) {
                    let moveObject = SKAction.move(to: CGPoint(x: 20, y: 647), duration: 15.0)
                    node.run(moveObject)
                } else if (x < 50 && y > 617) {
                    let moveObject = SKAction.move(to: CGPoint(x: 335, y: 647), duration: 7.5)
                    node.run(moveObject)
                }
                
            }
        }
    }
    
    
    
    func chooseRandomEnterance() -> CGPoint {
        let random = arc4random_uniform(4)
        var location = CGPoint()
        switch random {
        case 0:
            location = CGPoint(x: 8*sw, y: 8*sh)
        case 1:
            location = CGPoint(x: 8*sw, y: 659*sh)
        case 2:
            location = CGPoint(x: 367*sw, y: 8*sh)
        default:
            location = CGPoint(x: 367*sw, y: 659*sh)
            
        }
        return location
    }
    var monsters = [(SKShapeNode,Monster)]()
    func addMonster(type: Monster) {
        let enteranceLocation = chooseRandomEnterance()
        switch type {
        case .zombie:
            let zombie = Zombie(origin: enteranceLocation)
            monsters.append((zombie,.zombie))
            addChild(zombie)
        case .eagle:
            let eagle = Eagle(origin: enteranceLocation)
            monsters.append((eagle,.eagle))
            addChild(eagle)
        case .butterfly:
            let butterfly = Butterfly(origin: enteranceLocation)
            monsters.append((butterfly,.butterfly))
            addChild(butterfly)
        case .tiger:
            let tiger = Tiger(origin: enteranceLocation)
            monsters.append((tiger,.tiger))
            addChild(tiger)
        case .mouse:
            let mouse = Mouse(origin: enteranceLocation)
            monsters.append((mouse,.mouse))
            addChild(mouse)
            
        case .deer:
            let deer = Deer(origin: enteranceLocation)
            monsters.append((deer,.deer))
            addChild(deer)
        }
    }
    
    private func resetGame() {
        
        timer1.invalidate()
        timer2.invalidate()
        timer3.invalidate()
        self.removeAllChildren()
        snakeTail.removeAll()
        monsters.removeAll()
        foodArray.removeAll()
        
        
        
    }
    
    func restartGame() {
        
        snakeHead = SKShapeNode(circleOfRadius: ballRadius*sw )
        snakeHead.position = CGPoint(x: 100*sw, y: 333.5*sh)
        snakeHead.fillColor = .black
        snakeHead.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius*sw)
        snakeHead.physicsBody?.affectedByGravity = false
        snakeHead.physicsBody?.categoryBitMask = 1
        snakeHead.physicsBody?.contactTestBitMask = 10 | 100
        snakeHead.physicsBody?.collisionBitMask = 0
        snakeHead.zPosition = 10001
        
        addChild(snakeHead)
        
        for _ in 0...6 {
            addFood(value: 2)
        }
        
        //snake tail time
        timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GameScene.followFunc), userInfo: nil, repeats: true)
        //monster timer
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameScene.monsterFunc), userInfo: nil, repeats: true)
        //add monster timer
        timer3 = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(GameScene.addRandomMonster), userInfo: nil, repeats: true)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("didbegin")
        print("A: \(contact.bodyA.categoryBitMask)")
        print("B: \(contact.bodyB.categoryBitMask)")
        
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("ate monster!")
            if let item = contact.bodyB.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
            
        } else if contact.bodyA.categoryBitMask == 10 && contact.bodyB.categoryBitMask == 1 {
            
            // head hit food
            print("EAT")
            if let item = contact.bodyA.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<foodArray.count {
                    if item == foodArray[i] {
                        let amount = Int(foodLabels[i].text!)!
                        delegateRefresh?.changeScore(amount: amount)
                        foodArray.remove(at: i)
                        foodLabels.remove(at: i)
                        addTails(amount: amount)
                        
                        delayAdd()
                        break loop
                    }
                }
            }
        } else if contact.bodyA.categoryBitMask == 100 && contact.bodyB.categoryBitMask == 1 {
            //hit wall
            print("hit wall")
            switch direction! {
            case .up:
                goDown(nil)
            case .down:
                goUp(nil)
            case .left:
                goRight(nil)
            case .right:
                goLeft(nil)
            default:
                break
            }
            
        } else if contact.bodyA.categoryBitMask == 5 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("monster attack!")
            delegateRefresh?.gameOver()
            resetGame()
            
        } else if contact.bodyA.categoryBitMask == 25 && contact.bodyB.categoryBitMask == 666 {
            // monster gotchya
            print("shot monster!")
            if let item = contact.bodyB.node as? SKShapeNode {
                item.removeFromParent()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
            
        }
        
        
        
    }
    
    func moveSprite(sprite: SKShapeNode, location: CGPoint) {
        let action = SKAction.move(to: location, duration: 0.0)
        sprite.run(action)
    }
    
    func lockSprite(sprite: SKShapeNode, isDynamic: Bool) {
        sprite.physicsBody?.isDynamic = isDynamic
    }
    
    func colorSprite(sprite: SKShapeNode, colorString: String) {
        switch colorString {
        case "color1":
            sprite.fillColor = CustomColor.color1
        case "color2":
            sprite.fillColor = CustomColor.color2
        case "color3":
            sprite.fillColor = CustomColor.color3
        case "color4":
            sprite.fillColor = CustomColor.color4
        case "boundaryColor": break
        //        sprite.fillColor = CustomColor.boundaryColor
        default:
            break
        }
    }
    
    var touchOnce = true
    var touchDownPoint = CGPoint()
    //    func touchDown(atPoint pos : CGPoint) {
    //        if touchOnce {
    //            //        delegateRefresh?.fire()
    //            //        fired = false
    //            touchDownPoint = pos
    //            endTouchLocation = pos
    //            startTouchLocation = pos
    //            //        delegateRefresh?.refresh(start: startTouchLocation, end: endTouchLocation)
    //            //        delegateRefresh?.turn(on: true)
    //        }
    //    }
    //    var previouslySavedTouch = CGPoint()
    //    var savedTouch = CGPoint(x: 0,y: 0)
    //    func touchMoved(toPoint pos : CGPoint) {
    //        if touchOnce {
    //            //        endTouchLocation = pos
    //            //        delegateRefresh?.refresh(start: startTouchLocation, end: endTouchLocation)
    //            //            previouslySavedTouch = savedTouch
    //            //            savedTouch = pos
    //        }
    //    }
    //
    //
    //
    //    func touchUp(atPoint pos : CGPoint) {
    //        if touchOnce {
    //            endTouchLocation = previouslySavedTouch
    //            guard abs(pos.x - touchDownPoint.x) > 2 || abs(pos.y - touchDownPoint.y) > 2 else {return}
    //
    //            endTouchLocation = pos
    //            let dx = startTouchLocation.x - endTouchLocation.x
    //            let dy = startTouchLocation.y - endTouchLocation.y
    //            let amplitude = CGFloat(sqrt(Double(dx*dx + dy*dy)))
    //            //            icsBody?.applyImpulse(CGVector(dx: -16000*dx/amplitude, dy: -16000*dy/amplitude))
    //
    //            //            timer1 = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) {_ in
    //            //                self.changeDamping(amount: 3)
    //            //            }
    //            //            timer2 = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: false) {_ in
    //            //                self.changeDamping(amount: 10)
    //            //            }
    //            //            timer3 = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) {_ in
    //            //                self.changeDamping(amount: self.initialDamping)
    //            //            }
    //
    //
    //            touchOnce = false
    //            Global.delay(bySeconds: 0.5) {
    //                self.touchOnce = true
    //            }
    //        }
    //
    //    }
    //
    func tapTouch() {
        if touchOnce {
            guard abs(startTouchLocation.x - endTouchLocation.x) > 2 || abs(startTouchLocation.y - endTouchLocation.y) > 2 else {return}
            
            //            timer1.invalidate()
            //            timer2.invalidate()
            //            timer3.invalidate()
            
            let dx = startTouchLocation.x - endTouchLocation.x
            let dy = startTouchLocation.y - endTouchLocation.y
            let amplitude = CGFloat(sqrt(Double(dx*dx + dy*dy)))
            
            //            timer1 = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) {_ in
            //                self.changeDamping(amount: 3)
            //            }
            //            timer2 = Timer.scheduledTimer(withTimeInterval: 5.5, repeats: false) {_ in
            //                self.changeDamping(amount: 10)
            //            }
            //            timer3 = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) {_ in
            //                self.changeDamping(amount: self.initialDamping)
            //            }
            
            touchOnce = false
            Global.delay(bySeconds: 0.5) {
                self.touchOnce = true
            }
        }
        
    }
}
