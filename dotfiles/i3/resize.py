#!/usr/bin/python

import i3ipc

# Create the Connection object that can be used to send commands and subscribe to events.
i3 = i3ipc.Connection()


def borders_on_resize(i3, event):
    if event.change == "resize":
        i3.command('[class="[.]*"] border pixel 10')

    else:
        i3.command('[class="[.]*"] border pixel 3')


i3.on("mode", borders_on_resize)

# Start the main loop and wait for events to come in.
i3.main()
