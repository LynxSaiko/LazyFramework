#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import faulthandler
faulthandler.enable(all_threads=True)

from app import run_gui

if __name__ == "__main__":
    run_gui()
