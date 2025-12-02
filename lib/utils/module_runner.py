#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import contextlib
import subprocess
import signal
import threading
from PyQt6.QtCore import QThread, Qt, pyqtSignal
from lib.utils.patched_popen import PatchedPopen
from contextlib import redirect_stdout, redirect_stderr


class ModuleRunner(QThread):
    output = pyqtSignal(str)
    finished = pyqtSignal()

    def __init__(self, framework, module_instance):
        super().__init__()
        self.framework = framework
        self.module_instance = module_instance

        # capture object used with contextlib.redirect_stdout/stderr
        self.capture = UniversalCapture()
        # ensure queued connection so emit from any thread is queued to main
        #self.capture.output_signal.connect(self.output.emit, Qt.QueuedConnection)
        self.capture.output_signal.connect(self.output.emit, Qt.ConnectionType.QueuedConnection)
        self.original_popen = subprocess.Popen
        self.original_system = os.system

        self._stop_flag = False
        self._active = []
        self._lock = threading.Lock()

    def stop(self):
        self._stop_flag = True
        # kill tracked child processes
        with self._lock:
            procs = list(self._active)

        self.output.emit("[yellow]Runner stop requested — terminating children...[/yellow]")

        for p in procs:
            try:
                # polite terminate
                p.terminate()
            except Exception:
                pass
            try:
                p.wait(timeout=0.3)
            except Exception:
                # try kill process group / force kill
                try:
                    if os.name == 'posix' and hasattr(os, "killpg"):
                        os.killpg(os.getpgid(p.pid), signal.SIGKILL)
                    else:
                        p.kill()
                except Exception:
                    try:
                        p.kill()
                    except Exception:
                        pass

        with self._lock:
            self._active.clear()

    def run(self):
        try:
            # Bind patched Popen & system local to this thread's duration
            subprocess.Popen = self._patched_popen
            os.system = self._patched_system

            # Use contextlib.redirect_stdout/stderr to capture prints only for duration of module
            # This reduces window where global stdout is replaced
            try:
                with contextlib.redirect_stdout(self.capture), contextlib.redirect_stderr(self.capture):
                    if not self._stop_flag:
                        # Run module (this runs inside this QThread)
                        self.module_instance.run(self.framework.session)
            except Exception as e:
                # Module-level exceptions => emit to GUI
                self.output.emit(f"[red]Module Error: {e}[/red]")

        except Exception as e:
            self.output.emit(f"[red]Runner fatal error: {e}[/red]")

        finally:
            # restore globals
            try:
                subprocess.Popen = self.original_popen
            except Exception:
                pass
            try:
                os.system = self.original_system
            except Exception:
                pass

            # ensure any leftover procs cleaned
            with self._lock:
                self._active.clear()

            # stop capture (no-op here because redirect already restored)
            try:
                self.capture.flush()
            except Exception:
                pass

            # notify GUI that we're finished
            self.finished.emit()

    def _patched_popen(self, *args, **kwargs):
        # ensure callback present
        kwargs['output_callback'] = self.output.emit

        # preserve user's requested creation flags if any; we already set defaults in PatchedPopen
        try:
            p = PatchedPopen(*args, **kwargs)
        except TypeError:
            # fallback to original Popen if signature mismatch
            p = self.original_popen(*args, **kwargs)

        with self._lock:
            self._active.append(p)
        return p

    def _patched_system(self, cmd):
        # use our patched Popen to execute command
        self.output.emit(f"$ {cmd}")
        p = self._patched_popen(cmd, shell=True)
        try:
            p.wait()
        except Exception:
            pass
        return getattr(p, "returncode", -1)







# === RICH CONSOLE FOR GUI ===
