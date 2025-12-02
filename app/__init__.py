#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import os
import platform
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QPalette, QColor
from PyQt6.QtCore import Qt

from app.main import LazyFrameworkGUI

def run_gui():
    """Run the GUI application dengan auto-detect platform"""
    import platform
    # Auto-detect platform backend
    system = platform.system()
    
    if system == "Linux":
        # Cek apakah Wayland available
        wayland_display = os.environ.get('WAYLAND_DISPLAY')
        xdg_desktop = os.environ.get('XDG_CURRENT_DESKTOP', '').lower()
        
        if wayland_display and ('gnome' in xdg_desktop or 'kde' in xdg_desktop or 'mate' in xdg_desktop):
            os.environ['QT_QPA_PLATFORM'] = 'wayland'
            print("Using Wayland backend")
        else:
            os.environ['QT_QPA_PLATFORM'] = 'xcb'
            print("Using XCB backend")
            
    elif system == "Windows":
        os.environ['QT_QPA_PLATFORM'] = 'windows'
        print("Using Windows backend")
        
    elif system == "Darwin":  # macOS
        os.environ['QT_QPA_PLATFORM'] = 'cocoa'
        print("Using macOS Cocoa backend")
    else:
        os.environ['QT_QPA_PLATFORM'] = 'xcb'
        print("Using fallback XCB backend")
    
    # Fix environment variables for WebEngine
    os.environ['QTWEBENGINE_CHROMIUM_FLAGS'] = '--no-sandbox --disable-gpu-sandbox'
    os.environ['QT_QUICK_BACKEND'] = 'software'
    os.environ["LIBGL_ALWAYS_SOFTWARE"] = "1"
    
    # Fix SSL certificates untuk Linux
    if platform.system() == "Linux":
        os.environ['QTWEBENGINE_DISABLE_SANDBOX'] = '1'
        # Coba berbagai path certificate yang umum
        cert_paths = [
            '/etc/ssl/certs/ca-certificates.crt',
            '/etc/ssl/certs/ca-bundle.crt',
            '/etc/pki/tls/certs/ca-bundle.crt'
        ]
        for cert_path in cert_paths:
            if os.path.exists(cert_path):
                os.environ['SSL_CERT_FILE'] = cert_path
                os.environ['REQUESTS_CA_BUNDLE'] = cert_path
                break
    
    app = QApplication(sys.argv)
    app.setApplicationName("LazyFramework GUI")
    app.setApplicationVersion("2.0")

    # Set dark palette
    palette = QPalette()
    palette.setColor(QPalette.ColorRole.Window, QColor(30, 30, 30))
    palette.setColor(QPalette.ColorRole.WindowText, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.Base, QColor(25, 25, 25))
    palette.setColor(QPalette.ColorRole.AlternateBase, QColor(30, 30, 30))
    palette.setColor(QPalette.ColorRole.ToolTipBase, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.ToolTipText, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.Text, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.Button, QColor(45, 45, 45))
    palette.setColor(QPalette.ColorRole.ButtonText, Qt.GlobalColor.white)
    palette.setColor(QPalette.ColorRole.BrightText, Qt.GlobalColor.red)
    palette.setColor(QPalette.ColorRole.Link, QColor(42, 130, 218))
    palette.setColor(QPalette.ColorRole.Highlight, QColor(42, 130, 218))
    palette.setColor(QPalette.ColorRole.HighlightedText, Qt.GlobalColor.black)
    app.setPalette(palette)

    win = LazyFrameworkGUI()
    win.show()

    sys.exit(app.exec())


