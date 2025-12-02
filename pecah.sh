#!/bin/sh
# split_gui_proper.sh

echo "=== SPLIT GUI.PY - STRUKTUR PROPER ==="

# Backup
cp gui.py gui.py.backup

# Buat struktur folder DULU
echo "Membuat struktur folder..."
mkdir -p app
mkdir -p lib/ui lib/utils lib/widgets lib/dialogs

# Buat __init__.py
echo "Membuat __init__.py files..."
echo "# Package app" > app/__init__.py
echo "# Package lib" > lib/__init__.py
echo "# Package ui" > lib/ui/__init__.py
echo "# Package utils" > lib/utils/__init__.py
echo "# Package widgets" > lib/widgets/__init__.py
echo "# Package dialogs" > lib/dialogs/__init__.py

# Gunakan Python untuk ekstraksi
python3 << 'EOF'
import re
import os
import sys

print("Memisahkan kelas-kelas...")

# Baca file
with open('gui.py.backup', 'r') as f:
    content = f.read()

# Fungsi ekstrak kelas
def extract_class(class_name):
    pattern = rf'^class {class_name}.*?(?=^class|\Z)'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    return match.group(0) if match else None

# 1. ThemeManager
print("1. ThemeManager...")
theme = extract_class('ThemeManager')
if theme:
    with open('lib/ui/theme_manager.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
from PyQt6.QtWidgets import *
from PyQt6.QtCore import Qt

''')
        f.write(theme)
    print('   -> lib/ui/theme_manager.py')

# 2. UniversalCapture
print("2. UniversalCapture...")
universal = extract_class('UniversalCapture')
if universal:
    with open('lib/utils/capture.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import threading
import io
from PyQt6.QtCore import QObject, pyqtSignal

''')
        f.write(universal)
    print('   -> lib/utils/capture.py')

# 3. PatchedPopen
print("3. PatchedPopen...")
patched = extract_class('PatchedPopen')
if patched:
    with open('lib/utils/patched_popen.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import os
import threading
import signal

''')
        f.write(patched)
    print('   -> lib/utils/patched_popen.py')

# 4. ModuleRunner
print("4. ModuleRunner...")
module = extract_class('ModuleRunner')
if module:
    with open('lib/utils/module_runner.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
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


''')
        f.write(module)
    print('   -> lib/utils/module_runner.py')

# 5. GUIConsole (hanya pertama)
print("5. GUIConsole...")
console_match = re.search(r'^class GUIConsole:.*?(?=^class GUIConsole:|^class|\Z)', content, re.MULTILINE | re.DOTALL)
if console_match:
    with open('lib/widgets/console.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

''')
        f.write(console_match.group(0))
    print('   -> lib/widgets/console.py')

# 6. ProxySettingsDialog
print("6. ProxySettingsDialog...")
proxy = extract_class('ProxySettingsDialog')
if proxy:
    with open('lib/dialogs/proxy_dialog.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from PyQt6.QtWidgets import *
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QIntValidator

''')
        f.write(proxy)
    print('   -> lib/dialogs/proxy_dialog.py')

# 7. LazyFrameworkGUI
print("7. LazyFrameworkGUI...")
lazy_match = re.search(r'^class LazyFrameworkGUI.*?(?=^def run_gui\(\):)', content, re.MULTILINE | re.DOTALL)
if lazy_match:
    with open('app/main.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import time
import random
import re
import threading
import contextlib
import socket
import platform
import subprocess
import io
from datetime import datetime
from io import StringIO

from PyQt6.QtWidgets import *
from PyQt6.QtCore import *
from PyQt6.QtGui import *
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineSettings
from PyQt6.QtNetwork import QNetworkProxy

# Framework imports
from bin.console import LazyFramework
from core import load_banners_from_folder, get_random_banner
#from modules.payloads.reverse.reverse_tcp import send_command_to_session

# Library imports
from lib.ui.theme_manager import ThemeManager
from lib.utils.capture import UniversalCapture
from lib.utils.module_runner import ModuleRunner
from lib.widgets.console import GUIConsole
from lib.dialogs.proxy_dialog import ProxySettingsDialog
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(current_dir)
if project_root not in sys.path:
    sys.path.insert(0, project_root)

''')
        f.write(lazy_match.group(0))
    print('   -> app/main.py')

# 8. run_gui
print("8. run_gui...")
run_match = re.search(r'^def run_gui\(\):.*?(?=^if __name__)', content, re.MULTILINE | re.DOTALL)
if run_match:
    with open('app/__init__.py', 'w') as f:
        f.write('''#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import platform
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QPalette, QColor
from PyQt6.QtCore import Qt

from app.main import LazyFrameworkGUI

''')
        f.write(run_match.group(0))
    print('   -> app/__init__.py')

print("\\nSemua kelas berhasil dipisahkan!")
EOF

# 9. Buat gui.py baru
echo "Membuat entry point baru..."
cat > gui.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import faulthandler
faulthandler.enable(all_threads=True)

from app import run_gui

if __name__ == "__main__":
    run_gui()
EOF

echo ""
echo "=== STRUKTUR YANG DIBUAT ==="
find app lib -name "*.py" | sort

echo ""
echo "=== TEST IMPORTS ==="
python3 -c "
import sys
import os
sys.path.insert(0, '.')

print('Testing library imports...')

test_imports = [
    ('lib.ui.theme_manager', 'ThemeManager'),
    ('lib.utils.capture', 'UniversalCapture'),
    ('lib.utils.patched_popen', 'PatchedPopen'),
    ('lib.utils.module_runner', 'ModuleRunner'),
    ('lib.widgets.console', 'GUIConsole'),
    ('lib.dialogs.proxy_dialog', 'ProxySettingsDialog'),
]

for module_name, class_name in test_imports:
    try:
        module = __import__(module_name, fromlist=[class_name])
        print(f'✓ {module_name}.{class_name}')
    except Exception as e:
        print(f'✗ {module_name}.{class_name}: {e}')

print('\\nTesting app import...')
try:
    from app import run_gui
    print('✓ app.run_gui OK')
except Exception as e:
    print(f'✗ app.run_gui: {e}')
    import traceback
    traceback.print_exc()
"

echo ""
echo "=== SELESAI ==="
echo "Struktur:"
echo "├── gui.py          # Entry point"
echo "├── app/"
echo "│   ├── __init__.py # run_gui()"
echo "│   └── main.py     # Main window"
echo "└── lib/"
echo "    ├── ui/         # UI components"
echo "    ├── utils/      # Utilities"
echo "    ├── widgets/    # Widgets"
echo "    └── dialogs/    # Dialogs"
echo ""
echo "Jalankan: python gui.py"
