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

- (void) warmUp
{
   orbs[0].x = 1;
   
   for (int i=0; i < 20000; i++) {
      [self nextStep : orbs];
   }
   
   for (int i=1; i < particleCount; i++) {
      orbs[i] = orbs[0];
   }
}

- (void) nextStep: (Orbiter*) orb
{   
   const static float a = 5;
   const static float b = 15;
   const static float c = 1;
   
   const float ox = orb->x;
   const float oy = orb->y;
   const float oz = orb->z;
   
   orb->x = ox + (-a*ox*dt) + (a*oy*dt);
   orb->y = oy + (b*ox*dt)  - (oy*dt) - (oz*ox*dt);
   orb->z = oz + (-c*oz*dt) + (ox*oy*dt);
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
   self = [super initWithFrame:frame isPreview:isPreview];
   
   if (self) {
      
      defaults = defaults =
      [ScreenSaverDefaults defaultsForModuleWithName:MyModuleName];
      
      
      NSOpenGLPixelFormatAttribute attributes[] = { 
         NSOpenGLPFAAccelerated,
         NSOpenGLPFADepthSize, 16,
         NSOpenGLPFAMinimumPolicy,
         NSOpenGLPFAClosestPolicy,
         0
      };
      
      NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] 
                                      initWithAttributes:attributes] autorelease];
      
      glView = [[de_waldheinz_MyOpenGlView alloc] initWithFrame:NSZeroRect 
                                       pixelFormat:format];
      
      GLint swap = 1;
      [[glView openGLContext] setValues:&swap forParameter: NSOpenGLCPSwapInterval];
      
      if (!glView)
      {             
         NSLog( @"Couldn't initialize OpenGL view." );
         [self autorelease];
         return nil;
      }
      
      orbs = NULL;
      
      [self readSettings];
      [self addSubview:glView]; 
      [self setupOpenGl];
      [self makeTexture];
      [self setAnimationTimeInterval:1/30.0];
   }  
   
   return self;
}

- (void) setParticleCount: (int) count
{
   if (count <= 128) count = 128;
   if (count > 4096) count = 4096;
   
   if (orbs != NULL) free(orbs);
   orbs = NULL;
   
   orbs = (Orbiter*)malloc(count * sizeof(Orbiter));
   particleCount = count;
   [self warmUp];
}

- (void) readSettings
{   
   [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                               @"2000", @"ParticleCount",
                               @"2", @"TimeStep",
                               @"0", @"ColorScheme",
                               nil]];
   
   speed = 0.002f;
   dt = [defaults floatForKey:@"TimeStep"] / 100;
   colorScheme = [defaults integerForKey:@"ColorScheme"];
   [self setParticleCount: [defaults integerForKey:@"ParticleCount"]];
   rotSpeed = 0.001;
}

- (void) makeTexture
{
   const int twidth = 256;
   const int theight = 256;
   const int tbpp = 24;
   
   /* make texture */
   Byte* const textur = malloc(twidth * theight * (tbpp / 8));
   
   if (textur != NULL) {
      for (int i=0; i < twidth; i++) {
         for (int j=0; j < theight; j++) {
            Byte temp = 200*(1-sqrt(((128-i)*(128-i)) + ((128-j)*(128-j)) )/150)*
            (1-sqrt(((128-i)*(128-i)) + ((128-j)*(128-j)) )/150);
            if (temp > 0) {
               *(textur + i*twidth*3 + j*3) = temp;
            } else {
               *(textur + i*twidth*3 + j*3) = 0;
            }
            
            *(textur + i*twidth*3 + j*3 + 1) = *(textur + i*twidth*3 + j*3);
            *(textur + i*twidth*3 + j*3 + 2) = *(textur + i*twidth*3 + j*3);
         }
      }
      
      glGenTextures(1, &texture);
      glBindTexture(GL_TEXTURE_2D, texture);
      glTexImage2D(GL_TEXTURE_2D, 0, tbpp / 8, twidth, theight, 0,
                   GL_RGB, GL_UNSIGNED_BYTE, textur);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      glEnable(GL_TEXTURE_2D);
      glFlush();
      free(textur);
   }
   
   /* make display list */
   quadList = glGenLists(1);
   glNewList(quadList, GL_COMPILE);
   glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,-1.0, 0.0);
   glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,-1.0, 0.0);
   glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0.0);
   glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0.0);
   glEnd();
   glEndList();
}

