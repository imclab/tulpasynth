/**
 *  @file       BlockModel.h
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#import "ObstacleModel.h"

@interface BlockModel : ObstacleModel

/**
 *  Maximum and minimum widths
 **/
+ (float) minWidth;
+ (float) maxWidth;

@end
