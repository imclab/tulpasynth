//
//  WildBallModel.h
//  tulpasynth
//
//  Created by Colin Sullivan on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhysicsEntityModel.h"

@interface WildBallModel : PhysicsEntityModel

@property (strong, nonatomic) NSDictionary* initialLinearVelocity;

- (void) initialize;
- (NSMutableArray*) serializableAttributes;

@end
