//
//  TriObstacle.h
//  tulpasynth
//
//  Created by Colin Sullivan on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolygonObstacle.h"

#include <vector>
#include "FMPercussion.hpp"
#include "SecondOrderMarkovChain.hpp"

#include "WildBallModel.h"

/**
 *  @class  A triangular obstacle.
 **/
@interface TriObstacle : PolygonObstacle {
    /**
     *  Instruments we will use to sonify collisions.
     **/
    std::vector<instruments::FMPercussion*> instrs;
    /**
     *  Index of next instrument to play, polyphony for multiple
     *  collisions.
     **/
    int nextInstr;
}

/**
 *  The markov chain that will be used to generate pitches for all instances
 *  of TriObstacles.
 **/
+ (SecondOrderMarkovChain*) pitchGenerator;

+ (NSArray*) pitchIndexToNoteMapping;

+ (float) pitchIndexToFreq:(int)index;

+(GLKVector4) pitchIndexToColor:(int) index;
+(void) HSVtoRGB:(float *)r :(float *)g :(float *)b :(float )h :(float )s :(float )v;

@end
