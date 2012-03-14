//
//  TriObstacle.m
//  tulpasynth
//
//  Created by Colin Sullivan on 3/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TriObstacle.h"

#import "tulpaViewController.h"
@implementation TriObstacle

- (void)createShape {
    if (!self.width || !self.height) {
        return;
    }

    [super createShape];
    
    self.shape->m_radius = 0.5f;

    b2Vec2 triVertices[3];
    triVertices[0].Set(-self.width/2.0, -self.height/2.0);
    triVertices[1].Set(self.width/2.0, -self.height/2.0);
    triVertices[2].Set(0.0, self.height/2.0);

    ((b2PolygonShape*)self.shape)->Set(triVertices, 3);
    
    b2FixtureDef mySquareFixture;
    mySquareFixture.shape = self.shape;
    mySquareFixture.density = 1.0f;
    mySquareFixture.friction = 0.1f;
    mySquareFixture.restitution = 1.5f;
    
    self.shapeFixture = self.body->CreateFixture(&mySquareFixture);
}


- (void) initialize {
    [super initialize];
    
    b2MassData myBodyMass;
    myBodyMass.mass = 10.0f;
    self.body->SetMassData(&myBodyMass);
    
    self.effect.useConstantColor = YES;
    self.effect.constantColor = self.controller.greenColor;
    self.effect.texture2d0.name = self.controller.triObstacleTexture.name;
    
    for (int i = 0; i < 5; i++) {
        instruments::FMPercussion* instr = new instruments::FMPercussion();
        instr->finish_initializing();
        instrs.push_back(instr);
    }
    [[self class] pitchGenerator];
    nextInstr = 0;
}

- (void) handleCollision:(float)collisionStrength {
    
    [super handleCollision:collisionStrength];
    
    /**
     *  Array of pitch indexes to use.  0 is the root of the scale.
     **/
    static const int pitchGeneratorOutputMapping[] = {0, 4, 5, 7, 10, 12, 14, 17};

    int pitchTableIndex = [[self class] pitchGenerator]->nextIndex();
    NSLog(@"pitchTableIndex: %d", pitchTableIndex);
    int pitch = pitchGeneratorOutputMapping[pitchTableIndex];
    NSLog(@"pitch: %d", pitch);
    int note = 60 + pitch;
    float freq = 440 * pow(2, (note - 69.0)/12.0);
    
    instrs[nextInstr]->freq(freq);
    instrs[nextInstr]->velocity(collisionStrength);
    instrs[nextInstr]->play();
    
    if (++nextInstr >= instrs.size()) {
        nextInstr = 0;
    }
}

