import pyglet

from pyglet.window import mouse

window = pyglet.window.Window()

@window.event
def on_key_press(symbol, modifiers):
    print('A key was pressed')

@window.event
def on_mouse_press(x, y, button, modifiers):
    if button == mouse.LEFT:
        print('The left mouse button was pressed.')

@window.event
def on_draw():
    window.clear()

pyglet.app.run()