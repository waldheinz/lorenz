//
//  GlView.m
//  Lorenz
//
//  Created by Matthias Treydte on 25.01.14.
//
//

#import "GlView.h"

@implementation GlView

struct lorenz_state* state;

- (id)initWithFrame:(NSRect)frameRect
{
    
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc]  autorelease];
    
    self = [super initWithFrame:frameRect pixelFormat:format];
    
    if (self) {
        state = lorenz_create();
        [[self openGLContext] makeCurrentContext];
        lorenz_init(state);
        lorenz_resize(frameRect.size.width, frameRect.size.height);
    }
    
    return self;
}

- (void) drawRect:(NSRect)dirtyRect
{
    [[self openGLContext] makeCurrentContext];
    lorenz_animate(state);
    lorenz_draw(state);
}

- (void) tick
{
    //lorenz_animate(state);
}

- (void) setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    
    [[self openGLContext] makeCurrentContext];
    
    lorenz_resize(newSize.width, newSize.height);
    
    [[self openGLContext] update];
}

@end
