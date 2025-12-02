#!/usr/bin/env python3
# -*- coding: utf-8 -*-

class GUIConsole:
    def __init__(self, output_callback):
        self.output_callback = output_callback

    def print(self, *args, **kwargs):
        """Print dengan rich formatting ke GUI"""
        try:
            from io import StringIO
            from rich.console import Console

            with StringIO() as buffer:
                console = Console(file=buffer, force_terminal=False, width=120)
                console.print(*args, **kwargs)
                output = buffer.getvalue()
                if output.strip():
                    # Clean ANSI sequences
                    #clean_output = re.sub(r'\x1b\[[0-9;]*[mG]', '', output)
                    self.output_callback(output)
        except Exception as e:
            self.output_callback(f"Console error: {e}")

# === RICH CONSOLE FOR GUI ===
