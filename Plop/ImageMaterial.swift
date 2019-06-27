//
//  ImageMaterial.swift
//  Plop
//
//  Created by Daniel Bernal on 6/8/19.
//  Copyright © 2019 Plop Inc. All rights reserved.
//

import Foundation
import ARKit

class ImageMaterial: SCNMaterial {
    
    init(withImage image: String) {
        super.init()
        let image = UIImage(named: image)
        
        diffuse.contents = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
