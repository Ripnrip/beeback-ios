/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate, Storyboarded {
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// The tab bar the controls the transition
    lazy var tabBarViewController: PTTabBarViewController = {
        return childViewControllers.lazy.compactMap({ $0 as? PTTabBarViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    //Box node
    var box: SCNNode? = nil
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        self.sceneView.addSubview(childViewControllers[0].view)
        
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed to avoid interuppting the AR experience.
		UIApplication.shared.isIdleTimerDisabled = true

        // Start the AR experience
        resetTracking()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

        session.pause()
	}

    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true

    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
	func resetTracking() {
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        
        statusViewController.scheduleMessage("Look around to discover nearby items", inSeconds: 5.5, messageType: .contentPlacement)
        if box == nil {
            delayWithSeconds(7) { [weak self] in
                self?.addNode()
            }
        }
        
	}

    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    /// - Tag: ARImageAnchor-Visualizing
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            
            /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
            planeNode.eulerAngles.x = -.pi / 2
            
            /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            
            //add item to plane
            //animate item
            // Create a new scene
            let scene = SCNScene(named: "art.scnassets/ship.scn")!
            //scene.rootNode.position = planeNode.position
            // Set the scene to the view
            self.sceneView.scene.rootNode.addChildNode(scene.rootNode)
            
            //let grow = SCNAction.scale(to: 1 * 2 + 1, duration: 1)
            //scene.rootNode.runAction(grow)
            
            //scene.rootNode.scale = SCNVector3(-3,1,1)
            let tempScale: CGFloat = 1.0
            scene.rootNode.scale = SCNVector3(tempScale, tempScale, tempScale)
            // grow from 1 to tempScale, then back to 1
            let grow = SCNAction.scale(to: tempScale, duration: 4.1)
            let shrink = SCNAction.scale(to: 0.1, duration: 2.1)
            let sequence = SCNAction.sequence([shrink, grow])
            //scene.rootNode.runAction(SCNAction.repeatForever(sequence))
            scene.rootNode.runAction(sequence)
            //let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1 , 0), duration: 0.5))
            //scene.rootNode.runAction(SCNAction.repeatForever(action))
            
            //scene.rootNode.runAction(SCNAction.repeatForever(grow))
            //planeNode.addChildNode(scene.rootNode)
        }
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    func addNode() {
        //// General Declarations
         UIGraphicsBeginImageContextWithOptions(self.sceneView.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        
        
        //// Image Declarations
        let beeBackAR = UIImage(named: "BeeBackAR.png")!
        
        //// Picture Drawing
        let picturePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        context.saveGState()
        picturePath.addClip()
        context.translateBy(x: 0, y: 0)
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -beeBackAR.size.height)
        context.draw(beeBackAR.cgImage!, in: CGRect(x: 0, y: 0, width: beeBackAR.size.width, height: beeBackAR.size.height))
        context.restoreGState()
        
        let scnShape = SCNShape(path: picturePath, extrusionDepth: 0.2)
        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.1/2))
        //node.geometry = scnShape
        node.position = SCNVector3(0,0,-0.5)
        
        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "BeeBackAR.png")!
        //node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        //animate node
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
        node.runAction(action)
        
        box = node
        self.sceneView.tag = 0
        self.sceneView.scene.rootNode.addChildNode(box!)
        
    }

    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
        ])
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            if sceneViewTappedOn.tag == 1 {
                //show youtube ad
                UIApplication.shared.openURL(URL(string: "https://www.youtube.com/watch?v=k6UF2uZprYQ")!)
                return
            }
            let results = hitTest.first!
            let geometry = results.node.geometry
            print(geometry)
            let distanceFromBox = distance(from: results.node.position)
            print("the distance from the box is \(distanceFromBox)")
            
            if distanceFromBox < 2 {
                let alert = UIAlertController(title: "Alert", message: "Tapped the mystery box", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Alert", message: "You are too far from the mystery box", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        }
    }
    
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = (sceneView.pointOfView?.position.x)! - vector.x
        let distanceY = (sceneView.pointOfView?.position.y)! - vector.y
        let distanceZ = (sceneView.pointOfView?.position.z)! - vector.z
        return sqrtf((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
}
