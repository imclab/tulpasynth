//
//  PolygonObstacle.m
//  tulpasynth
//
//  Created by Colin Sullivan on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PolygonObstacle.h"

@implementation PolygonObstacle

- (void)setHeight:(float)height {
    [super setHeight:height];
    
    [self createShape];
}

- (void)setWidth:(float)width {
    [super setWidth:width];
    
    [self createShape];
}

- (void)setWidth:(float)aWidth withHeight:(float)aHeight {
    super.width = aWidth;
    super.height = aHeight;
    
    [self createShape];
}

- (void) destroyShape {
    if (self.shapeFixture) {
        self.body->DestroyFixture(self.shapeFixture);        
    }
    
    if (self.shape) {
        delete (b2PolygonShape*)self.shape;
    }
}

- (void) createShape {
    [self destroyShape];
    
    self.shape = new b2PolygonShape();
}

@end