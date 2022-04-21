import os
import subprocess
from pathlib import Path
from platform import python_version

from IPython.terminal.prompts import Prompts, Token
from pygments.token import Token

c.HistoryManager.enabled = False

c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.color_info = True
c.InteractiveShell.colors = "linux"
c.TerminalInteractiveShell.true_color = True

c.InteractiveShell.sphinxify_docstring = True
c.TerminalInteractiveShell.autoformatter = None
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalInteractiveShell.display_completions = "multicolumn"
c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.editor = "/usr/bin/nvim"
c.TerminalInteractiveShell.enable_history_search = True
c.TerminalInteractiveShell.extra_open_editor_shortcuts = True
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.highlighting_style = "native"
c.TerminalInteractiveShell.prompt_includes_vi_mode = True
c.Completer.use_jedi = True


class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [
            (Token, ""),
            (Token.Number, str(Path().absolute())),
            (Token, " "),
            # (Token.Generic.Heading, " "),
            # (Token.Generic.Subheading, get_branch()),
            # (Token, " "),
            (Token.Literal.String, " "),
            (Token.Literal.String, "v" + python_version()),
            (Token, " "),
            (Token, "\n"),
            (
                Token.Prompt
                if self.shell.last_execution_succeeded
                else Token.Generic.Error,
                ":: ",
            ),
        ]

    def out_prompt_tokens(self, cli=None):
        return []


c.TerminalInteractiveShell.prompts_class = MyPrompt
