# This file is part of ranger, the console file manager.
# License: GNU GPL version 3, see the file "AUTHORS" for details.

from __future__ import absolute_import, division, print_function

from ranger.colorschemes.default import Default
from ranger.gui.color import black, blue, bold, green, red


class Scheme(Default):
    progress_bar_color = green

    def use(self, context):
        fg, bg, attr = Default.use(self, context)

        if context.border:
            fg = black
        return fg, bg, attr
