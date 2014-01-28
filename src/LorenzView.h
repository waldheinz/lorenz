//
//  LorenzView.h
//  Lorenz
//
//  Created by Matthias on 28.03.09.
//  Copyright (c) 2009, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <OpenGL/gl.h>

#include "LorenzDraw.h"
#include "GlView.h"

@interface de_waldheinz_LorenzView : ScreenSaverView
{   
    IBOutlet id configSheet;
    IBOutlet NSSlider *particleCountOption;
    IBOutlet NSSlider *timeStepSlider;
    IBOutlet NSButtonCell *colorRandomButton;
    IBOutlet NSButtonCell *colorNiciButton;
}

- (void) readSettings;
- (IBAction) okClick: (id) sender;
- (IBAction) cancelClick: (id) sender;

@end
