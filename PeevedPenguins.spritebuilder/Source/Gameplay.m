//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Selina Wang on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {

CCPhysicsNode *_physicsNode;
CCNode *_levelNode;
CCNode *_catapultArm;
CCNode *_contentNode;
CCNode *_pullbackNode;
CCNode *_mouseJointNode;
CCPhysicsJoint *_mouseJoint;
}

-(void)didLoadFromCCB {
    self.userInteractionEnabled = true;
    CCScene *level = [CCBReader loadAsScene: @"Levels/Level1"];
    [_levelNode addChild:level];
    _physicsNode.debugDraw = true;
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody  bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void)releaseCatapult {
    if (_mouseJoint != nil)
    {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [self releaseCatapult];
}


-(void)launchPenguin {
    CCNode* penguin = [CCBReader load:@"Penguin"];
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    [_physicsNode addChild:penguin];
    
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    self.position = ccp(0,0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}


-(void)retry {
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}
@end
