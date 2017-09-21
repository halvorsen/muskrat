//
//  Bullet.swift
//  SnakeTank
//
//  Created by Jenn Halvorsen on 9/5/17.
//  Copyright © 2017 Right Brothers. All rights reserved.
//

import SceneKit
import GameplayKit

class Bullet: SCNNode, BrothersUIAutoLayout {
    
    var color: UIColor = .white
    
    init(height: Float, rotation: Float, rotate90: Bool) {
        super.init()
        //let shape = SCNSphere(radius: Global.monsterRadius*2)
        let shape = SCNCapsule(capRadius: Global.monsterRadius*3/2, height: Global.monsterRadius*5)
        let sphereMaterial = SCNMaterial()
         sphereMaterial.diffuse.contents = color
        
       // sphereMaterial.emission.contents = UIColor.white
        shape.materials = [sphereMaterial]
        let sphere = SCNNode(geometry: shape)
        sphere.position =  SCNVector3(x: 0, y: 0, z: -3)
        let physShape = SCNPhysicsShape(geometry: shape, options: nil)
        
        let sphereBodys = SCNPhysicsBody(type: .kinematic, shape: physShape)
        sphere.physicsBody = sphereBodys
        
        sphere.physicsBody?.isAffectedByGravity = false
        sphere.physicsBody?.categoryBitMask = CollisionTypes.bullet.rawValue
        sphere.physicsBody?.collisionBitMask = 0
        sphere.physicsBody?.contactTestBitMask = 0
      
        if rotate90 {
            sphere.rotation = SCNVector4(0,0,1,Float.pi/2)
        }
        
        self.position = SCNVector3(x: 0, y: height, z: 0)
        
        let innerNode = SCNNode()
        self.addChildNode(innerNode)
        innerNode.rotation = SCNVector4(x:0,y:1,z:0,w:rotation)
        innerNode.addChildNode(sphere)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
