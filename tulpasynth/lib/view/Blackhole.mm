
//
//  Blackhole.m
//  tulpasynth
//
//  Created by Colin Sullivan on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Blackhole.h"

#import "tulpaViewController.h"

@implementation Blackhole

- (void) setWidth:(float)width {
    [super setWidth:width];
    
    self.shape->m_radius = self.width/2;
}

- (void) initialize {
    [super initialize];
    
    BlackholeModel* model = ((BlackholeModel*)self.model);
    
    self.shape = new b2CircleShape();
    self.width = [model.width floatValue];
    
    b2FixtureDef myShapeFixture;
    myShapeFixture.shape = self.shape;
    myShapeFixture.friction = 0.1f;
    myShapeFixture.density = 0.75f;
    myShapeFixture.restitution = 1.0f;
    self.shapeFixture = self.body->CreateFixture(&myShapeFixture);

    b2MassData myBodyMass;
    myBodyMass.mass = 0.25f;
    myBodyMass.center.SetZero();
    self.body->SetMassData(&myBodyMass);

    self.effect.texture2d0.name = self.controller.blackholeTexture.name;
    self.effect.useConstantColor = YES;
    self.effect.constantColor = self.controller.greenColor;
}

@end