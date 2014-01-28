//
//  LorenzView.m
//  Lorenz
//
//  Created by Matthias on 28.03.09.
//  Copyright (c) 2009, __MyCompanyName__. All rights reserved.
//

#import "LorenzView.h"

@implementation de_waldheinz_LorenzView

static NSString * const MyModuleName = @"de.waldheinz.LorenzScreenSaver";

GlView *glView;
ScreenSaverDefaults const *defaults;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
   self = [super initWithFrame:frame isPreview:isPreview];
   
   if (self) {
      
      defaults =
         [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
      
//      NSOpenGLPixelFormatAttribute attributes[] = {
//         NSOpenGLPFAAccelerated,
       //  NSOpenGLPFADepthSize, 32,
//         NSOpenGLPFAMinimumPolicy,
//         NSOpenGLPFAClosestPolicy,
//         0
//      };
           // [[glView openGLContext] setValues:1 forParameter: NSOpenGLCPSwapInterval];
      
      glView = [[GlView alloc] initWithFrame:frame];
      
      if (!glView)
      {             
         NSLog( @"Couldn't initialize OpenGL view." );
         [self autorelease];
         return nil;
      }
      
      [self readSettings];
      [self addSubview:glView];
      
      [self setAnimationTimeInterval:1/30.0];
   }  
   
   return self;
}

- (void) readSettings
{   
   [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                               @"2000", @"ParticleCount",
                               @"2", @"TimeStep",
                               @"0", @"ColorScheme",
                               nil]];
   
   //dt = [defaults floatForKey:@"TimeStep"] / 100;
   //colorScheme = [defaults integerForKey:@"ColorScheme"];
   //[self setParticleCount: [defaults integerForKey:@"ParticleCount"]];
   //rotSpeed = 0.001;
}

- (void)dealloc
{
   [glView removeFromSuperview];
   [glView release];
   
   [super dealloc];
}

- (void)startAnimation
{
   [super startAnimation];
}

- (void)stopAnimation
{
   [super stopAnimation];
}

- (void)animateOneFrame
{
 //  [glView tick];
   [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
   return YES;
}

- (NSWindow*)configureSheet
{
   if (!configSheet)
   {
      if (![NSBundle loadNibNamed:@"Config" owner:self]) 
      {
         NSLog( @"Failed to load configure sheet." );
         NSBeep();
         
         return NULL;
      }
   }
   
   [particleCountOption setIntegerValue: [defaults 
                                  integerForKey:@"ParticleCount"]];
   
   [timeStepSlider setFloatValue: [defaults floatForKey:@"TimeStep"]];
//   [colorRandomButton setState: ((colorScheme == 0) ? NSOnState : NSOffState)];
//   [colorNiciButton setState: ((colorScheme == 1) ? NSOnState : NSOffState)];
   
   return configSheet;
}

- (IBAction)cancelClick: (id)sender
{
   [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction) okClick: (id)sender
{  
   // Update our defaults
   [defaults setInteger:[particleCountOption intValue] 
                 forKey:@"ParticleCount"];
   [defaults setFloat:[timeStepSlider floatValue]
               forKey:@"TimeStep"];
   
//   [self setParticleCount:[particleCountOption intValue]];
//   dt = [timeStepSlider floatValue] / 100;
   
   if ([colorRandomButton state] == NSOnState) {
//      colorScheme = 0;
   } else if ([colorNiciButton state] == NSOnState) {
//      colorScheme = 1;
   }
   
//   [defaults setInteger:colorScheme forKey: @"ColorScheme"];
   
   // Save the settings to disk
   [defaults synchronize];
   
   // Close the sheet
   [[NSApplication sharedApplication] endSheet:configSheet];
}

@end
