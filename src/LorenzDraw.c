//
//  LorenzDraw.cpp
//  Lorenz
//
//  Created by Matthias Treydte on 25.01.14.
//
//

#include "LorenzDraw.h"

#include <stdlib.h>
#include <math.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>

typedef struct {
    GLfloat x, y, z;
    GLfloat dx, dy, dz;
    GLfloat ttl;
    GLfloat cr, cg, cb;
} orbiter;

struct lorenz_state {
    orbiter* orbs;
    int count;
    int color_scheme;
    float rx, ry, rz, dt, speed, rotSpeed;
    GLuint texture, quadList;
};

struct lorenz_state* lorenz_create() {
    struct lorenz_state* result = (struct lorenz_state*) malloc(sizeof(struct lorenz_state));
    
    result->speed = 0.002;
    result->rotSpeed = 0.001;
    result->color_scheme = 0;
    result->dt = 0.001;
    result->orbs = 0;
    result->rx = 0.01;
    result->ry = 0.01;
    result->rz = 0.01;
    result->rotSpeed = 0.001;
    
    lorenz_configure(result, 100000);
    
    return result;
}

void nextStep(const float dt, orbiter* orb);

void warmUp(struct lorenz_state* state) {
    orbiter* orbs = state->orbs;
    
    orbs[0].x = 1;
    orbs[0].y = 1;
    orbs[0].z = 1;
    
    for (int i=0; i < 20000; i++) {
        nextStep(state->dt, orbs);
    }
    
    for (int i=1; i < state->count; i++) {
        orbs[i] = orbs[0];
        nextStep(state->dt, orbs);
    }
}

void nextStep(const float dt, orbiter* orb) {
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


void lorenz_configure(struct lorenz_state* state, int count) {
    if (count <= 128) {
        count = 128;
    }
    
    if (count > 4096) {
        count = 4096;
    }
    
    if (state->orbs) {
        free(state->orbs);
        state->orbs = 0;
    }
    
    state->orbs = (orbiter*) malloc(count * sizeof(orbiter));
    state->count = count;
    warmUp(state);
}

float calcScale(const float ttl) {
    return (-4 * (ttl * ttl) + 4 * ttl) / 2;
}

void lorenz_draw(struct lorenz_state *st) {
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    
    glTranslatef(0, 0, -30);
    
    glRotatef(st->rx * 360, 1.0, 0.0, 0.0);
    glRotatef(st->ry * 360, 0.0, 1.0, 0.0);
    glRotatef(st->rz * 360, 0.0, 0.0, 1.0);
    
    for (int i=0; i < st->count; i++) {
        const orbiter* const o = &st->orbs[i];
        
        if (o->ttl > 0) {
            glPushMatrix();
            
            glColor3f(o->cr, o->cg, o->cb);
            glTranslatef(o->x,o->y,o->z);
            float scale = calcScale(o->ttl);
            //scale *= scale;
            glScalef(scale, scale, scale);
            
            /* rotate back to face camera */
            glRotatef (-st->rz * 360, 0.0, 0.0, 1.0);
            glRotatef (-st->ry * 360, 0.0, 1.0, 0.0);
            glRotatef (-st->rx * 360, 1.0, 0.0, 0.0);
            
            /* put a star */
            glCallList(st->quadList);
            
            glPopMatrix();
        }
    }
    
    glFlush();
}


inline float myrand() {
    return ((float)random() / RAND_MAX);
}

void lorenz_resize(float width, float height) {
    glViewport(0, 0, (GLint)width, (GLint)height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(90, (GLfloat)width / height, 0.1, 100);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT);
}

void lorenz_animate(struct lorenz_state* st) {
    GLfloat ttl_sub = 1.0f / st->count;
    orbiter* orbs = st->orbs;
    
    for (int iter=0; iter < 50; iter++) {
        for (int i=st->count-1; i > 0; --i) {
            orbs[i] = orbs[i-1];
            orbs[i].x += orbs[i].dx * (1-orbs[i].ttl);
            orbs[i].y += orbs[i].dy * (1-orbs[i].ttl);
            orbs[i].z += orbs[i].dz * (1-orbs[i].ttl);
            orbs[i].ttl -= ttl_sub;
        }
        
        /* init the new particle */
        
        orbiter* o = orbs;
        nextStep(st->dt, o);
        
        o->dx = (0.5 - myrand()) * st->speed;
        o->dy = (0.5 - myrand()) * st->speed;
        o->dz = (0.5 - myrand()) * st->speed;
        o->ttl = 0.5f + myrand() / 2.0f;
        
        float r, g, b;
        
        if (st->color_scheme == 0) {
            /* random colors */
            r = myrand();
            g = myrand();
            b = myrand();
        } else {
            /* Nici's colors */
            if (myrand() > 0.7f) {
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
    st->rx += st->rotSpeed;
    if (st->rx >= 1) st->rx = 0;
    
    st->ry += st->rotSpeed;
    if (st->ry >= 1) st->ry = 0;
    
    st->rz += st->rotSpeed;
    if (st->rz >= 1) st->rz = 0;
}

void lorenz_init(struct lorenz_state* st) {
    glShadeModel(GL_SMOOTH);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    const int twidth = 256;
    const int theight = 256;
    const int tbpp = 24;
    
    /* make texture */
    unsigned char* const textur = malloc(twidth * theight * (tbpp / 8));
    
    if (textur != NULL) {
        for (int i=0; i < twidth; i++) {
            for (int j=0; j < theight; j++) {
                unsigned char temp = 200*(1-sqrt(((128-i)*(128-i)) + ((128-j)*(128-j)) )/150)*
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
        
        glGenTextures(1, &st->texture);
        glBindTexture(GL_TEXTURE_2D, st->texture);
        glTexImage2D(GL_TEXTURE_2D, 0, tbpp / 8, twidth, theight, 0,
                     GL_RGB, GL_UNSIGNED_BYTE, textur);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glEnable(GL_TEXTURE_2D);
        glFlush();
        free(textur);
    }
    
    /* make display list */
    st->quadList = glGenLists(1);
    glNewList(st->quadList, GL_COMPILE);
    glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex3f(-1.0,-1.0, 0.0);
    glTexCoord2f(1.0, 0.0); glVertex3f( 1.0,-1.0, 0.0);
    glTexCoord2f(1.0, 1.0); glVertex3f( 1.0, 1.0, 0.0);
    glTexCoord2f(0.0, 1.0); glVertex3f(-1.0, 1.0, 0.0);
    glEnd();
    glEndList();
}

void lorenz_release(struct lorenz_state* st) {
    // TODO
}
