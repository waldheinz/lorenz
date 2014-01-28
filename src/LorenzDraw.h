//
//  LorenzDraw.h
//  Lorenz
//
//  Created by Matthias Treydte on 25.01.14.
//
//

#ifndef __Lorenz__LorenzDraw__
#define __Lorenz__LorenzDraw__

struct lorenz_state;

struct lorenz_state* lorenz_create();
void lorenz_init(struct lorenz_state*);
void lorenz_configure(struct lorenz_state* state, int count);
void lorenz_resize(float width, float height);
void lorenz_release(struct lorenz_state*);
void lorenz_animate(struct lorenz_state*);
void lorenz_draw(struct lorenz_state*);

#endif /* defined(__Lorenz__LorenzDraw__) */
