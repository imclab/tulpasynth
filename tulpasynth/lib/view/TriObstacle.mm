/**
 *  @file       TriObstacle.mm
 *
 *  @author     Colin Sullivan <colinsul [at] gmail.com>
 *
 *              Copyright (c) 2012 Colin Sullivan
 *              Licensed under the GPLv3 license.
 **/

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
    mySquareFixture.restitution = 1.0f;
    
    self.shapeFixture = self.body->CreateFixture(&mySquareFixture);
}


- (void) initialize {
    [super initialize];
    
    b2MassData myBodyMass;
    myBodyMass.mass = 10.0f;
    self.body->SetMassData(&myBodyMass);
    
    self.effect.texture2d0.name = self.controller.triObstacleTexture.name;
    
    for (int i = 0; i < 5; i++) {
        instruments::FMPercussion* instr = new instruments::FMPercussion();
        instr->gain(0.2);
        instr->finish_initializing();
        instrs.push_back(instr);
    }
    [[self class] pitchGenerator];
    nextInstr = 0;
}

- (void) handleCollision:(PhysicsEntity *)otherEntity withStrength:(float)collisionStrength {
    [super handleCollision:otherEntity withStrength:collisionStrength];
    


    int pitchTableIndex = [[self class] pitchGenerator]->nextIndex();
//    NSLog(@"pitchTableIndex: %d", pitchTableIndex);

    
    
    self.color = [[self class] pitchIndexToColor:pitchTableIndex];
    
    instrs[nextInstr]->freq([[self class] pitchIndexToFreq:pitchTableIndex]);
    instrs[nextInstr]->velocity(collisionStrength);
    instrs[nextInstr]->play();
    
    if (++nextInstr >= instrs.size()) {
        nextInstr = 0;
    }
    
    // give pitch to ball model
    WildBallModel* m = (WildBallModel*)otherEntity.model;
    m.pitchIndex = [NSNumber numberWithInt:pitchTableIndex];
}

+ (NSArray*) pitchIndexToNoteMapping {
    /**
     *  Array of pitch indexes to use.  0 is the root of the scale.
     **/
    
    static NSArray* theMapping;
    
    if (!theMapping) {
        theMapping = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:4],
                      [NSNumber numberWithInt:5],
                      [NSNumber numberWithInt:7],
                      [NSNumber numberWithInt:10],
                      [NSNumber numberWithInt:12],
                      [NSNumber numberWithInt:14],
                      [NSNumber numberWithInt:17],
                      nil];
    }
    
    return theMapping;
}

+ (float) pitchIndexToFreq:(int)index {
    NSNumber* pitch = [[[self class] pitchIndexToNoteMapping] objectAtIndex:index];
    //    NSLog(@"pitch: %d", pitch);
    int note = 72 + [pitch intValue];
    float freq = 440 * pow(2, (note - 69.0)/12.0);
    return freq;
}

+(GLKVector4) pitchIndexToColor:(int) index {
    static float upperBoundFreq = 440 * pow(2, ((60+17) - 69.0)/12.0);
    
    float freq = [[self class] pitchIndexToFreq:index];
    float r, g, b;
    [[self class] HSVtoRGB:&r :&g :&b :(freq/upperBoundFreq)*360.0 :1.0 :1.0];
    
    return GLKVector4Make(r, g, b, 1.0);

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


+(void) HSVtoRGB:(float *)r :(float *)g :(float *)b :(float )h :(float )s :(float )v {
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

+ (GLKBaseEffect*)effectInstance {
    static GLKBaseEffect* theInstance = nil;
    if (!theInstance) {
        theInstance = [[GLKBaseEffect alloc] init];
    }
    return theInstance;
}

+ (GLKBaseEffect*)effect1Instance {
    static GLKBaseEffect* theInstance = nil;
    if (!theInstance) {
        theInstance = [[GLKBaseEffect alloc] init];
    }
    return theInstance;
}

@end
