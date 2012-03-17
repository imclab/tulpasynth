//
//  WildBallModel.m
//  tulpasynth
//
//  Created by Colin Sullivan on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WildBallModel.h"

@implementation WildBallModel

@synthesize initialLinearVelocity;

- (void) initialize {
    self.nosync = true;
    [super initialize];
}

- (NSMutableArray*) serializableAttributes {
    NSMutableArray* attributes = [super serializableAttributes];
    
//    [attributes removeObject:@"id"];
    
    [attributes addObject:@"initialLinearVelocity"];
    
    return attributes;
}

+ (NSMutableDictionary*) defaultAttributes {
    NSMutableDictionary* defaults = [super defaultAttributes];
    
    [defaults setValue:[NSNumber numberWithFloat:1.5] forKey:@"height"];
    [defaults setValue:[NSNumber numberWithFloat:1.5] forKey:@"width"];
    [defaults setValue:[NSNumber numberWithFloat:stk::PI/4.0] forKey:@"angle"];
    
    return defaults;
}

@end
