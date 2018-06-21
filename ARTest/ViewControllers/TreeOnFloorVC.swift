//
//  TreeOnfloorVC.swift
//  ARTest
//
//  Created by Sergey Leskov on 6/18/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//

import UIKit
import ARKit

class TreeOnFloorVC: UIViewController {
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpSceneView()
        
        self.addTapGestureToSceneView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        //Lighting
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.addNodeToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func addNodeToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        let name:String = "art.scnassets/Tree/Tree.scn" //you can add node whatever
        
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .background).async {
            guard let tempScene = SCNScene(named: name) else {
                print("Error tempScene")
                return
            }
            
            guard let geometry:SCNGeometry = tempScene.rootNode.childNodes.first?.geometry else {
                print("Error geometry")
                return
            }
            
            
            let boxNode:SCNNode = SCNNode(geometry: geometry)
            boxNode.position = SCNVector3(x,y,z)
            self.sceneView.scene.rootNode.addChildNode(boxNode)
            group.leave()
            
        }
        group.notify(queue: .main){
            //Here you know that the node is has been put
        }
    }

}



extension TreeOnFloorVC: ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.blue
        
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
