/**
 *  @file       GLView.h
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#import <GLKit/GLKit.h>

#import "View.h"

#include "b2Body.h"
#include "PanEntity.h"


#include "Globals.h"


/**
 *  @class  View class that takes care of generalized open gl drawing stuff.
 **/
@interface GLView : View

/**
 *  All GLView instances will use the same vertexBuffer and indexBuffer.
 **/
+ (GLuint)vertexBuffer;
+ (GLuint)indexBuffer;

+ (void) initializeBuffers;


@property (strong, nonatomic) GLKBaseEffect* effect;


/**
 *  Width and height of this object (in world coordinates)
 **/
@property float width;
@property float height;

/**
 *  Rotation of this object (in radians)
 **/
@property (nonatomic) float32 angle;

/**
 *  Position of the center of this object (in world coordinates)
 **/
@property (nonatomic) b2Vec2* position;


/**
 *  Wether or not this view will be drawn (TODO: this can invoke an animation
 *  when enabled/disabled).
 **/
@property (nonatomic) BOOL active;


/**
 *  Padding to add when scaling drawing.  Used to offset padding on texture
 *  images.
 **/
@property (nonatomic) float scalingMultiplier;

- (void) initialize;

- (void)prepareToDraw;
- (void)prepareToDraw1;
- (void)_bindAndEnable;
- (void)draw;
- (void)_disable;
- (void)postDraw;
- (void)postDraw1;

- (void)update;

/**
 *  Static list of all GLView instances
 **/
+ (NSMutableArray*) Instances;

/**
 *  Should be overridden in subclasses to create a transformation matrix used
 *  in `update`.
 **/
- (GLKMatrix4)currentModelViewTransform;

///**
// *  If there are new changes to the transform or other properties of the
// *  effect since last draw, we need to draw it again.
// **/
//@property (nonatomic) BOOL changesToDraw;

/**
 *  Handler for a pan (dragging) gesture.
 **/
- (GLboolean) handlePan:(PanEntity *) pan;
/**
 *  Handler for when a pan gesture involving this entity ended.
 **/
- (void) handlePanEnded;
/**
 *  Handler for when a pan gesture involving this entity has started.
 **/
- (void) handlePanStarted;
/**
 *  Handler for update when a pan gesture was active.
 **/
- (void) handlePanUpdate;
/**
 *  Pointer to pan gesture if it is currently happening on self
 **/
@property PanEntity * panner;

/**
 *  An optional secondary GLKBaseEffect for drawing two textures.
 **/
@property (strong, nonatomic) GLKBaseEffect* effect1;

/**
 *  Return pointer to instance of GLKBaseEffect to use for self.effect.
 **/
+ (GLKBaseEffect*)effectInstance;
+ (GLKBaseEffect*)effect1Instance;




@end
