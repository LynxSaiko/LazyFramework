# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['gui.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('banner', 'banner'),
        ('modules', 'modules'),
        ('examples', 'examples'),
        ('core', 'core'),
        ('bin', 'bin'),
        # Jika kamu punya file icon
        ('lzf-skull.ico', '.'),           # icon akan ada di root executable
    ],
    hiddenimports=[
        'PyQt6',
        'PyQt6.QtCore',
        'PyQt6.QtGui',
        'PyQt6.QtWidgets',
        'PyQt6.QtWebEngineCore',
        'PyQt6.QtWebEngineWidgets',
        'PyQt6.QtNetwork',
        'rich',
        'rich.console',
        'rich.table',
        'rich.panel',
        'shlex',
        'dataclasses',
        'socket',
        'threading',
        'ctypes',           # kadang dibutuhkan PyQt6 di Windows
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='LazyFramework',           # ← Ganti kalau mau nama lain
    debug=False,
    exclude_binaries=True,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,                       # kompres biar lebih kecil (opsional)
    console=False,                 # False = windowed (GUI tanpa console hitam)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='lzf-skull.ico'            # ← Ganti dengan nama icon kamu (harus ada di folder)
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='LazyFramework'
)
