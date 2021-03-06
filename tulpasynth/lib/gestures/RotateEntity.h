/**
 *  @file       RotateEntity.h
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#ifndef _ROTATEENTITY_H_
#define _ROTATEENTITY_H_

#include "GestureEntity.h"

/**
 *  @class  Abstraction for a `UIRotationGestureRecognizer`, exposes the
 *  amount of rotation.
 **/
class RotateEntity : public GestureEntity
{
public:
    RotateEntity(UIRotationGestureRecognizer* rotateRecognizer);
    ~RotateEntity();


    /**
     *  Amount of rotation in this gesture (in radians).
     **/
    float32 rotation;
    
    virtual void update();

};

#endif