/**
 *  @file       Obstacle.h
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#import "PhysicsEntity.h"

#include "b2Math.h"

#include "TouchEntity.h"
#include "PinchEntity.h"
#include "RotateEntity.h"
#include "TapEntity.h"

#import "ObstacleModel.h"

@class tulpaViewController;

/**
 *  @class Abstraction around touch handlers for an obstacle that the falling
 *  balls can collide with.
 **/
@interface Obstacle : PhysicsEntity

- (void) initialize;

- (GLboolean) handlePinch:(PinchEntity *) pinch;
/**
 *  The pinch gesture recognizer if this object is currently being pinched
 **/
@property PinchEntity * pincher;
/**
 *  Width and height properties for use when scaling (pinching)
 **/ 
@property GLfloat preScalingWidth, preScalingHeight;

/**
 *  Called from parent view from rotate gesture callback.
 **/
- (GLboolean) handleRotate:(RotateEntity *) rotate;

/**
 *  The entity that is currently rotating this object.
 **/
@property RotateEntity * rotator;
/**
 *  Rotation value before gesture began
 **/
@property float32 preGestureAngle;


- (GLboolean) handleTap:(TapEntity *) tap;

@end
