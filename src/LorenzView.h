//
//  LorenzView.h
//  Lorenz
//
//  Created by Matthias on 28.03.09.
//  Copyright (c) 2009, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

#import "MyOpenGlView.h"

typedef struct {
   GLfloat x, y, z;
   GLfloat dx, dy, dz;
   GLfloat ttl;
   GLfloat cr, cg, cb;
} Orbiter;

@interface de_waldheinz_LorenzView : ScreenSaverView 
{
   de_waldheinz_MyOpenGlView *glView;
   int particleCount;
   float rx, ry, rz, dt, speed, rotSpeed;
   GLuint texture, quadList;
   Orbiter* orbs;
   int colorScheme;
   
   IBOutlet id configSheet;
   IBOutlet NSSlider *particleCountOption;
   IBOutlet NSSlider *timeStepSlider;
   IBOutlet NSButtonCell *colorRandomButton;
   IBOutlet NSButtonCell *colorNiciButton;
   
   ScreenSaverDefaults const *defaults;
}

- (void) setParticleCount: (int) count;
- (void) nextStep: (Orbiter*) orb;
- (void) setupOpenGl;
- (void) warmUp;
- (float) myrand;
- (void) readSettings;
- (void) makeTexture;
- (IBAction) okClick: (id)sender;
- (IBAction) cancelClick: (id)sender;

@end
