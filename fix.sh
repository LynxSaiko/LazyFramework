#!/bin/sh
# fix_all_contextlib_fixed.sh

cd /usr/share/lazyframework

echo "=== PERBAIKI SEMUA IMPORTS CONTEXTILIB ==="

# List file yang perlu diperbaiki
FILES="gui/main_window.py gui/core/module_runner.py gui/__init__.py"

for file in $FILES; do
    if [ -f "$file" ]; then
        echo "Memeriksa $file..."
        
        # Backup
        cp "$file" "${file}.backup"
        
        # Periksa apakah menggunakan redirect_stdout/stderr atau contextlib
        if grep -q "redirect_stdout\|redirect_stderr\|contextlib\." "$file"; then
            echo "  ✓ Menggunakan contextlib/redirect"
            
            # Cek apakah import sudah ada
            if ! grep -q "^import contextlib" "$file" && ! grep -q "^from contextlib import" "$file"; then
                echo "  ✗ Import contextlib belum ada, menambahkan..."
                
                # Tambahkan setelah shebang atau di awal
                if grep -q "^#!/usr/bin/env python3" "$file"; then
                    # Setelah shebang
                    sed -i '2a\
import contextlib\
from contextlib import redirect_stdout, redirect_stderr' "$file"
                else
                    # Di awal file
                    sed -i '1a\
import contextlib\
from contextlib import redirect_stdout, redirect_stderr' "$file"
                fi
            else
                echo "  ✓ Import contextlib sudah ada"
            fi
        else
            echo "  ✗ Tidak menggunakan contextlib"
        fi
    else
        echo "  ✗ File $file tidak ditemukan"
    fi
done

# Perbaiki khusus untuk fungsi yang spesifik
echo ""
echo "=== PERBAIKI FUNGSI SPESIFIK ==="

# 1. Fungsi load_selected_module di main_window.py
echo "1. Memperbaiki load_selected_module..."
if grep -q "def load_selected_module" gui/main_window.py; then
    # Tambahkan imports di dalam fungsi jika perlu
    sed -i '/def load_selected_module/,/^    def / {
        /output_buffer = io\.StringIO()/i\
        import contextlib\
        from contextlib import redirect_stdout, redirect_stderr\
        import io
    }' gui/main_window.py
    echo "  ✓ load_selected_module diperbaiki"
fi

# 2. Fungsi execute_command di main_window.py  
echo "2. Memperbaiki execute_command..."
if grep -q "def execute_command" gui/main_window.py; then
    sed -i '/def execute_command/,/^    def / {
        /output_buffer = io\.StringIO()/i\
            import contextlib\
            from contextlib import redirect_stdout, redirect_stderr\
            import io
    }' gui/main_window.py
    echo "  ✓ execute_command diperbaiki"
fi

# 3. Fungsi show_module_info_in_tab di main_window.py
echo "3. Memperbaiki show_module_info_in_tab..."
if grep -q "def show_module_info_in_tab" gui/main_window.py; then
    sed -i '/def show_module_info_in_tab/,/^    def / {
        /output_buffer = io\.StringIO()/i\
        import contextlib\
        from contextlib import redirect_stdout, redirect_stderr\
        import io
    }' gui/main_window.py
    echo "  ✓ show_module_info_in_tab diperbaiki"
fi

# 4. ModuleRunner.run() method
echo "4. Memperbaiki ModuleRunner.run()..."
if grep -q "def run" gui/core/module_runner.py; then
    # Pastikan imports di atas class
    if ! grep -q "^import contextlib" gui/core/module_runner.py; then
        sed -i '1a\
import contextlib\
from contextlib import redirect_stdout, redirect_stderr' gui/core/module_runner.py
    fi
    echo "  ✓ ModuleRunner.run() diperbaiki"
fi

echo ""
echo "=== VERIFIKASI ==="
python3 -c "
import sys
import os
sys.path.insert(0, '.')

print('Testing imports...')

# Test basic imports
try:
    import contextlib
    from contextlib import redirect_stdout, redirect_stderr
    print('✓ contextlib imports OK')
except ImportError as e:
    print(f'✗ contextlib error: {e}')

# Test specific modules
modules_to_test = ['gui.main_window', 'gui.core.module_runner']

for mod in modules_to_test:
    try:
        __import__(mod)
        print(f'✓ {mod} imports OK')
    except ImportError as e:
        print(f'✗ {mod} error: {e}')
    except Exception as e:
        print(f'✗ {mod} other error: {e}')
        import traceback
        traceback.print_exc()

print('\\nDone.')
"

echo ""
echo "=== SELESAI ==="
echo "Coba jalankan: lazyframework"
