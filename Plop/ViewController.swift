//
//  ViewController.swift
//  Plop
//
//  Created by Daniel Bernal on 6/6/19.
//  Copyright © 2019 Plop Inc. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    private var planes = [UUID: Plane]()
    private var lightNode: SCNNode!
    private var posterScene: SCNScene!
    private var weaponScene: SCNScene!
    private var weapon: SCNNode!
    private var poster: SCNNode!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSceneView()
        initScene()
        initARSession()
        loadModels()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func tappedShoot(_ sender: Any) {
        shoot()
    }
    
    // MARK: - Initialization
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [
              //ARSCNDebugOptions.showFeaturePoints,
              //ARSCNDebugOptions.showWorldOrigin,
              //SCNDebugOptions.showBoundingBoxes,
              //SCNDebugOptions.showWireframe
        ]
        sceneView.autoenablesDefaultLighting = true
    }
    
    func initScene() {
        let scene = SCNScene()
        scene.isPaused = false
        sceneView.scene = scene
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: World Tracking Not Supported")
            return
        }
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = [ .vertical]
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        sceneView.session.run(config)
    }
    
    func resetARSession() {
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    @objc func didTapScene(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let location = gesture.location(ofTouch: 0, in: sceneView)
            let hit = sceneView.hitTest(location, types: .existingPlaneUsingGeometry)
            if let hit = hit.first {
                placePosterOnPlane(hit)
            }
        default:
            break
        }
    }
    
    func loadModels() {
        posterScene = SCNScene(named: "Plop.scnassets/Poster.scn")!
        poster = posterScene.rootNode.childNode(withName: "poster", recursively: false)!        
    }
    
    func placePosterOnPlane(_ hit: ARHitTestResult) {
        position(node: poster, atHit: hit)
        sceneView?.scene.rootNode.addChildNode(poster)
        suspendARPlaneDetection()
        hideARPlanes()
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        // Trasnform the node to match the hit target
        node.transform = SCNMatrix4(hit.anchor!.transform)
        
        // Move it to the touch target position
        // FIgure out WTF why are we using column 3 and whats the other shit
        let position = SCNVector3Make(
            hit.worldTransform.columns.3.x,
            hit.worldTransform.columns.3.y,
            hit.worldTransform.columns.3.z
        );        
        
        // Rotate it to match to vertical plane
        // Figure the fuck out values for SCNVector as in design it works with degrees
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x - (Float.pi/2), node.eulerAngles.y, node.eulerAngles.z)
        node.position = position
    }
    
    func shoot() {
        let camera = sceneView.session.currentFrame!.camera
        let weapon = Weapon()
        
        // Move to where camera is
        var translation = matrix_float4x4(weapon.transform)
        translation.columns.3.z = -0.1  // Put weapon behind screen
        translation.columns.3.x = 0.03 // Launch point to screen center
        
        weapon.simdTransform = matrix_multiply(camera.transform, translation)
        
        // Apply force & Impulse
        let force = simd_make_float4(-3, 0, -5, 0) //
        let rotatedForce = simd_mul(camera.transform, force)
        let impulse = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        sceneView?.scene.rootNode.addChildNode(weapon)
        weapon.shoot(inDirection: impulse)
    }
    
    
    // Stops Detecting Planes
    func suspendARPlaneDetection() {
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        config.planeDetection = []
        sceneView.session.run(config)
    }
    
    // Remove Material from all planes
    func hideARPlanes() {
        for plane in planes {
            plane.value.hide()            
        }
    }
    
    
}

extension ViewController : ARSCNViewDelegate {
    
    // MARK: - SceneRendering
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = Plane(anchor: planeAnchor)
        planes[anchor.identifier] = plane
        print(planes.count)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
  
}