- (void)dealloc
{
   [glView removeFromSuperview];
   [glView release];
   free (orbs);
   
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

float calcScale(float ttl) {
   return (-4 * (ttl * ttl) + 4 * ttl) / 2;
}

- (void)drawRect:(NSRect)rect
{
   [super drawRect:rect];
   
   glClear(GL_COLOR_BUFFER_BIT);
   glLoadIdentity();
   
   glTranslatef(0, 0, -30);
   
   glRotatef(rx * 360, 1.0, 0.0, 0.0);
   glRotatef(ry * 360, 0.0, 1.0, 0.0);
   glRotatef(rz * 360, 0.0, 0.0, 1.0);   
   
   for (int i=0; i<particleCount; i++) {
      const Orbiter* const o = orbs + i;
      
      if (orbs[i].ttl > 0) {
         glPushMatrix();
         
         glColor3f(o->cr, o->cg, o->cb);
         glTranslatef(o->x,o->y,o->z);
         float scale = calcScale(o->ttl);
         //scale *= scale;
         glScalef(scale, scale, scale);
         
         /* rotate back to face camera */
         glRotatef (-rz * 360, 0.0, 0.0, 1.0);
         glRotatef (-ry * 360, 0.0, 1.0, 0.0);
         glRotatef (-rx * 360, 1.0, 0.0, 0.0);
         
         /* put a star */
         glCallList(quadList);
         
         glPopMatrix();
      }
   }
   
   glFlush();
}

- (float) myrand
{
   return ((float)random() / RAND_MAX);
}

- (void)animateOneFrame
{
   GLfloat ttl_sub = 1.0f / particleCount;
   for (int iter=0; iter < 5; iter++) {
      for (int i=particleCount-1; i > 0; --i) {
         orbs[i] = orbs[i-1];
         orbs[i].x += orbs[i].dx * (1-orbs[i].ttl);
         orbs[i].y += orbs[i].dy * (1-orbs[i].ttl);
         orbs[i].z += orbs[i].dz * (1-orbs[i].ttl);
         orbs[i].ttl -= ttl_sub;
      }
      
      /* init the new particle */
      
      Orbiter* const o = orbs;
      [self nextStep : o];
      o->dx = (0.5-[self myrand]) * speed;
      o->dy = (0.5-[self myrand]) * speed;
      o->dz = (0.5-[self myrand]) * speed;
      o->ttl = 0.5f + [self myrand] / 2.0f;
      
      float r, g, b;
      
      if (colorScheme == 0) {
         /* random colors */
         r = [self myrand];
         g = [self myrand];
         b = [self myrand];
      } else {
         /* Nici's colors */
         if ([self myrand] > 0.7f) {
            r=1.0f; g=0.41f; b=0.71f;
         } else {
            r=0.98f; g=0.98f; b=0.76f;
         }
      }
      
      o->cr = r;
      o->cg = g;
      o->cb = b;      
   }
   
   /* rotate view */
   rx += rotSpeed;
   if (rx >= 1) rx = 0;
   ry += rotSpeed;
   if (ry >= 1) ry = 0;
   rz += rotSpeed;
   if (rz >= 1) rz = 0;
   
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
   [colorRandomButton setState: ((colorScheme == 0) ? NSOnState : NSOffState)];
   [colorNiciButton setState: ((colorScheme == 1) ? NSOnState : NSOffState)];
   
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
   
   [self setParticleCount:[particleCountOption intValue]];
   dt = [timeStepSlider floatValue] / 100;
   
   if ([colorRandomButton state] == NSOnState) {
      colorScheme = 0;
   } else if ([colorNiciButton state] == NSOnState) {
      colorScheme = 1;
   }
   
   [defaults setInteger:colorScheme forKey: @"ColorScheme"];
   
   // Save the settings to disk
   [defaults synchronize];
   
   // Close the sheet
   [[NSApplication sharedApplication] endSheet:configSheet];
}

- (void) setFrameSize:(NSSize)newSize
{
   [super setFrameSize:newSize];
   
   [glView setFrameSize:newSize];
   [[glView openGLContext] makeCurrentContext];
   
   glViewport(0, 0, (GLint)newSize.width, (GLint)newSize.height);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   gluPerspective(90, (GLfloat)newSize.width / newSize.height, 0.1, 100);
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity();
   glClear(GL_COLOR_BUFFER_BIT);
   
   [[glView openGLContext] update];
}

- (void) setupOpenGl
{
   [[glView openGLContext] makeCurrentContext];
   glShadeModel(GL_SMOOTH);
   glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
   glClearDepth(1.0);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA,GL_ONE);
}

@end
