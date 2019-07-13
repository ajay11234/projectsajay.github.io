//
//  ViewController.swift
//  Stereoscopic-ARKit-Template
//
//  Created by Hanley Weng on 1/7/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var sceneView2: ARSCNView!
    
    
    var shipNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       configureLighting()
        
     
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        let scene = SCNScene()
        sceneView.scene = scene
        
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView2.scene = scene
        sceneView2.showsStatistics = sceneView.showsStatistics
        
        sceneView2.isPlaying = true
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView2.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView2.automaticallyUpdatesLighting = true
    }
    
    @IBAction func tapgesture(_ sender: UITapGestureRecognizer) {

        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)

        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z

        let shipScene = SCNScene(named: "art.scnassets/clienthouse.scn")!
             shipNode = shipScene.rootNode.childNode(withName:"CLIENT", recursively: true)!



        shipNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(shipNode)
        sceneView2.scene.rootNode.addChildNode(shipNode)
    }
    
    
    @IBAction func pinchgesture(_ sender: UIPinchGestureRecognizer) {
        
        
        shipNode.runAction(SCNAction.scale(by: sender.scale, duration: 0.1))
        
        sender.scale = 1
        sceneView.scene.rootNode.addChildNode(shipNode)
        sceneView2.scene.rootNode.addChildNode(shipNode)
        
        
    }
    
    @IBAction func panscreeges(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        let xpan = sender.velocity(in: sceneView).x/10000
        
        shipNode.runAction(SCNAction.rotateBy(x: 0, y: xpan, z: 0, duration: 0.1))
        
        sceneView.scene.rootNode.addChildNode(shipNode)
        sceneView2.scene.rootNode.addChildNode(shipNode)
        
    }
    
    
    
//
//    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
//        let tapLocation = recognizer.location(in: sceneView)
//        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
//
//        guard let hitTestResult = hitTestResults.first else { return }
//        let translation = hitTestResult.worldTransform.translation
//        let x = translation.x
//        let y = translation.y
//        let z = translation.z
//
//        guard let shipScene = SCNScene(named: "housefur.scn"),
//            let shipNode = shipScene.rootNode.childNode(withName: "housefur", recursively: false)
//            else { return }
//
//
//        shipNode.position = SCNVector3(x,y,z)
//        sceneView.scene.rootNode.addChildNode(shipNode)
//    sceneView2.scene.rootNode.addChildNode(shipNode)
//    }
    
    
    
    
    
    
   
    // UPDATE EVERY FRAME:
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFrame()
        }
    }
    
    func updateFrame() {
        
        // Clone pointOfView for Second View
        let pointOfView : SCNNode = (sceneView.pointOfView?.clone())!
        
        // Determine Adjusted Position for Right Eye
        let orientation : SCNQuaternion = pointOfView.orientation
        let orientationQuaternion : GLKQuaternion = GLKQuaternionMake(orientation.x, orientation.y, orientation.z, orientation.w)
        let eyePos : GLKVector3 = GLKVector3Make(1.0, 0.0, 0.0)
        let rotatedEyePos : GLKVector3 = GLKQuaternionRotateVector3(orientationQuaternion, eyePos)
        let rotatedEyePosSCNV : SCNVector3 = SCNVector3Make(rotatedEyePos.x, rotatedEyePos.y, rotatedEyePos.z)
        
        let mag : Float = 0.066 // This is the value for the distance between two pupils (in metres). The Interpupilary Distance (IPD).
        pointOfView.position.x += rotatedEyePosSCNV.x * mag
        pointOfView.position.y += rotatedEyePosSCNV.y * mag
        pointOfView.position.z += rotatedEyePosSCNV.z * mag
        
        // Set PointOfView for SecondView
        sceneView2.pointOfView = pointOfView
        
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

//extension UIColor {
//    open class var transparentLightBlue: UIColor {
//        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
//    }
//}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
         2//
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)

        // 3
        plane.materials.first?.diffuse.contents = UIImage(named: "nexus")
        plane.materials.first?.blendMode = .multiply
        

        // 4
        let planeNode = SCNNode(geometry: plane)
        
      
        
        
        

        
        
        // 5
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        
        
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}
