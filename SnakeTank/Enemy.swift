//
//  Butterfly.swift
//  Snake Gladiator
//
//  Created by Aaron Halvorsen on 8/4/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import SceneKit
import GameplayKit

class Enemy: SCNNode, BrothersUIAutoLayout {
    

    var actualNode = SCNNode()
    var sphereMaterial = SCNMaterial()
    init(height: Float, rotation: Float) {
        super.init()
        
        let shape = SCNSphere(radius: Global.monsterRadius)
        
        sphereMaterial.fresnelExponent = 1.0
        sphereMaterial.shininess  = 1.0
        sphereMaterial.transparency = 1.0
        
        //            sphereMaterial.specular.contents = materialColor
        sphereMaterial.diffuse.contents = CustomColor.colors[CustomColor.current]
        //            sphereMaterial.reflective.contents = materialColor
        //            sphereMaterial.normal.contents = materialColor
        //            sphereMaterial.selfIllumination.contents = materialColor
        //            sphereMaterial.multiply.contents = materialColor
        //        sphereMaterial.locksAmbientWithDiffuse = true
        shape.materials = [sphereMaterial]
        
        
        
        let sphere = SCNNode(geometry: shape)
        sphere.position =  SCNVector3(x: 0, y: 0, z: -3)
        let physShape = SCNPhysicsShape(geometry: shape, options: nil)
        
        let sphereBodys = SCNPhysicsBody(type: .kinematic, shape: physShape)
        sphere.physicsBody = sphereBodys
        
        sphere.physicsBody?.isAffectedByGravity = false
        sphere.physicsBody?.categoryBitMask = CollisionTypes.monster.rawValue
        sphere.physicsBody?.collisionBitMask = 0
        sphere.physicsBody?.contactTestBitMask = CollisionTypes.tail.rawValue | CollisionTypes.head.rawValue | CollisionTypes.bullet.rawValue
        sphere.position = SCNVector3(x: 0, y: 0, z: -3)
        actualNode = sphere
        
        
        
        
        
        self.position = SCNVector3(x: 0, y: height, z: 0)
        self.rotation = SCNVector4(x:0,y:1,z:0,w:rotation)
        
        self.addChildNode(sphere)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

