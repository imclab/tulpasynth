/**
 *  @file       BlackholeModel.mm
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#import "BlackholeModel.h"

@implementation BlackholeModel

@synthesize eatenBallTimes, eatenBallPitchIndexes;

- (NSMutableArray*) serializableAttributes {
    NSMutableArray* attrs = [super serializableAttributes];
    
    [attrs addObject:@"eatenBallTimes"];
    [attrs addObject:@"eatenBallPitchIndexes"];
    
    return attrs;
}

+ (NSMutableDictionary*) defaultAttributes {
    NSMutableDictionary* defaults = [super defaultAttributes];
    
    [defaults setValue:[NSNumber numberWithFloat:5.0] forKey:@"width"];
    [defaults setValue:[NSNumber numberWithFloat:5.0] forKey:@"height"];
    [defaults setValue:[NSMutableArray array] forKey:@"eatenBallTimes"];
    [defaults setValue:[NSMutableArray array] forKey:@"eatenBallPitchIndexes"];
    
    return defaults;
}

// ghetto serialize for eaten ball times
- (NSMutableDictionary*) serialize {
    NSMutableDictionary* attributes = [super serialize];
 
    NSMutableArray* eatenTimesDates = [attributes objectForKey:@"eatenBallTimes"];
    NSMutableArray* eatenTimeNumbers = [[NSMutableArray alloc] init];
    for (NSDate* eatenTime in eatenTimesDates) {
        [eatenTimeNumbers addObject:[NSNumber numberWithDouble:[eatenTime timeIntervalSince1970]]];
    }
    [attributes setValue:eatenTimeNumbers forKey:@"eatenBallTimes"];
    return attributes;
}

@end
