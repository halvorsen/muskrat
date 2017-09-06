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

class ViewController: UIViewController, ARSCNViewDelegate, BrothersUIAutoLayout, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate {
    
    let cover = UIView()
    var score = UILabel()
    var scoreInt = Int() {didSet{score.text = String(scoreInt); Global.points = scoreInt}}
   
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
    var snakeHinge = SCNNode()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myScheme = ColorScheme(rawValue: UserDefaults.standard.integer(forKey: "colorScheme"))
        CustomColor.changeCustomColor(colorScheme: myScheme!)
        // Set the view's delegate
        sceneView.delegate = self
        
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
        view.addSubview(score)
        
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        wrapper = scene.rootNode.childNode(withName: "wrapper", recursively: false)!
        snakeHead = wrapper.childNode(withName: "headHinge", recursively: false)!.childNode(withName: "head", recursively: false)!
        snakeHinge = wrapper.childNode(withName: "headHinge", recursively: false)!
        
        startScene()
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
//
//        for _ in 0...6 {
//            addFood(value: 2)
//        }
        //snake tail time
        timer1 = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(ViewController.followFunc), userInfo: nil, repeats: true)
        //monster timer
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ViewController.monsterFunc), userInfo: nil, repeats: true)
        //add monster timer
        timer3 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.addRandomMonster), userInfo: nil, repeats: true)
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
       
        let shape = SCNSphere(radius: Global.monsterRadius)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.emission.contents = [UIColor.black]
        sphereMaterial.selfIllumination.contents = [UIColor.blue]
        sphereMaterial.reflective.contents = [UIColor.black]
       // sphereMaterial.
        shape.materials = [sphereMaterial]
        let sphere = SCNNode(geometry: shape)
        sphere.position =  SCNVector3(x: 0, y: 0, z: 0)
        let physShape = SCNPhysicsShape(geometry: shape, options: nil)
        
        let sphereBodys = SCNPhysicsBody(type: .kinematic, shape: physShape)
        sphere.physicsBody = sphereBodys
        
        sphere.physicsBody?.isAffectedByGravity = false
        sphere.physicsBody?.categoryBitMask = CollisionTypes.tail.rawValue
        sphere.physicsBody?.collisionBitMask = 0
      //  sphere.physicsBody?.contactTestBitMask = 5 | 25
        sphere.position = SCNVector3(x: 0, y: 0, z: 0)
        wrapper.addChildNode(sphere)
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
        addTails(amount: 1)
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
    let snakeSpeed: Float = 1200
    let ballRadius: Float = 1
    @objc func followFunc() {
        guard snakeTail.count > 0 else {return}
        
        for i in 1..<snakeTail.count {
          
            let moveObject = SCNAction.move(to: snakeTail[i-1].position, duration: trailTime)
            snakeTail[i].runAction(moveObject)
        }
        //let _position = snakeHead.position
       let globalPositionOfSnakeHead = snakeHinge.convertPosition(snakeHead.position, to: wrapper)
       // let moveObject = SCNAction.move(to: snakeHead.position, duration: trailTime + 0.01)
        let moveObject = SCNAction.move(to: SCNVector3(x: globalPositionOfSnakeHead.x , y: globalPositionOfSnakeHead.y , z: globalPositionOfSnakeHead.z ), duration: trailTime + 0.01)
        snakeTail[0].runAction(moveObject)
   
    }
    
    enum Facing {
        case up,down,left,right
    }
    var direction: Facing? = .up
    var duration: Double = 5
    @objc private func goUp(_ swipe: UISwipeGestureRecognizer?) {
        print("swipeup")
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.move(by: SCNVector3(0,4,0), duration: duration)
        snakeHinge.runAction(moveObject)
        if direction == .down {
            snakeHinge.removeAllActions()
        }
        direction = .up
    }
    @objc private func goDown(_ swipe: UISwipeGestureRecognizer?) {
        print("swipedown")
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.move(by: SCNVector3(0,-4,-0), duration: duration)
        snakeHinge.runAction(moveObject)
        if direction == .up {
            snakeHinge.removeAllActions()
        }
        direction = .down
        
    }
    @objc private func goRight(_ swipe: UISwipeGestureRecognizer?) {
        print("swiperight")
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.rotateBy(x: 0, y: -CGFloat.pi*2, z: 0, duration: duration*3.14*1.5)
        snakeHinge.runAction(moveObject)
        if direction == .left {
            snakeHinge.removeAllActions()
        }
        direction = .right
        
    }
    @objc private func goLeft(_ swipe: UISwipeGestureRecognizer?) {
        print("swipeleft")
        snakeHinge.removeAllActions()
        let moveObject = SCNAction.rotateBy(x: 0, y: CGFloat.pi*2, z: 0, duration: duration*3.14*1.5)
        snakeHinge.runAction(moveObject)
        if direction == .right {
            snakeHinge.removeAllActions()
        }
        direction = .left
        
    }
    
