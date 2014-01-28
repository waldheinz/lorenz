//
//  GlView.h
//  Lorenz
//
//  Created by Matthias Treydte on 25.01.14.
//
//

#import <Cocoa/Cocoa.h>

#include "LorenzDraw.h"

@interface GlView : NSOpenGLView

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;
- (void)tick;

@end
