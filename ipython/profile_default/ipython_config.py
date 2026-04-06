import os
import sys

from IPython.terminal.prompts import Prompts, Token

c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.highlight_matching_brackets = True


c.InteractiveShellApp.exec_lines = []
c.InteractiveShellApp.exec_lines.append("%load_ext autoreload")
c.InteractiveShellApp.exec_lines.append("%autoreload 2")


class CustomPrompt(Prompts):
    def in_prompt_tokens(self, cli=None):
        python_version = sys.version.split()[0]
        current_directory = os.getcwd()
        virtual_env = os.environ.get("VIRTUAL_ENV", "")
        virtual_env_name = os.path.basename(virtual_env) if virtual_env else ""
        return [
            (Token.PromptNum, ""),
            (Token.Prompt, f"{python_version} "),
            (Token.Prompt, f"({virtual_env_name}) {current_directory}"),
            (Token.Prompt, "\n"),
            (Token.Test, "󰅪 "),
        ]

    def out_prompt_tokens(self):
        return [
            (Token.Prompt, "   "),  # Indentation for output prompt
            (Token.PromptNum, " "),  # Output prompt number
            (Token.Prompt, " "),  # Space after the prompt number
        ]


c.TerminalInteractiveShell.prompts_class = CustomPrompt