//    private func delayAdd() {
//        let myDouble = Double(arc4random_uniform(5)) + 1.0
//        Global.delay(bySeconds: myDouble) {
//            let random = Int(arc4random_uniform(2))
//            if random == 0 {
//                self.addFood(value: Int(arc4random_uniform(UInt32(self.topFoodAmount))) + 1)
//            } else {
//                self.addFood(value: Int(arc4random_uniform(2)) + 1)
//            }
//        }
//    }
    
    
    private func addTails(amount: Int) {
        
        for i in 0..<amount {
            
            addSphere()
        }
        
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
                let distanceY = snakeHead.position.y - node.position.y
                let moveObject = SCNAction.move(by: SCNVector3(0,distanceY,0), duration: TimeInterval(abs(distanceY)/3))
                node.runAction(moveObject)
                let distanceAngle = snakeHinge.rotation.w - node.rotation.w
                let rotateObject = SCNAction.rotate(toAxisAngle: SCNVector4(x:0,y:1,z:0,w:snakeHinge.rotation.w), duration: TimeInterval(abs(distanceAngle/3)))
                node.runAction(rotateObject)
            case .eagle:
           
                let rotateObject = SCNAction.rotate(by: 1*sign, around: SCNVector3(0,1,0), duration: 5.0)
                node.runAction(rotateObject)
                
                if node.position.y > -2.8 && node.position.y < 2.8 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1*sign2),0), duration: 5.0)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.7 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.1),0), duration: 5.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1),0), duration: 5.0)
                    node.runAction(moveObject)
                }
              
            case .butterfly:
                
                let rotateObject = SCNAction.rotate(by: 1*sign, around: SCNVector3(0,1,0), duration: 5.0)
                node.runAction(rotateObject)
                
                if node.position.y > -2.8 && node.position.y < 2.8 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1*sign2),0), duration: 5.0)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.7 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.1),0), duration: 10.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.1),0), duration: 10.0)
                    node.runAction(moveObject)
                }
                
            case .tiger:
                let distanceY = snakeHead.position.y - node.position.y
                let moveObject = SCNAction.move(by: SCNVector3(0,distanceY,0), duration: TimeInterval(abs(distanceY)/25))
                node.runAction(moveObject)
                let distanceAngle = snakeHinge.rotation.w - node.rotation.w
                let rotateObject = SCNAction.rotate(toAxisAngle: SCNVector4(x:0,y:1,z:0,w:snakeHinge.rotation.w), duration: TimeInterval(abs(distanceAngle/25)))
                node.runAction(rotateObject)
                node.runAction(moveObject)
            case .mouse:
                break
                //start mouse at the beginning to just move around circle quickly
                
            case .deer:
                let rotateObject = SCNAction.rotate(by: 0.05*sign, around: SCNVector3(0,1,0), duration: 5.0)
                node.runAction(rotateObject)
                
                if node.position.y > -2.5 && node.position.y < 2.5 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.3*sign2),0), duration: 5.0)
                    node.runAction(moveObject)
                    
                } else if node.position.y > 2.4 {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(-0.3),0), duration: 10.0)
                    node.runAction(moveObject)
                } else {
                    let moveObject = SCNAction.move(by: SCNVector3(0,Float(0.3),0), duration: 10.0)
                    node.runAction(moveObject)
                }
            }
        }
    }
    
    
    
    func chooseRandomEnterance() -> (y:Float,rotation:Float) {
        let random = arc4random_uniform(8)
        var y = Float()
        var rotation = Float()
        switch random {
        case 0:
            rotation = Float.pi
            y = 1
        case 1:
            rotation = Float.pi*3/2
            y = 2
        case 2:
            rotation = Float.pi/2
            y = 2.5
        case 3:
            rotation = Float.pi
            y = 1
        case 4:
            rotation = Float.pi*5/2
            y = -1
        case 5:
            rotation = Float.pi/4
            y = -2.5
        case 6:
            rotation = Float.pi*8
            y = -0.5
        default:
            rotation = Float.pi*1.8
            y = 0
            
        }
        return (y,rotation)
    }
    
    var monsters = [(SCNNode,Monster)]()
    func addMonster(type: Monster) {
        let (enteranceLocationY,enteranceLocationTheta) = chooseRandomEnterance()
        switch type {
        case .zombie:
            let zombie = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((zombie,.zombie))
            wrapper.addChildNode(zombie)
        case .eagle:
            let eagle = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((eagle,.eagle))
            wrapper.addChildNode(eagle)
        case .butterfly:
            let butterfly = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((butterfly,.butterfly))
            wrapper.addChildNode(butterfly)
        case .tiger:
            let tiger = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((tiger,.tiger))
            wrapper.addChildNode(tiger)
        case .mouse:
            let mouse = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((mouse,.mouse))
            wrapper.addChildNode(mouse)
            
        case .deer:
            let deer = Enemy(height: enteranceLocationY, rotation: enteranceLocationTheta)
            monsters.append((deer,.deer))
            wrapper.addChildNode(deer)
        }
    }
    
    private func resetGame() {
        
        timer1.invalidate()
        timer2.invalidate()
        timer3.invalidate()
        
        snakeTail.removeAll()
        monsters.removeAll()
      //  foodArray.removeAll()
  
    }
    
    func restartGame() {
        
        myScheme = ColorScheme(rawValue: UserDefaults.standard.integer(forKey: "colorScheme"))
        CustomColor.changeCustomColor(colorScheme: myScheme!)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/snake.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        wrapper = scene.rootNode.childNode(withName: "wrapper", recursively: false)!
        snakeHead = wrapper.childNode(withName: "headHinge", recursively: false)!.childNode(withName: "head", recursively: false)!
        snakeHinge = wrapper.childNode(withName: "headHinge", recursively: false)!
        
        timer1.fire();timer2.fire();timer3.fire()
        
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("didbegin")
        print("A: \(contact.nodeA.physicsBody!.categoryBitMask)")
        print("B: \(contact.nodeB.physicsBody!.categoryBitMask)")
        
        if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.head.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue {
            // monster gotchya
            print("ate monster!")
            if let item = contact.nodeB as? SCNNode {
                item.removeFromParentNode()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.wall.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.head.rawValue {
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
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.tail.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue {
            // monster gotchya
            print("monster attack!")
            gameOver()
            resetGame()
            
        } else if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.bullet.rawValue && contact.nodeB.physicsBody!.categoryBitMask == CollisionTypes.monster.rawValue {
            // monster gotchya
            print("shot monster!")
            if let item = contact.nodeB as? SCNNode {
                item.removeFromParentNode()
                loop: for i in 0..<monsters.count {
                    if item == monsters[i].0 {
                        
                        monsters.remove(at: i)
                        
                        break loop
                    }
                }
            }
        }
        
        //        else if contact.bodyA.categoryBitMask == 10 && contact.bodyB.categoryBitMask == 1 {
        //
        //            // head hit food
        //            print("EAT")
        //            if let item = contact.bodyA.node as? SKShapeNode {
        //                item.removeFromParent()
        //                loop: for i in 0..<foodArray.count {
        //                    if item == foodArray[i] {
        //                        let amount = Int(foodLabels[i].text!)!
        //                        delegateRefresh?.changeScore(amount: amount)
        //                        foodArray.remove(at: i)
        //                        foodLabels.remove(at: i)
        //                        addTails(amount: amount)
        //
        //                        delayAdd()
        //                        break loop
        //                    }
        //                }
        //            }
        //        }
    }
}
