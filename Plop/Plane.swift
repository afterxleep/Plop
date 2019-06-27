//
//  Plane.swift
//  Plop
//
//  Created by Daniel Bernal on 6/8/19.
//  Copyright © 2019 Plop Inc. All rights reserved.
//

import ARKit

class Plane: SCNNode {
    
    let plane: SCNPlane
    
    init(anchor: ARPlaneAnchor) {
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        super.init()        
        plane.cornerRadius = 0.008
        plane.materials = [GridMaterial()]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2 // For vertical planes
        planeNode.opacity = 1.0
        //planeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //planeNode.physicsBody?.mass = 2.0
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        if let grid = plane.materials.first as? GridMaterial {
            grid.updateWith(anchor: anchor)
        }
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
    func hide() {
        let material = plane.materials.first
        material?.colorBufferWriteMask = []
        
    }
    
}
