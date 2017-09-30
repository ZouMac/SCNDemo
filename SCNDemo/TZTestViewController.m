//
//  TZTestViewController.m
//  SCNDemo
//
//  Created by tanzou on 2017/9/29.
//  Copyright © 2017年 tanzou. All rights reserved.
//

#import "TZTestViewController.h"

typedef enum : NSUInteger {
    CollisionDetectionMaskShip = 1,
    CollisionDetectionMaskSun = 2,
    CollisionDetectionMaskMoon = 3,
    CollisionDetectionMaskEarth = 4,
} CollisionDetectionMask;

@interface TZTestViewController ()<SCNPhysicsContactDelegate>

@property (nonatomic, strong) SCNScene *scene;

@property (nonatomic, strong) SCNNode *shipNode;

@property (nonatomic, strong) SCNNode *sunNode;

@property (nonatomic, strong) SCNNode *moonNode;

@property (nonatomic, strong) SCNNode *earthNode;

@property (nonatomic, strong) SCNView *scnView;

@end

@implementation TZTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    SCNScene *scene = [SCNScene scene];
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    self.scene = scene;
    
//    SCNBox *box = [SCNBox boxWithWidth:5. height:5 length:5 chamferRadius:0];
//    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
//    SCNMaterial *material = [SCNMaterial material];
//    material.emission.contents = [UIColor blueColor];
//    boxNode.geometry.firstMaterial = material;
    
    [self createSunModel];
    [self createEarthModel];
    [self createMoonModel];
    [self createShipModel];
    
    [self createOtherCollision];
    [self createBtn];
    [self createLight];
    [self createCamera];
   
    
    SCNView *scnView = (SCNView *)self.view;
    scnView.scene = scene;
    _scnView = scnView;
    
     [self createGesture];
    
    scnView.showsStatistics = YES;
    scnView.allowsCameraControl = YES;
    
    
}

-(void)createOtherCollision{
    
    //    设置碰撞物体实体形状
    _sunNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:[SCNSphere sphereWithRadius:20] options:nil]];
    _earthNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithNode:_earthNode options:nil]];
    _moonNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithNode:_moonNode options:nil]];
    
    //    设置碰撞事件
    _sunNode.physicsBody.collisionBitMask = CollisionDetectionMaskShip;
    _sunNode.physicsBody.contactTestBitMask = CollisionDetectionMaskShip;
    
    _earthNode.physicsBody.collisionBitMask = CollisionDetectionMaskShip;
    _earthNode.physicsBody.contactTestBitMask = CollisionDetectionMaskShip;
    
    _moonNode.physicsBody.collisionBitMask = CollisionDetectionMaskShip;
    _moonNode.physicsBody.contactTestBitMask = CollisionDetectionMaskShip;
    //    设置碰撞代理
    _scene.physicsWorld.contactDelegate = self;
}

- (void)createGesture{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheBox:)];
    NSMutableArray *gestures = [NSMutableArray array];
    [gestures addObject:tapGes];
    [gestures addObjectsFromArray:_scnView.gestureRecognizers];
    _scnView.gestureRecognizers = gestures;
}

-(void)createBtn{
    UIButton *restartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    restartBtn.frame = CGRectMake(30, 30, 80, 40);
    [self.view addSubview:restartBtn];
    [restartBtn setTitle:@"fly" forState:UIControlStateNormal];
    [restartBtn addTarget:self action:@selector(fly) forControlEvents:UIControlEventTouchUpInside];
    //    [restartBtn setBackgroundColor:[UIColor grayColor]];
    [restartBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    restartBtn.titleLabel.font = [UIFont systemFontOfSize:20];
}

-(void)createCamera{
    SCNNode *cameraNode = [SCNNode node];
    SCNCamera *camera = [SCNCamera camera];
    cameraNode.camera = camera;
    [_scene.rootNode addChildNode:cameraNode];
    cameraNode.position = SCNVector3Make(0, 5, 100);
}

- (void)createLight{
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    //    lightNode.light.type = SCNLightTypeOmni;
    //    lightNode.light.zFar = 100;
    //    [sunNode addChildNode:lightNode];
    
    lightNode.light.type = SCNLightTypeAmbient;
    ////    lightNode.position = SCNVector3Make(0, 20, 20);
    ////    lightNode.light.color = [UIColor redColor];
    [_scene.rootNode addChildNode:lightNode];
}

- (void)createSunModel{
    SCNSphere *sun = [SCNSphere sphereWithRadius:20];
    SCNNode *sunNode = [SCNNode nodeWithGeometry:sun];
    _sunNode = sunNode;
    sunNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"sun"];
    [_scene.rootNode addChildNode:sunNode];
    [sunNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:2]]];
    sunNode.physicsBody.collisionBitMask = CollisionDetectionMaskSun;
}

