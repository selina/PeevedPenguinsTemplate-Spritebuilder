//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Selina Wang on 6/27/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "Penguin.h"


@implementation Gameplay {

CCPhysicsNode *_physicsNode;
CCNode *_levelNode;
CCNode *_catapultArm;
CCNode *_contentNode;
CCNode *_pullbackNode;
CCNode *_mouseJointNode;
CCPhysicsJoint *_mouseJoint;
Penguin *_currentPenguin;
CCPhysicsJoint *_penguinCatapultJoint;
CCAction *_followPenguin;
}

static const float MIN_SPEED = 5.f;

-(void)didLoadFromCCB {
    self.userInteractionEnabled = true;
    CCScene *level = [CCBReader loadAsScene: @"Levels/Level1"];
    [_levelNode addChild:level];
    _physicsNode.debugDraw = true;
    _pullbackNode.physicsBody.collisionMask = @[];
    _mouseJointNode.physicsBody.collisionMask = @[];
    _physicsNode.collisionDelegate = self;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody  bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
        _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation = false;
        
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

- (void)update:(CCTime)delta
{
    if (_currentPenguin.launched) {
        if (ccpLength(_currentPenguin.physicsBody.velocity) < MIN_SPEED)
        {
            [self nextAttempt];
            return;
        }
    
    int xMin = _currentPenguin.boundingBox.origin.x;
    
    if (xMin < self.boundingBox.origin.x)
    {
        [self nextAttempt];
        return;
    }
    
    int xMax = xMin + _currentPenguin.boundingBox.size.width;
    if (xMax > (self.boundingBox.origin.x + self.boundingBox.size.width))
    {
        [self nextAttempt];
        return;
    }
    }
}

-(void)nextAttempt {
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
    
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
}

-(void)releaseCatapult {
    if (_mouseJoint != nil)
    {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        
        _currentPenguin.physicsBody.allowsRotation = true;
        
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
        
        _currentPenguin.launched = true;
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

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    float energy = [pair totalKineticEnergy];
    
    if (energy > 5000.f) {
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved:nodeA];
        } key:nodeA];
    }
}

-(void)sealRemoved:(CCNode *)seal {
    
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    explosion.autoRemoveOnFinish = true;
    explosion.position = seal.position;
    [seal.parent addChild:explosion];
    [seal removeFromParent];
}


@end
