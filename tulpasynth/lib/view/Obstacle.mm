/**
 *  @file       Obstacle.mm
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#import "Obstacle.h"

#import "tulpaViewController.h"

@implementation Obstacle

@synthesize selected, deleteButton;


- (void) setSelected:(BOOL)wasSelected {
    if (wasSelected) {
        self.color = self.controller.orangeColor;
        self.deleteButton.active = true;
        [self.controller.selectedObstacles addObject:self];
    }
    else {
        self.deleteButton.active = false;
        self.color = self.controller.greenColor;
    }
    selected = wasSelected;
}

- (id)initWithController:(tulpaViewController *)theController withModel:(Model *)aModel {
    if (self = [super initWithController:theController withModel:aModel]) {
        // set selected to false after initialize has been called.
        self.selected = false;
    }
    
    return self;
}

- (void) initialize {
    [super initialize];
    
    self.color = self.controller.greenColor;
    self.deleteButton = [[ObstacleDeleteButton alloc] initWithController:self.controller withModel:self.model];
    self.deleteButton.active = false;
}

- (GLboolean) handleTap:(TapEntity *)tap {
    // if tap wasn't for us
    if (![super handleTap:tap]) {
        // was it for delete button
        if (self.selected && [self.deleteButton handleTap:tap]) {
            return true;
        }
    }
    else {
        return true;
    }
    return false;
}

- (void) handleTapOccurred:(TapEntity *)aTap {
    [super handleTapOccurred:aTap];
    [self.controller selectObstacle:self];
}

- (void) postDraw {
    [super postDraw];
    
    [self.deleteButton prepareToDraw];
    [self.deleteButton draw];
    [self.deleteButton postDraw];
}

- (void) update {
    [super update];
    
    [self.deleteButton update];
}

- (void) destroy {
    [super destroy];

    try {
        [self.controller.obstacles removeObject:self];
    } catch (NSException* e) {
        if (e.name == NSRangeException) {
            NSLog(@"NSRangeException occurred controller.obstacles removeObject");
        }
        else {
            NSLog(@"other exception occurred obstacles removeObject");
        }
    }
}

@end
