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
    var spriteScene = GameScene(size: CGSize(width: 375, height: 667)) //skScene
    var score = UILabel()
    var scoreInt = Int() {didSet{score.text = String(scoreInt); Global.points = scoreInt}}
    let view3 = SKView()
    let instructionLabel = UILabel()
    var timer = Timer()
    var tap = UITapGestureRecognizer()
    var myScheme: ColorScheme?
    var wrapper = SCNNode()

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
    }
    
    private func startScene() {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func changeScore(amount: Int) {
        
        scoreInt += amount
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sceneView.addGestureRecognizer(spriteScene.swipeUp)
        sceneView.addGestureRecognizer(spriteScene.swipeDown)
        sceneView.addGestureRecognizer(spriteScene.swipeRight)
        sceneView.addGestureRecognizer(spriteScene.swipeLeft)
        myView.addGestureRecognizer(spriteScene.tap)
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
            //        myGameOverView.replay.addTarget(self, action: #selector(GameViewController.replayFunc(_:)), for: .touchUpInside)
            //        myGameOverView.menu.addTarget(self, action: #selector(GameViewController.menuFunc(_:)), for: .touchUpInside)
            //        myGameOverView.gameCenter.addTarget(self, action: #selector(GameViewController.gameCenterFunc(_:)), for: .touchUpInside)
            //       myGameOverView.extraLife.addTarget(self, action: #selector(GameViewController.extraLifeFunc(_:)), for: .touchUpInside)
            //   spriteScene.touchOnce = false
            view.addSubview(myGameOverView)
            Global.delay(bySeconds: 5.0) {
                self.once = true
            }
            
            
            
        }
    }
    
    var activityView = UIActivityIndicatorView()
    private func purchase(productId: String = "arSnake.IAP.idk") {
        
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
}
