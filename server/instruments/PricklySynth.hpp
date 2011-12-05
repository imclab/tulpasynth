/**
 *  @file       PricklySynth.hpp
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2011 Colin Sullivan
 *              Licensed under the MIT license.
 **/


#ifndef _PRICKLYSYNTH_HPP_
#define _PRICKLYSYNTH_HPP_

#include <BlitSaw.h>
#include <SineWave.h>

#include "Instrument.hpp"
#include "../Globals.h"

namespace instruments {

class PricklySynth : private Instrument
{
public:
    PricklySynth(Orchestra* anOrch, Json::Value initialAttributes);
    ~PricklySynth() {};

    virtual void play() {
        Instrument::play();
    }

    virtual stk::StkFrames& next_buf(stk::StkFrames& frames);

protected:
    // BPF f;
    stk::BlitSaw mFundSaw;
    stk::StkFloat mFundSawGain;

    stk::SineWave mFundSine;
    stk::StkFloat mFundSineGain;

    stk::SineWave mLowSine;
    stk::StkFloat mLowSineGain;

    stk::BlitSaw mJuice;
    stk::StkFloat mJuiceGain;

    stk::SineWave mSweeper;
    stk::StkFloat mSweeperGain;

    /**
     *  When modulating filter's frequency, stay within bounds.
     **/
    float mMinFilterFreq;
    float mMaxFilterFreq;

    /**
     *  BPF stuff
     **/
    stk::StkFloat m_a0;
    stk::StkFloat m_b1;
    stk::StkFloat m_b2;
    stk::StkFloat m_y1;
    stk::StkFloat m_y2;

    void filterFreq(stk::StkFloat freq) {
        /**
         *  BPF code stolen from ChucK ugen_filter.cpp:682
         **/

        stk::StkFloat Q = 5;

        stk::StkFloat pfreq = freq * RADIANS_PER_SAMPLE;
        stk::StkFloat pbw = 1.0 / Q * pfreq * .5;

        stk::StkFloat C = 1.0 / ::tan(pbw);
        stk::StkFloat D = 2.0 * ::cos(pfreq);
        stk::StkFloat next_a0 = 1.0 / (1.0 + C);
        stk::StkFloat next_b1 = C * D * next_a0 ;
        stk::StkFloat next_b2 = (1.0 - C) * next_a0;

        this->m_a0 = next_a0;
        this->m_b1 = next_b1;
        this->m_b2 = next_b2;
    }

};

  
}; // namespace instruments

#endif