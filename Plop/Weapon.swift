//
//  Weapon.swift
//  Plop
//
//  Created by Daniel Bernal on 6/8/19.
//  Copyright © 2019 Plop Inc. All rights reserved.
//

import Foundation
import ARKit

class Weapon: SCNNode {
    
    override init() {
        super.init()
        let weaponScene = SCNScene(named: "Plop.scnassets/Poo.scn")!
        let weapon = weaponScene.rootNode.childNode(withName: "poo", recursively: false)!
        geometry = weapon.geometry
        scale = SCNVector3(0.004, 0.004, 0.004)
        eulerAngles = SCNVector3(
                (CGFloat.pi * CGFloat.random(in: 0 ..< 1)),
                (CGFloat.pi * CGFloat.random(in: 0 ..< 1)),
                (CGFloat.pi * CGFloat.random(in: 0 ..< 1)))
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shoot(inDirection direction: SCNVector3) {
        physicsBody?.applyForce(direction, asImpulse: true)
    }
    
}