+ (SecondOrderMarkovChain*) pitchGenerator {
    static SecondOrderMarkovChain* m;
    
    if (!m) {

        std::vector< std::vector<float> >* theProbs = new std::vector< std::vector<float> >();
        
        struct pitchProbRow {
            float probs[8];
        };
        
        static const pitchProbRow pitchProbs[] = {
        //          C           E           F           G           Bb          C           D           F
         /*         0           4           5           7           10          12          14          17      */
            {/*0 , 0 */  0.0/8.0,    0.0/8.0,    2.0/8.0,     0.0/8.0,   0.0/8.0,    3.0/8.0,    2.0/8.0,    1.0/8.0},
            {/*0 , 4 */  4.0/8.0,    1.0/8.0,    0.0/8.0,     0.0/8.0,   3.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*0 , 5 */  0.0/8.0,    0.0/8.0,    2.0/8.0,     0.0/8.0,   5.0/8.0,    0.0/8.0,    1.0/8.0,    0.0/8.0},
            {/*0 , 7 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    2.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*0 ,10 */  0.0/8.0,    2.0/8.0,    2.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*0 ,12 */  8.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*0 ,14 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     4.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*0 ,17 */  0.0/8.0,    1.0/8.0,    4.0/8.0,     0.0/8.0,   1.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*4 , 0 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*4 , 4 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*4 , 5 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    2.0/8.0,    0.0/8.0},
            {/*4 , 7 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*4 ,10 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*4 ,12 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    4.0/8.0,    2.0/8.0},
            {/*4 ,14 */  3.0/8.0,    3.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*4 ,17 */  2.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*5 , 0 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    4.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*5 , 4 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*5 , 5 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    4.0/8.0,    2.0/8.0},
            {/*5 , 7 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*5 ,10 */  0.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*5 ,12 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    2.0/8.0,    2.0/8.0,    0.0/8.0},
            {/*5 ,14 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*5 ,17 */  0.0/8.0,    2.0/8.0,    3.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    2.0/8.0,    1.0/8.0},
            {/*7 , 0 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    2.0/8.0,    0.0/8.0},
            {/*7 , 4 */  0.0/8.0,    8.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*7 , 5 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*7 , 7 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    2.0/8.0,    2.0/8.0,    0.0/8.0},
            {/*7 ,10 */  2.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*7 ,12 */  2.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*7 ,14 */  0.0/8.0,    0.0/8.0,    2.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*7 ,17 */  0.0/8.0,    4.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            //              C           E           F           G           Bb          C           D           F
            /*              0           4           5           7           10          12          14          17  */    
            {/*10, 0 */  0.0/8.0,    3.0/8.0,    3.0/8.0,     0.0/8.0,   0.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*10, 4 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     4.0/8.0,   4.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*10, 5 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    4.0/8.0},
            {/*10, 7 */  1.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    1.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*10, 10*/  2.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    2.0/8.0,    2.0/8.0},
            {/*10, 12*/  2.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*10, 14*/  0.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*10, 17*/  2.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*12, 0 */  4.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*12, 4 */  0.0/8.0,    3.0/8.0,    0.0/8.0,     0.0/8.0,   3.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*12, 5 */  2.0/8.0,    0.0/8.0,    2.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*12, 7 */  2.0/8.0,    2.0/8.0,    2.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*12, 10*/  2.0/8.0,    0.0/8.0,    2.0/8.0,     2.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*12, 12*/  2.0/8.0,    2.0/8.0,    2.0/8.0,     0.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*12, 14*/  2.0/8.0,    2.0/8.0,    2.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*12, 17*/  0.0/8.0,    0.0/8.0,    4.0/8.0,     0.0/8.0,   0.0/8.0,    2.0/8.0,    2.0/8.0,    0.0/8.0},
            {/*14, 0 */  0.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*14, 4 */  0.0/8.0,    0.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*14, 5 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*14, 7 */  0.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*14, 10*/  0.0/8.0,    0.0/8.0,    2.0/8.0,     2.0/8.0,   0.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*14, 12*/  0.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   0.0/8.0,    0.0/8.0,    4.0/8.0,    4.0/8.0},
            {/*14, 14*/  0.0/8.0,    2.0/8.0,    2.0/8.0,     0.0/8.0,   0.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*14, 17*/  2.0/8.0,    0.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 0 */  0.0/8.0,    2.0/8.0,    2.0/8.0,     2.0/8.0,   2.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 4 */  0.0/8.0,    0.0/8.0,    0.0/8.0,     2.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    2.0/8.0},
            {/*17, 5 */  4.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 7 */  2.0/8.0,    2.0/8.0,    0.0/8.0,     0.0/8.0,   2.0/8.0,    2.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 10*/  0.0/8.0,    0.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    4.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 12*/  0.0/8.0,    4.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 14*/  0.0/8.0,    4.0/8.0,    0.0/8.0,     0.0/8.0,   4.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0},
            {/*17, 17*/  0.0/8.0,    4.0/8.0,    0.0/8.0,     4.0/8.0,   0.0/8.0,    0.0/8.0,    0.0/8.0,    0.0/8.0}
        };
        
        // for each row in pitch table
        for (int i = 0; i < sizeof(pitchProbs) / sizeof(pitchProbs[0]); i++) {
            // create row in vector
            std::vector<float>* theRow = new std::vector<float>(pitchProbs[i].probs, pitchProbs[i].probs + sizeof(pitchProbs[i].probs) / sizeof(float));
            theProbs->push_back((*theRow));
        }
        
        m = new SecondOrderMarkovChain(theProbs);
    }
    
    return m;
}


@end