from pyglet.gl import *

# [...omitted: set up a GL context and framebuffer]
glBegin(GL_QUADS)
glVertex3f(0, 0, 0)
glVertex3f(0.1, 0.2, 0.3)
glVertex3f(0.1, 0.2, 0.3)
glEnd()