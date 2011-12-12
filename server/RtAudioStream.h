/**
 *  @file       RtAudioStream.h
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *  
 *              Copyright (c) 2011 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#ifndef _RTAUDIOSTREAM_H_
#define _RTAUDIOSTREAM_H_

#include <string>
#include <RtAudio.h>
#include "Globals.h"

/**
 *  @name   RtAudioStream
 *  @class  RtAudio configuration abstraction.
 *  Utilizes callback function passed into the
 *  `start` method to use for generating samples.
 *  Abstracts away much of RtAudio configuration.
 **/
class RtAudioStream
{
public:
    RtAudioStream();
    ~RtAudioStream();

    /**
     *  Opens a stream.  Takes a callback to use for
     *  sound generation.
     *
     *  @param  callback  Called to fill each buffer.
     **/
    void init(RtAudioCallback callback);

    /**
     *  Starts a stream.
     **/
    void start();

    /**
     *  Stops and closes a stream.
     **/
    void stop();

    /**
     *  Return our bufferFrames
     **/
    unsigned int getBufferFrames() { return this->bufferFrames; }
    

private:
    
    /**
     *  The master RtAudio instance.
     *  Used to play all sounds.
     **/
    RtAudio adac;

    /**
     *  Master sample index
     **/
    int t;

    /**
     *  Buffer size.
     **/
    unsigned int bufferFrames;

    /**
     *  Handle error and exit.  Takes a string to print to the screen.
     *
     *  @param  errorMessage  String error message to print to screen
     **/
    void handle_error_and_exit(std::string errorMessage);

    /**
     *  Handle error and exit.  Takes RtError object, just sends
     *  string to above method.
     *
     *  @param  e  Address to the RtError object.
     **/
    void handle_error_and_exit(RtError& e);

    /**
     *  Close stream.  Used when exiting.
     **/
    void cleanup();
};

#endif