/**
 *  @file       Glitch.hpp
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2011 Colin Sullivan
 *              Licensed under the MIT license.
 **/

#ifndef _GLITCH_H_
#define _GLITCH_H_

#include <Sampler.h>

using namespace stk;

namespace instruments {
    class Glitch : public Sampler
    {
    public:
        /**
         *  Create a glitch sampler.
         *
         *  @param  numClips  Amount of glitch clips we 
         *  can choose from.
         **/
        Glitch(int numClips);
        ~Glitch(){};

        /**
         *  Set new random clip to play
         **/
        void noteOn( StkFloat frequency, StkFloat amplitude );

        /**
         *  Do nothing for now
         **/
        void setFrequency( StkFloat frequency ){};

        /**
         *  Do nothing for now
         **/
        void controlChange( int number, StkFloat value ){};


        StkFloat tick( unsigned int channel = 0 );
        StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );


    private:

        /**
         *  Amount of clips we can choose from when 
         *  playing a beat.
         **/
        int mNumClips;

        /**
         *  Clip that we're currently playing (have not yet finished)
         **/
        FileWvIn* mCurrentClip;

        /**
         *  Get a new random clip to use.
         **/
        FileWvIn* new_current_clip();

        /**
         *  Get the current clip (or start a new one)
         **/
        FileWvIn* get_current_clip();
    };

    inline StkFloat Glitch::tick(unsigned int) {

        FileWvIn* clip = this->mCurrentClip;

        // If there is currently a clip playing
        if(clip) {
            // Grab a sample off of the clip
            StkFloat result = clip->tick();

            // If file is done playing
            if(clip->isFinished()) {
                this->mCurrentClip = NULL;
                clip->reset();
            }

            return result;
        }
        else {
            return 0.0;
        }
    }

    inline StkFrames& Glitch::tick(StkFrames& frames, unsigned int channel) {
        FileWvIn* clip = this->mCurrentClip;

        if (clip) {
            // Grab samples off of clip
            StkFrames result = clip->tick(frames);

            // If we've finished playing file
            if(clip->isFinished()) {
                this->mCurrentClip = NULL;
                clip->reset();
            }

            return result;
        }
        else {
            return frames;
        }
    }
}

#endif