- (void)createEarthModel{
    SCNSphere *earth = [SCNSphere sphereWithRadius:5];
    SCNNode *earthNode = [SCNNode nodeWithGeometry:earth];
    _earthNode = earthNode;
    earthNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"land_ocean"];
    [_sunNode addChildNode:earthNode];
    earthNode.position = SCNVector3Make(50, 0, 0);
    [earthNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:0.5]]];
    earthNode.physicsBody.collisionBitMask = CollisionDetectionMaskEarth;
}

- (void)createMoonModel{
    SCNSphere *moon = [SCNSphere sphereWithRadius:2];
    SCNNode *moonNode = [SCNNode nodeWithGeometry:moon];
    _moonNode = moonNode;
    moonNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"moon"];
    [_earthNode addChildNode:moonNode];
    moonNode.position = SCNVector3Make(8, 0, 0);
    [moonNode runAction:[SCNAction repeatActionForever:[SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    _earthNode.physicsBody.collisionBitMask = CollisionDetectionMaskMoon;
}

- (void)createShipModel{
    SCNNode *shipNode = [_scene.rootNode childNodeWithName:@"ship" recursively:YES];
//    self.shipNode = shipNode;
    shipNode.rotation = SCNVector4Make(0, 2, 0, M_PI);
    shipNode.position = SCNVector3Make(-50, -50, 50);
    [_scene.rootNode addChildNode:shipNode];
    SCNAction *moveAction = [SCNAction repeatActionForever:[SCNAction moveTo:SCNVector3Make(0,0, 18) duration:10]];
    moveAction.timingMode = SCNActionTimingModeEaseOut;   //越来越慢
    SCNAction *rotateAction = [SCNAction repeatActionForever:[SCNAction rotateByAngle:-2 aroundAxis:SCNVector3Make(-5, 5, 0) duration:10]];
    SCNAction *sequenceAction = [SCNAction sequence:@[moveAction,rotateAction]];
    [shipNode runAction:sequenceAction];
    shipNode.physicsBody.collisionBitMask = CollisionDetectionMaskShip;
    
    [self addParticleSystem:shipNode];
    [self setShipNodeCollision:shipNode];
}

- (void)fly{
   
    SCNNode *shipNode = [_scene.rootNode childNodeWithName:@"ship" recursively:YES];

    SCNAction *moveAction = [SCNAction repeatActionForever:[SCNAction moveTo:SCNVector3Make(0,0, 18) duration:10]];
    moveAction.timingMode = SCNActionTimingModeEaseOut;   //越来越慢
    SCNAction *rotateAction = [SCNAction repeatActionForever:[SCNAction rotateByAngle:-2 aroundAxis:SCNVector3Make(-5, 5, 0) duration:10]];
    SCNAction *sequenceAction = [SCNAction sequence:@[moveAction,rotateAction]];
    [shipNode runAction:sequenceAction];

}

- (void)addParticleSystem:(SCNNode *)shipNode{
    SCNNode *shipMesh = [shipNode childNodeWithName:@"shipMesh" recursively:YES];
    SCNNode *emitter = [shipMesh childNodeWithName:@"emitter" recursively:YES];
    SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"reactor.scnp" inDirectory:@"art.scnassets/particles"];
    [emitter addParticleSystem:ps];
}

- (void)setShipNodeCollision:(SCNNode *)shipNode{
    
    shipNode.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithNode:shipNode options:nil]];
    shipNode.physicsBody.collisionBitMask = CollisionDetectionMaskMoon | CollisionDetectionMaskEarth | CollisionDetectionMaskSun;
    shipNode.physicsBody.contactTestBitMask = CollisionDetectionMaskMoon | CollisionDetectionMaskEarth | CollisionDetectionMaskSun;
}

#pragma mark - SCNPhysicsContactDelegate
-(void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
    SCNNode *nodeA = contact.nodeA;
    SCNNode *nodeB = contact.nodeB;
    SCNNode *shipNode = [SCNNode node];
    
    //        SCNVector3 contactPoint  = contact.contactPoint;
    
    if (nodeA.physicsBody.categoryBitMask == CollisionDetectionMaskShip) {
        shipNode = nodeA;
    }else{
        shipNode = nodeB;
    }
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:3];
    
    
    // on completion
    [SCNTransaction setCompletionBlock:^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];

        [shipNode removeFromParentNode];
//        shipNode.hidden = YES;
        SCNAction *moveAction = [SCNAction repeatActionForever:[SCNAction moveTo:SCNVector3Make(-50, -50, 50) duration:0.01]];
        SCNAction *actions = [SCNAction sequence:@[moveAction]];
//        [shipNode runAction:actions completionHandler:^{
//            shipNode.hidden = NO;
////            SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"reactor.scnp" inDirectory:@"art.scnassets/particles"];
//            [shipNode removeAllParticleSystems];
//        }];
        

        [SCNTransaction commit];
    }];
    SCNParticleSystem *ps = [SCNParticleSystem particleSystemNamed:@"reactor.scnp" inDirectory:@"art.scnassets/particles"];
    [shipNode addParticleSystem:ps];
    
    [SCNTransaction commit];
}

-(void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact{
   
    
}

-(void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact{
    
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
