//
//  GridMaterial.swift
//  Plop
//
//  Created by Daniel Bernal on 6/8/19.
//  Copyright © 2019 Plop Inc. All rights reserved.
//

import Foundation
import ARKit

class GridMaterial: SCNMaterial {
    
    override init() {
        super.init()
        let image = UIImage(named: "Grid")
        
        diffuse.contents = image
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        let mmPerMeter: Float = 1000
        let mmOfImage: Float = 65
        let repeatAmount: Float = mmPerMeter / mmOfImage
        diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
    }
    
}
