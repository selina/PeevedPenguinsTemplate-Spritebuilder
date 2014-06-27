//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Selina Wang on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {

CCPhysicsNode *_PhysicsNode;
CCNode *_catapultArm;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = true;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [self launchPenguin];
}

-(void)launchPenguin {
    CCNode* penguin = [CCBReader load:@"Penguin"];
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    [_physicsNode addChild:penguin];
    
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
}
@end
