//
//  TZTestViewController.m
//  SCNDemo
//
//  Created by tanzou on 2017/9/29.
//  Copyright © 2017年 tanzou. All rights reserved.
//

#import "TZTestViewController.h"

@interface TZTestViewController ()

@end

@implementation TZTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    SCNScene *scene = [SCNScene scene];
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
//    SCNBox *box = [SCNBox boxWithWidth:5. height:5 length:5 chamferRadius:0];
//    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
//    SCNMaterial *material = [SCNMaterial material];
//    material.emission.contents = [UIColor blueColor];
//    boxNode.geometry.firstMaterial = material;
    
    SCNSphere *sun = [SCNSphere sphereWithRadius:10];
    SCNNode *sunNode = [SCNNode nodeWithGeometry:sun];
    sunNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"sun"];
    [scene.rootNode addChildNode:sunNode];
    [sunNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:2]]];
    
    SCNSphere *earth = [SCNSphere sphereWithRadius:5];
    SCNNode *earthNode = [SCNNode nodeWithGeometry:earth];
    earthNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"land_ocean"];
    [sunNode addChildNode:earthNode];
    earthNode.position = SCNVector3Make(50, 0, 0);
    [earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:0.5]]];
    
    
    SCNSphere *moon = [SCNSphere sphereWithRadius:2];
    SCNNode *moonNode = [SCNNode nodeWithGeometry:moon];
    moonNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"moon"];
    [earthNode addChildNode:moonNode];
    moonNode.position = SCNVector3Make(8, 0, 0);
    [moonNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    
    SCNNode *shipNode = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    shipNode.rotation = SCNVector4Make(0, 2, 0, M_PI);
    shipNode.position = SCNVector3Make(-50, -50, 0);
    [scene.rootNode addChildNode:shipNode];
    SCNAction *moveAction = [SCNAction repeatActionForever:[SCNAction moveTo:SCNVector3Make(0,0, 0) duration:10]];
    SCNAction *rotateAction = [SCNAction repeatActionForever:[SCNAction rotateByAngle:-2 aroundAxis:SCNVector3Make(0, 0, 0) duration:10]];
    SCNAction *sequenceAction = [SCNAction sequence:@[moveAction,rotateAction]];
    [shipNode runAction:sequenceAction];
    
    SCNNode *shipMesh = [shipNode childNodeWithName:@"shipMesh" recursively:YES];
    
    SCNNode *emitter = [shipMesh childNodeWithName:@"emitter" recursively:YES];
    SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"reactor.scnp" inDirectory:@"art.scnassets/particles"];
    [emitter addParticleSystem:ps];
    
    
    SCNNode *cameraNode = [SCNNode node];
    SCNCamera *camera = [SCNCamera camera];
    cameraNode.camera = camera;
    [scene.rootNode addChildNode:cameraNode];
    cameraNode.position = SCNVector3Make(0, 0, 100);
    
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 0, 30);
    [scene.rootNode addChildNode:lightNode];
    
    lightNode.light.type = SCNLightTypeAmbient;
////    lightNode.position = SCNVector3Make(0, 20, 20);
////    lightNode.light.color = [UIColor redColor];
    [scene.rootNode addChildNode:lightNode];
    
    SCNView *scnView = (SCNView *)self.view;
    scnView.scene = scene;
    
    scnView.showsStatistics = YES;
    scnView.allowsCameraControl = YES;
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheBox:)];
    NSMutableArray *gestures = [NSMutableArray array];
    [gestures addObject:tapGes];
    [gestures addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestures;
}

- (void)tapTheBox:(UITapGestureRecognizer *)tapGes{
    SCNView *scnView = (SCNView *)self.view;
    
    CGPoint p = [tapGes locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    if (hitResults.count) {
        SCNHitTestResult *hitResult = hitResults[0];
        SCNMaterial *material = hitResult.node.geometry.firstMaterial;
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
