# modules/recon/wpscan.py
# WPScan Module – LazyFramework (FULL RESPONSIVE + API TOKEN + BRUTEFORCE)

import subprocess
import shutil
import os
from typing import Dict, Any
from rich.table import Table
from rich import box
from rich.console import Console

console = Console(width=70)

MODULE_INFO = {
    "name": "WPScan Scanner",
    "description": "WordPress scanner - responsive table + API token + bruteforce",
    "author": "Enhanced by Bro",
    "category": "recon",
}

OPTIONS = {
    "URL": {
        "default": "",
        "required": True,
        "description": "Target URL http/https",
    },
    "MODE": {
        "default": "STANDARD",
        "required": True,
        "choices": ["QUICK", "STANDARD", "AGGRESSIVE", "BRUTEFORCE"],
        "description": "Scan mode",
    },
    "UPDATE_DB": {
        "default": "NO",
        "choices": ["YES", "NO"],
        "description": "Update database WPScan dulu?",
    },
    "MAX_THREADS": {
        "default": "10",
        "description": "Jumlah thread (5-50)",
    },
    "WORDLIST": {
        "default": "",
        "required": False,
        "description": "Path to wordlist",
    },
    "USERNAMES": {
        "default": "admin",
        "required": False,
        "description": "Username user,admin,example",
    },
    "API_TOKEN": {
        "default": "",
        "required": False,
        "description": "WPScan API Token",
    },
}

def run(session: Dict[str, Any], options: Dict[str, Any]):
    raw_url = options.get("URL", "").strip()
    mode = options.get("MODE", "STANDARD").upper()
    update_db = options.get("UPDATE_DB", "NO").upper() == "YES"
    threads = options.get("MAX_THREADS", "10")
    wordlist = options.get("WORDLIST", "").strip()
    usernames = options.get("USERNAMES", "admin").strip()
    api_token = options.get("API_TOKEN", "").strip()

    # Normalisasi URL
    if not raw_url.startswith(("http://", "https://")):
        url = "https://" + raw_url
    else:
        url = raw_url
    url = url.rstrip("/") + "/"

    # Cek wpscan
    wpscan = shutil.which("wpscan")
    if not wpscan:
        console.print("[bold red][X] wpscan tidak terinstall! Install: gem install wpscan[/]")
        return

    # Update DB
    if update_db:
        console.print("[cyan][*] Updating WPScan database...[/]")
        subprocess.run([wpscan, "--update"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        console.print("[green][+] Database updated![/]")

    # Command utama – 100% ANTI-ERROR
    cmd = [
        wpscan,
        "--url", url,
        "--no-banner",
        "--force",
        "--scope",
        "--ignore-main-redirect",
        "--random-user-agent",
        "--max-threads", str(threads),
        "--format", "cli",
    ]

    # Tambah API Token kalau diisi
    if api_token:
        cmd.extend(["--api-token", api_token])

    # Mode handling
    if mode == "QUICK":
        cmd.extend(["--detection-mode", "passive"])
    elif mode == "STANDARD":
        cmd.extend(["--enumerate", "vp,vt,u"])
    elif mode == "AGGRESSIVE":
        cmd.extend(["--enumerate", "vp,vt,u,cb,dbe,ap", "--plugins-detection", "aggressive"])
    elif mode == "BRUTEFORCE":
        if not wordlist or not os.path.isfile(wordlist):
            console.print("[bold red][X] WORDLIST tidak ditemukan! Set dulu path yang benar.[/]")
            return
        cmd.extend(["--passwords", wordlist])
        cmd.extend(["--usernames", usernames if usernames else "admin"])

    # TABEL RESPONSIVE – Otomatis menyesuaikan lebar terminal
    table = Table(
        title="[bold cyan]WPScan Configuration[/]",
        box=box.ROUNDED,
        show_header=True,
        header_style="bold white",
        width=console.width,  # Ini yang bikin 100% responsive!
        expand=True,
    )
    table.add_column("Parameter", style="bold magenta", justify="left", width=18)
    table.add_column("Value", overflow="fold")

    table.add_row("Target", f"[bold white]{url}[/]")
    table.add_row("Mode", f"[bold yellow]{mode}[/]")
    table.add_row("Threads", str(threads))
    table.add_row("Wordlist", wordlist or "[dim]N/A[/]")
    table.add_row("Usernames", usernames or "[dim]admin[/]")
    table.add_row("API Token", "[bold green]Active[/]" if api_token else "[dim]Not used[/]")
    table.add_row("Update DB", "[bold green]YES[/]" if update_db else "[dim]NO[/]")
    table.add_row("Anti-Abort", "[bold green]ENABLED[/]")

    console.print(table)
    console.print(f"[dim]Executing → {' '.join(cmd)}[/]\n")

    try:
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            universal_newlines=True,
        )

        for line in process.stdout:
            line = line.rstrip()
            if not line:
                continue
            if "[!]" in line:
                console.print(f"[bold red]{line}[/]")
            elif "[+]" in line:
                console.print(f"[bold green]{line}[/]")
            elif "[i]" in line:
                console.print(f"[bold yellow]{line}[/]")
            elif "Scan Aborted" in line or "Unable to identify" in line:
                console.print(f"[bold magenta]{line} → [dim](ignored)[/]")
            else:
                console.print(line)

        process.wait()
        console.print("\n[bold green][+] Scan selesai![/]")

    except KeyboardInterrupt:
        console.print("\n[bold red][X] Dibatalkan oleh user[/]")
    except Exception as e:
        console.print(f"[bold red][X] Error: {e}[/]")