#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import os
import threading
import signal

class PatchedPopen(subprocess.Popen):
    def __init__(self, *args, **kwargs):
        # pop output_callback if ada (ModuleRunner memberikan)
        self.output_callback = kwargs.pop('output_callback', None)

        # Force capture output (text mode)
        kwargs.setdefault('stdout', subprocess.PIPE)
        kwargs.setdefault('stderr', subprocess.STDOUT)
        kwargs.setdefault('universal_newlines', True)
        kwargs.setdefault('bufsize', 1)

        # Ensure process group created for safe killing
        if os.name == 'posix':
            kwargs.setdefault('preexec_fn', os.setsid)
        else:
            # Windows flag
            kwargs.setdefault('creationflags', getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0x00000200))

        super().__init__(*args, **kwargs)

        # Spawn thread to read stdout (daemon so it won't block exit)
        if self.output_callback and self.stdout:
            self._reader_thread = threading.Thread(target=self._read_output, daemon=True)
            self._reader_thread.start()

    def _read_output(self):
        try:
            # read line by line; stop when stream closed
            for line in iter(self.stdout.readline, ''):
                if not line:
                    break
                try:
                    # callback is expected to be Qt signal emit or similar;
                    # ensure it doesn't raise to this thread
                    self.output_callback(line.rstrip())
                except Exception:
                    pass
        except Exception:
            pass


