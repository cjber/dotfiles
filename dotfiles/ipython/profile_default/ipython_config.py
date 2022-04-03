from IPython.terminal.prompts import Prompts
from pygments.token import Token

c.TerminalIPythonApp.display_banner = False
c.InteractiveShell.color_info = True
c.InteractiveShell.colors = "linux"
c.InteractiveShell.sphinxify_docstring = True
c.TerminalInteractiveShell.autoformatter = "black"
c.TerminalInteractiveShell.confirm_exit = False
c.TerminalInteractiveShell.display_completions = "multicolumn"
c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.editor = "/usr/bin/nvim"
c.TerminalInteractiveShell.enable_history_search = True
c.TerminalInteractiveShell.extra_open_editor_shortcuts = True
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.highlighting_style = "native"
c.TerminalInteractiveShell.prompt_includes_vi_mode = True


class MyPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        return [(Token.Prompt, ">> ")]

    def out_prompt_tokens(self, cli=None):
        return [(Token.Prompt, "-> ")]


c.TerminalInteractiveShell.true_color = True
c.Completer.use_jedi = True
c.TerminalInteractiveShell.prompts_class = MyPrompt
