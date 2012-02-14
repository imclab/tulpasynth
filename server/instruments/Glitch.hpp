/**
 *  @file       Glitch.hpp
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2011 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

#ifndef _GLITCH_H_
#define _GLITCH_H_

#include <Sampler.h>

#include "Instrument.hpp"


using namespace stk;

namespace instruments {
    class Glitch : private Instrument, public Sampler
    {
    public:
        /**
         *  Create a glitch sampler.
         *
         *  @param  numClips  Amount of glitch clips we 
         *  can choose from.
         **/
        Glitch(Orchestra* anOrch, Json::Value initialAttributes, int numClips);
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

        virtual void play() {
            this->noteOn(-1, -1);
            return;
        }

        virtual stk::StkFloat next_samp(int chan) {
            return this->tick(chan);
        }

        virtual stk::StkFrames& next_buf(stk::StkFrames& frames, unsigned int channel) {
            return this->tick(frames, channel);
        }

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

    inline StkFloat Glitch::tick(unsigned int channel) {

        FileWvIn* clip = this->mCurrentClip;
        StkFloat result = 0.0;

        // If there is currently a clip playing
        if(clip != NULL) {
            // Grab a sample off of the clip
            result = clip->tick(channel);

            // If file is done playing
            if(clip->isFinished()) {
                this->mCurrentClip = NULL;
                clip->reset();
            }
        }

        return result;
    }

    inline StkFrames& Glitch::tick(StkFrames& frames, unsigned int channel) {
        FileWvIn* clip = this->mCurrentClip;

        if (clip) {
            // Grab samples off of clip
            clip->tick(frames);

            // If we've finished playing file
            if(clip->isFinished()) {
                this->mCurrentClip = NULL;
                clip->reset();
            }
        }

        return frames;
    }
}

#endif