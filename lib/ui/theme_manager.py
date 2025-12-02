#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import json
from PyQt6.QtWidgets import *
from PyQt6.QtCore import Qt

class ThemeManager:
    def __init__(self, app, main_window):
        self.app = app
        self.main_window = main_window
        current_dir = os.path.dirname(os.path.abspath(__file__))
        self.theme_path = os.path.join(current_dir, "themes")
        #os.makedirs(self.theme_path, exist_ok=True)  # Auto buat folder kalau gak ada
        
        # Load dari config dulu
        self.current_theme = self._load_from_config("red_team.qss")
        self.load_theme(self.current_theme)

    def _load_from_config(self, default):
        if os.path.exists("config.json"):
            try:
                with open("config.json") as f:
                    config = json.load(f)
                    return config.get("theme", default)
            except:
                pass
        return default

    def _save_to_config(self, theme_name):
        try:
            config = {"theme": theme_name}
            with open("config.json", "w") as f:
                json.dump(config, f)
        except:
            pass

    def load_theme(self, theme_name):
        path = os.path.join(self.theme_path, theme_name)
        
        # Default fallback kalau gagal
        fallback = "QMainWindow { background: #1e1e1e; color: white; }"
        
        if not os.path.exists(path):
            print(f"[-] Theme file not found: {path}")
            self.app.setStyleSheet(fallback)
            self.current_theme = "red_team.qss"  # atau default lain
            self._save_to_config(self.current_theme)
            return

        try:
            # Baca dengan mode binary dulu → deteksi BOM / karakter aneh
            with open(path, "rb") as f:
                raw = f.read()
            
            # Hapus BOM kalau ada
            if raw.startswith(b'\xef\xbb\xbf'):
                raw = raw[3:]
            
            # Decode dengan error handling ketat
            stylesheet = raw.decode('utf-8', errors='replace')
            
            # Validasi sederhana: pastikan jumlah { dan } seimbang
            if stylesheet.count('{') != stylesheet.count('}'):
                raise ValueError("Unbalanced braces in QSS")
            
            # Coba apply dulu ke dummy widget (ini yang bikin aman!)
            dummy = QWidget()
            dummy.setStyleSheet(stylesheet)
            
            # Kalau sampai sini tidak error → aman
            self.app.setStyleSheet(stylesheet)
            self.current_theme = theme_name
            self._save_to_config(theme_name)
            print(f"[+] Theme loaded: {theme_name}")
            
            # Hapus dummy
            dummy.deleteLater()
            
        except Exception as e:
            print(f"[-] Failed to load theme {theme_name}: {e}")
            print("[!] Using fallback dark theme")
            self.app.setStyleSheet(fallback)
            self.current_theme = "red_team.qss"
            self._save_to_config(self.current_theme)

    def create_theme_switcher(self):
        widget = QWidget()
        layout = QHBoxLayout(widget)
        layout.setContentsMargins(10, 5, 10, 5)
        layout.setSpacing(5)

        label = QLabel("🎨 Theme:")
        label.setStyleSheet("color: #00ffff; font-weight: bold; font-size: 11pt;")

        combo = QComboBox()
        combo.addItems([
            "Red Team Mode", "Blue Team Mode", 
            "Matrix Green"
        ])
        
        # Fix mapping
        self.theme_map = {
        
            "Red Team Mode": "red_team.qss",
            "Blue Team Mode": "blue_team.qss",
           
            "Matrix Green": "matrix_green.qss"
        }
        
        # Set current berdasarkan yang lagi load
        current_display = [k for k, v in self.theme_map.items() if v == self.current_theme][0]
        combo.setCurrentText(current_display)
        
        combo.currentTextChanged.connect(lambda text: 
            self.load_theme(self.theme_map.get(text, "red_team.qss"))
        )
        
        layout.addWidget(label)
        layout.addWidget(combo)
        layout.addStretch()
        return widget


# Tambahkan di top file gui.py:
# import faulthandler; faulthandler.enable(all_threads=True)
# import builtins, io, contextlib, signal

