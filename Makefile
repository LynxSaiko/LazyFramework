# ===========================================================================
# ██╗      █████╗ ███████╗██╗   ██╗    ███████╗██████╗  █████╗ ███╗   ███╗
# ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝    ██╔════╝██╔══██╗██╔══██╗████╗ ████║
# ██║     ███████║  ███╔╝  ╚████╔╝     █████╗  ██████╔╝███████║██╔████╔██║
# ██║     ██╔══██║ ███╔╝    ╚██╔╝      ██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║
# ███████╗██║  ██║███████╗   ██║       ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║
# ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
# 
#                   P E N T E S T I N G   F R A M E W O R K
#                           Version: 2.6.0
# ===========================================================================

# Configuration
NAME            := lazyframework
VERSION         := 2.6.0
AUTHOR          := LazyHackers
LICENSE         := GPLv3

# ANSI Color Codes
RESET   := \033[0m
BOLD    := \033[1m
RED     := \033[31m
GREEN   := \033[32m
YELLOW  := \033[33m
BLUE    := \033[34m
MAGENTA := \033[35m
CYAN    := \033[36m
WHITE   := \033[37m
BLACK   := \033[30m
BRIGHT_RED    := \033[91m
BRIGHT_GREEN  := \033[92m
BRIGHT_YELLOW := \033[93m
BRIGHT_BLUE   := \033[94m
BRIGHT_MAGENTA:= \033[95m
BRIGHT_CYAN   := \033[96m

# Background Colors
BG_BLACK   := \033[40m
BG_RED     := \033[41m
BG_GREEN   := \033[42m
BG_YELLOW  := \033[43m
BG_BLUE    := \033[44m
BG_MAGENTA := \033[45m
BG_CYAN    := \033[46m
BG_WHITE   := \033[47m

# System Detection
UNAME_S := $(shell uname -s)
TERMUX_PREFIX := $(shell echo $$PREFIX 2>/dev/null)

# Detect if running on Termux
ifeq ($(UNAME_S),Linux)
    ifeq ($(TERMUX_PREFIX),/data/data/com.termux/files/usr)
        IS_TERMUX    := 1
        DISTRO_NAME  := Termux
        INSTALL_DIR  := /data/data/com.termux/files/home/$(NAME)
        BIN_DIR      := /data/data/com.termux/files/usr/bin
        DESKTOP_DIR  := $(HOME)/.local/share/applications
        ICON_DIR     := $(HOME)/.local/share/icons/hicolor/scalable/apps
        PIP_CMD      := pip
        NEED_SUDO    := 0
    else
        IS_TERMUX    := 0
        DISTRO_NAME  := $(shell lsb_release -si 2>/dev/null || uname -s)
        INSTALL_DIR  := /usr/share/$(NAME)
        BIN_DIR      := /usr/bin
        DESKTOP_DIR  := /usr/share/applications
        ICON_DIR     := /usr/share/icons/hicolor/scalable/apps
        PIP_CMD      := pip3
        NEED_SUDO    := 1
    endif
else
    IS_TERMUX    := 0
    DISTRO_NAME  := $(UNAME_S)
    INSTALL_DIR  := /usr/local/share/$(NAME)
    BIN_DIR      := /usr/local/bin
    DESKTOP_DIR  := /usr/local/share/applications
    ICON_DIR     := /usr/local/share/icons/hicolor/scalable/apps
    PIP_CMD      := pip3
    NEED_SUDO    := 1
endif

.PHONY: all install uninstall clean info help banner check

# ===========================================================================
# METASPLOIT-STYLE BANNER
# ===========================================================================
banner:
	@clear 2>/dev/null || true
	@printf "${BRIGHT_RED}"
	@echo "                      ______"
	@echo "                   .-\"      \"-."
	@echo "                  /            \\"
	@echo "${BRIGHT_YELLOW}     ${BRIGHT_RED}.${BRIGHT_YELLOW}           ${BRIGHT_RED}|${BRIGHT_YELLOW},  ${BRIGHT_RED}.${BRIGHT_YELLOW}-.${BRIGHT_RED}.${BRIGHT_YELLOW} ,${BRIGHT_RED}|${BRIGHT_YELLOW}           ${BRIGHT_RED}.${RESET}"
	@echo "${BRIGHT_YELLOW}     |           |${BRIGHT_RED}(${BRIGHT_YELLOW} ${BRIGHT_RED}.${BRIGHT_YELLOW}_${BRIGHT_RED}.${BRIGHT_YELLOW} )${BRIGHT_RED}|${BRIGHT_YELLOW}           |${RESET}"
	@echo "${BRIGHT_YELLOW}  ,  |           |${BRIGHT_RED}/${BRIGHT_YELLOW}  ${BRIGHT_RED}|  ${BRIGHT_YELLOW}\\${BRIGHT_RED}|${BRIGHT_YELLOW}           |  .${RESET}"
	@echo "${BRIGHT_YELLOW}  |\\-'           |${BRIGHT_RED}\`${BRIGHT_YELLOW}-'${BRIGHT_RED}|${BRIGHT_YELLOW}\`${BRIGHT_RED}|${BRIGHT_YELLOW}           \`-'|${RESET}"
	@echo "${BRIGHT_YELLOW}   \\             |${BRIGHT_RED}'${BRIGHT_YELLOW}---'${BRIGHT_RED}'${BRIGHT_YELLOW}|             /${RESET}"
	@echo "${BRIGHT_YELLOW}    \\           /'${BRIGHT_RED}.${BRIGHT_YELLOW}---${BRIGHT_RED}.${BRIGHT_YELLOW}\`\\           /${RESET}"
	@echo "${BRIGHT_YELLOW}     \\        /'${BRIGHT_RED}'${BRIGHT_YELLOW}---${BRIGHT_RED}'${BRIGHT_YELLOW}\`\`\\        /${RESET}"
	@echo "${BRIGHT_YELLOW}      \`\\    /\`${BRIGHT_RED}'${BRIGHT_YELLOW}---${BRIGHT_RED}'${BRIGHT_YELLOW}\`\`\`\\    /\`${RESET}"
	@echo "${BRIGHT_YELLOW}        \`\\/\`${BRIGHT_RED}'${BRIGHT_YELLOW}---${BRIGHT_RED}'${BRIGHT_YELLOW}\`\`\`\`\\/\`${RESET}"
	@printf "${BRIGHT_RED}"
	@echo "         =[ ${BRIGHT_YELLOW}lazyframework ${BRIGHT_RED}v$(VERSION)                    ]="
	@echo ""
	@printf "${BRIGHT_YELLOW}"
	@echo "    + -- --=[ ${BRIGHT_RED}$(VERSION) modules loaded${BRIGHT_YELLOW}                    ]"
	@echo "    + -- --=[ ${BRIGHT_RED}Pentesting Framework${BRIGHT_YELLOW}                        ]"
	@echo "    + -- --=[ ${BRIGHT_RED}Type 'help' for help menu${BRIGHT_YELLOW}                   ]"
	@echo ""
	@printf "${RESET}"

# ===========================================================================
# SETOOLKIT-STYLE HEADER
# ===========================================================================
header:
	@printf "${BRIGHT_CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}                                                                                ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}▄████████████████▄${RESET}   ${BRIGHT_YELLOW}██████╗ ███████╗███████╗████████╗ ${BRIGHT_RED}▄██████████████▄${RESET}   ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}██               ██${RESET}  ${BRIGHT_YELLOW}██╔══██╗██╔════╝██╔════╝╚══██╔══╝${BRIGHT_RED}██               ██${RESET}  ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}██   ${BRIGHT_YELLOW}▄███▄${BRIGHT_RED}   ██${RESET}  ${BRIGHT_YELLOW}██████╔╝█████╗  ███████╗   ██║   ${BRIGHT_RED}██   ${BRIGHT_YELLOW}▄████▄${BRIGHT_RED}   ██${RESET}  ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}██   ${BRIGHT_YELLOW}▀▀▀▀▀${BRIGHT_RED}   ██${RESET}  ${BRIGHT_YELLOW}██╔══██╗██╔══╝  ╚════██║   ██║   ${BRIGHT_RED}██   ${BRIGHT_YELLOW}▀▀▀▀▀${BRIGHT_RED}   ██${RESET}  ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}██               ██${RESET}  ${BRIGHT_YELLOW}██║  ██║███████╗███████╗   ██║   ${BRIGHT_RED}██               ██${RESET}  ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_RED}▀████████████████▀${RESET}   ${BRIGHT_YELLOW}╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ${BRIGHT_RED}▀██████████████▀${RESET}   ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}                                                                                ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}     ${BRIGHT_GREEN}╦  ╦╔═╗╦╔╦╗  ╔═╗╔═╗╔╦╗╔═╗╔╗╔╔╦╗╔═╗╔╦╗╦╔═╗╔╗╔╔═╗╦═╗${RESET}              ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}     ${BRIGHT_GREEN}║  ║╠═╣║ ║║  ║  ║ ║║║║╠═╣║║║ ║ ╠═╣ ║ ║║ ║║║║║╣ ╠╦╝${RESET}              ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}     ${BRIGHT_GREEN}╩═╝╩╩ ╩╩═╩╝  ╚═╝╚═╝╩ ╩╩ ╩╝╚╝ ╩ ╩ ╩ ╩ ╩╚═╝╝╚╝╚═╝╩╚═${RESET}              ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}                                                                                ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_MAGENTA}[${BRIGHT_YELLOW}*${BRIGHT_MAGENTA}]${RESET} ${BRIGHT_WHITE}Framework   ${BRIGHT_CYAN}:${RESET} ${BRIGHT_YELLOW}LazyFramework ${BRIGHT_RED}v$(VERSION)${RESET}                       ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_MAGENTA}[${BRIGHT_YELLOW}*${BRIGHT_MAGENTA}]${RESET} ${BRIGHT_WHITE}Platform    ${BRIGHT_CYAN}:${RESET} ${BRIGHT_GREEN}$(DISTRO_NAME)${RESET}                                   ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_MAGENTA}[${BRIGHT_YELLOW}*${BRIGHT_MAGENTA}]${RESET} ${BRIGHT_WHITE}Install Dir ${BRIGHT_CYAN}:${RESET} ${BRIGHT_BLUE}$(INSTALL_DIR)${RESET}                      ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}  ${BRIGHT_MAGENTA}[${BRIGHT_YELLOW}*${BRIGHT_MAGENTA}]${RESET} ${BRIGHT_WHITE}Modules     ${BRIGHT_CYAN}:${RESET} ${BRIGHT_YELLOW}15 Exploits ${BRIGHT_CYAN}|${RESET} ${BRIGHT_GREEN}8 Payloads ${BRIGHT_CYAN}|${RESET} ${BRIGHT_MAGENTA}12 Tools${RESET}     ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}║${RESET}                                                                                ${BRIGHT_CYAN}║${RESET}\n"
	@printf "${BRIGHT_CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${RESET}\n"
	@echo ""

# ===========================================================================
# INSTALLATION FLOW
# ===========================================================================
all: banner header check install

check:
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}System detection...${RESET}\n"
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Platform:${RESET} ${BRIGHT_CYAN}$(DISTRO_NAME)${RESET} "
	@if [ $(IS_TERMUX) -eq 1 ]; then \
		printf "${BRIGHT_YELLOW}(Termux)${RESET}\n"; \
	else \
		printf "${BRIGHT_BLUE}(Linux)${RESET}\n"; \
	fi
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Installation directory:${RESET} ${BRIGHT_BLUE}$(INSTALL_DIR)${RESET}\n"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		printf "${BRIGHT_YELLOW}[${BRIGHT_RED}!${BRIGHT_YELLOW}]${RESET} ${BRIGHT_RED}Root privileges required${RESET}\n"; \
	else \
		printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}No root required${RESET}\n"; \
	fi
	@echo ""

install: install-deps install-binary install-console install-desktop install-icon finish

# ===========================================================================
# INSTALLATION STEPS (METASPLOIT STYLE)
# ===========================================================================
install-deps:
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Installing dependencies...${RESET}\n"
	@printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Updating pip...${RESET}"
	#@$(PIP_CMD) install --upgrade pip > /dev/null 2>&1
	@printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"
	@printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Installing Python packages...${RESET}"
	@$(PIP_CMD) install rich PyQt6 PyQt6-WebEngine stem requests --break-system-packages > /dev/null 2>&1
	@printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Dependencies installed successfully${RESET}\n"
	@echo ""

install-binary:
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Installing framework binaries...${RESET}\n"
	@# Create directory
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating directory ${BRIGHT_BLUE}$(INSTALL_DIR)${RESET}"; \
		sudo mkdir -p "$(INSTALL_DIR)" 2>/dev/null || mkdir -p "$(INSTALL_DIR)"; \
		printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
	else \
		printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating directory ${BRIGHT_BLUE}$(INSTALL_DIR)${RESET}"; \
		mkdir -p "$(INSTALL_DIR)"; \
		printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
	fi
	
	@# Copy files
	@printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Copying framework files...${RESET}"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		sudo cp -r *.py "$(INSTALL_DIR)/" 2>/dev/null || true; \
		for dir in bin modules app core lib themes; do \
			if [ -d "$$dir" ]; then \
				sudo cp -r "$$dir" "$(INSTALL_DIR)/" 2>/dev/null || true; \
			fi; \
		done; \
		if [ -f "lzfconsole" ]; then \
			sudo cp lzfconsole "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
	else \
		cp -r *.py "$(INSTALL_DIR)/" 2>/dev/null || true; \
		for dir in bin modules app core lib themes; do \
			if [ -d "$$dir" ]; then \
				cp -r "$$dir" "$(INSTALL_DIR)/" 2>/dev/null || true; \
			fi; \
		done; \
		if [ -f "lzfconsole" ]; then \
			cp lzfconsole "$(INSTALL_DIR)/" 2>/dev/null || true; \
		fi; \
	fi
	@printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"
	
	@# Create launcher
	@printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating launcher...${RESET}"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		sudo mkdir -p "$(BIN_DIR)"; \
		echo '#!/bin/bash' | sudo tee "$(BIN_DIR)/lazyframework" > /dev/null; \
		echo 'cd "$(INSTALL_DIR)"' | sudo tee -a "$(BIN_DIR)/lazyframework" > /dev/null; \
		echo 'exec python3 lzfconsole --gui "$$@"' | sudo tee -a "$(BIN_DIR)/lazyframework" > /dev/null; \
		sudo chmod +x "$(BIN_DIR)/lazyframework"; \
	else \
		mkdir -p "$(BIN_DIR)"; \
		echo '#!/bin/bash' > "$(BIN_DIR)/lazyframework"; \
		echo 'cd "$(INSTALL_DIR)"' >> "$(BIN_DIR)/lazyframework"; \
		echo 'exec python3 lzfconsole --gui "$$@"' >> "$(BIN_DIR)/lazyframework"; \
		chmod +x "$(BIN_DIR)/lazyframework"; \
	fi
	@printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Framework binaries installed${RESET}\n"
	@echo ""

install-console:
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Installing console launcher...${RESET}\n"
	@if [ $(NEED_SUDO) -eq 1 ]; then \
		if [ -f "lzfconsole" ]; then \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Copying lzfconsole to ${BRIGHT_BLUE}$(BIN_DIR)${RESET}"; \
			sudo cp lzfconsole "$(BIN_DIR)/" 2>/dev/null || true; \
			sudo chmod +x "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		fi; \
	else \
		if [ -f "lzfconsole" ]; then \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Copying lzfconsole to ${BRIGHT_BLUE}$(BIN_DIR)${RESET}"; \
			cp lzfconsole "$(BIN_DIR)/" 2>/dev/null || true; \
			chmod +x "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		fi; \
	fi
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Console launcher installed${RESET}\n"
	@echo ""

install-desktop:
	@if [ $(IS_TERMUX) -eq 0 ]; then \
		printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Installing desktop entry...${RESET}\n"; \
		if [ $(NEED_SUDO) -eq 1 ]; then \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating desktop file${RESET}"; \
			sudo mkdir -p "$(DESKTOP_DIR)"; \
			sudo sh -c 'echo "[Desktop Entry]" > "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Version=1.0" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Type=Application" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Name=LazyFramework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "GenericName=Penetration Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Comment=Professional Security Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Exec=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Icon=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Categories=Utility;Security;Development;" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "Terminal=false" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "StartupNotify=true" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo sh -c 'echo "StartupWMClass=LazyFrameworkGUI" >> "$(DESKTOP_DIR)/lazyframework.desktop"'; \
			sudo chmod 644 "$(DESKTOP_DIR)/lazyframework.desktop"; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		else \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating desktop file${RESET}"; \
			mkdir -p "$(DESKTOP_DIR)"; \
			echo "[Desktop Entry]" > "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Version=1.0" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Type=Application" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Name=LazyFramework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "GenericName=Penetration Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Comment=Professional Security Testing Framework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Exec=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Icon=lazyframework" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Categories=Utility;Security;Development;" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "Terminal=false" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "StartupNotify=true" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			echo "StartupWMClass=LazyFrameworkGUI" >> "$(DESKTOP_DIR)/lazyframework.desktop"; \
			chmod 644 "$(DESKTOP_DIR)/lazyframework.desktop"; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		fi; \
		printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Desktop entry installed${RESET}\n"; \
		echo ""; \
	fi

install-icon:
	@if [ $(IS_TERMUX) -eq 0 ]; then \
		printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Installing application icon...${RESET}\n"; \
		if [ $(NEED_SUDO) -eq 1 ]; then \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating SVG icon${RESET}"; \
			sudo mkdir -p "$(ICON_DIR)"; \
			sudo sh -c 'echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<svg width=\"256\" height=\"256\" viewBox=\"0 0 256 256\" xmlns=\"http://www.w3.org/2000/svg\">" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<rect width=\"256\" height=\"256\" fill=\"#0d1117\" rx=\"30\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<rect x=\"28\" y=\"28\" width=\"200\" height=\"200\" fill=\"#161b22\" rx=\"15\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<text x=\"128\" y=\"105\" text-anchor=\"middle\" font-family=\"Arial, sans-serif\" font-size=\"36\" font-weight=\"bold\" fill=\"#50fa7b\">LF</text>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<text x=\"128\" y=\"145\" text-anchor=\"middle\" font-family=\"Arial, sans-serif\" font-size=\"18\" fill=\"#8be9fd\">Framework</text>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "<path d=\"M60 170 H196 M60 185 H180 M60 200 H160\" stroke=\"#6272a4\" stroke-width=\"4\" stroke-linecap=\"round\"/>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			sudo sh -c 'echo "</svg>" >> "$(ICON_DIR)/lazyframework.svg"'; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		else \
			printf "    ${BRIGHT_YELLOW}[${BRIGHT_BLUE}→${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Creating SVG icon${RESET}"; \
			mkdir -p "$(ICON_DIR)"; \
			echo '<?xml version="1.0" encoding="UTF-8"?>' > "$(ICON_DIR)/lazyframework.svg"; \
			echo '<svg width="256" height="256" viewBox="0 0 256 256" xmlns="http://www.w3.org/2000/svg">' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<rect width="256" height="256" fill="#0d1117" rx="30"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<rect x="28" y="28" width="200" height="200" fill="#161b22" rx="15"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<text x="128" y="105" text-anchor="middle" font-family="Arial, sans-serif" font-size="36" font-weight="bold" fill="#50fa7b">LF</text>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<text x="128" y="145" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="#8be9fd">Framework</text>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '<path d="M60 170 H196 M60 185 H180 M60 200 H160" stroke="#6272a4" stroke-width="4" stroke-linecap="round"/>' >> "$(ICON_DIR)/lazyframework.svg"; \
			echo '</svg>' >> "$(ICON_DIR)/lazyframework.svg"; \
			printf " ${BRIGHT_GREEN}[DONE]${RESET}\n"; \
		fi; \
		printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Icon installed${RESET}\n"; \
		echo ""; \
	fi

finish:
	@sleep 0.5
	@printf "${BRIGHT_GREEN}"
	@echo "   ▄████████    ▄████████    ▄████████    ▄████████ "
	@echo "  ███    ███   ███    ███   ███    ███   ███    ███ "
	@echo "  ███    ███   ███    ███   ███    █▀    ███    █▀  "
	@echo "  ███    ███  ▄███▄▄▄▄██▀  ▄███▄▄▄       ███        "
	@echo "▀███████████ ▀▀███▀▀▀▀▀   ▀▀███▀▀▀     ▀███████████ "
	@echo "  ███    ███ ▀███████████   ███    █▄           ███ "
	@echo "  ███    ███   ███    ███   ███    ███    ▄█    ███ "
	@echo "  ███    █▀    ███    ███   ██████████  ▄████████▀  "
	@echo "               ███    ███                           "
	@printf "${RESET}"
	@echo ""
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}LazyFramework ${BRIGHT_RED}v$(VERSION) ${BRIGHT_GREEN}installation complete!${RESET}\n"
	@echo ""
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Launch the framework:${RESET}\n"
	@printf "    ${BRIGHT_YELLOW}└─${BRIGHT_CYAN} ${BRIGHT_GREEN}lazyframework${RESET}   ${BRIGHT_WHITE}→ GUI interface (recommended)${RESET}\n"
	@printf "    ${BRIGHT_YELLOW}└─${BRIGHT_CYAN} ${BRIGHT_GREEN}lzfconsole${RESET}      ${BRIGHT_WHITE}→ Console interface${RESET}\n"
	@echo ""
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}!${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Need help? Type:${RESET} ${BRIGHT_GREEN}lazyframework --help${RESET}\n"
	@echo ""

# ===========================================================================
# UNINSTALL (SETOOLKIT STYLE)
# ===========================================================================
uninstall:
	@printf "${BRIGHT_RED}"
	@echo "   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄▄▄▄▄▄▄▄▄▄▄ "
	@echo "  ▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌"
	@echo "  ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░▌           ▀▀▀▀█░█▀▀▀▀ "
	@echo "  ▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌               ▐░▌     ▐░▌               ▐░▌     "
	@echo "  ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌               ▐░▌     ▐░▌               ▐░▌     "
	@echo "  ▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌▐░▌               ▐░▌     ▐░▌               ▐░▌     "
	@echo "   ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌               ▐░▌     ▐░▌               ▐░▌     "
	@echo "            ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌               ▐░▌     ▐░▌               ▐░▌     "
	@echo "   ▄▄▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄  ▄▄▄▄█░█▄▄▄▄ "
	@echo "  ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌"
	@echo "   ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀       ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ "
	@printf "${RESET}"
	@echo ""
	@printf "${BRIGHT_RED}[${BRIGHT_YELLOW}!${BRIGHT_RED}]${RESET} ${BRIGHT_WHITE}WARNING: This will remove LazyFramework completely!${RESET}\n"
	@echo ""
	@printf "${BRIGHT_YELLOW}[${BRIGHT_RED}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Files to be removed:${RESET}\n"
	@printf "    ${BRIGHT_RED}├─${RESET} ${BRIGHT_BLUE}$(INSTALL_DIR)${RESET}\n"
	@printf "    ${BRIGHT_RED}├─${RESET} ${BRIGHT_BLUE}$(BIN_DIR)/lazyframework${RESET}\n"
	@printf "    ${BRIGHT_RED}├─${RESET} ${BRIGHT_BLUE}$(BIN_DIR)/lzfconsole${RESET}\n"
	@if [ $(IS_TERMUX) -eq 0 ]; then \
		printf "    ${BRIGHT_RED}├─${RESET} ${BRIGHT_BLUE}$(DESKTOP_DIR)/lazyframework.desktop${RESET}\n"; \
		printf "    ${BRIGHT_RED}└─${RESET} ${BRIGHT_BLUE}$(ICON_DIR)/lazyframework.svg${RESET}\n"; \
	fi
	@echo ""
	@printf "${BRIGHT_YELLOW}[${BRIGHT_RED}?${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Are you sure you want to continue? [y/N] ${RESET}"
	@read -p "" choice; \
	if [ "$$choice" = "y" ] || [ "$$choice" = "Y" ]; then \
		echo ""; \
		printf "${BRIGHT_YELLOW}[${BRIGHT_RED}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Removing LazyFramework...${RESET}\n"; \
		if [ $(NEED_SUDO) -eq 1 ]; then \
			sudo rm -rf "$(INSTALL_DIR)" 2>/dev/null || true; \
			sudo rm -f "$(BIN_DIR)/lazyframework" "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
			if [ $(IS_TERMUX) -eq 0 ]; then \
				sudo rm -f "$(DESKTOP_DIR)/lazyframework.desktop" 2>/dev/null || true; \
				sudo rm -f "$(ICON_DIR)/lazyframework.svg" 2>/dev/null || true; \
			fi; \
		else \
			rm -rf "$(INSTALL_DIR)" 2>/dev/null || true; \
			rm -f "$(BIN_DIR)/lazyframework" "$(BIN_DIR)/lzfconsole" 2>/dev/null || true; \
			if [ $(IS_TERMUX) -eq 0 ]; then \
				rm -f "$(DESKTOP_DIR)/lazyframework.desktop" 2>/dev/null || true; \
				rm -f "$(ICON_DIR)/lazyframework.svg" 2>/dev/null || true; \
			fi; \
		fi; \
		printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}LazyFramework has been uninstalled!${RESET}\n"; \
	else \
		echo ""; \
		printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_CYAN}Uninstallation cancelled.${RESET}\n"; \
	fi
	@echo ""

# ===========================================================================
# UTILITIES
# ===========================================================================
clean:
	@printf "${BRIGHT_YELLOW}[${BRIGHT_CYAN}*${BRIGHT_YELLOW}]${RESET} ${BRIGHT_WHITE}Cleaning temporary files...${RESET}\n"
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@printf "${BRIGHT_YELLOW}[${BRIGHT_GREEN}+${BRIGHT_YELLOW}]${RESET} ${BRIGHT_GREEN}Cleanup complete!${RESET}\n"
	@echo ""

info:
	@printf "${BRIGHT_CYAN}"
	@echo "    ╔══════════════════════════════════════════════════════════╗"
	@echo "    ║                    ${BRIGHT_YELLOW}SYSTEM INFORMATION${BRIGHT_CYAN}                    ║"
	@echo "    ╠══════════════════════════════════════════════════════════╣"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Framework${BRIGHT_CYAN}:${RESET} ${BRIGHT_GREEN}LazyFramework ${BRIGHT_RED}v$(VERSION)${BRIGHT_CYAN}                     ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Platform${BRIGHT_CYAN}:${RESET} ${BRIGHT_BLUE}$(DISTRO_NAME)${BRIGHT_CYAN}                               ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Install Dir${BRIGHT_CYAN}:${RESET} ${BRIGHT_YELLOW}$(INSTALL_DIR)${BRIGHT_CYAN}                 ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Bin Dir${BRIGHT_CYAN}:${RESET} ${BRIGHT_YELLOW}$(BIN_DIR)${BRIGHT_CYAN}                           ║\n"
	@printf "${BRIGHT_CYAN}    ║                                                    ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Available Commands:${BRIGHT_CYAN}                              ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_GREEN}lazyframework${BRIGHT_CYAN}  - GUI interface                    ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_GREEN}lzfconsole${BRIGHT_CYAN}     - Console interface               ║\n"
	@printf "${BRIGHT_CYAN}    ║                                                    ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_WHITE}Make Commands:${BRIGHT_CYAN}                                  ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_YELLOW}make install${BRIGHT_CYAN}   - Install framework              ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_YELLOW}make uninstall${BRIGHT_CYAN} - Remove framework               ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_YELLOW}make clean${BRIGHT_CYAN}     - Clean temporary files         ║\n"
	@printf "${BRIGHT_CYAN}    ║  ${BRIGHT_YELLOW}make info${BRIGHT_CYAN}      - Show this information         ║\n"
	@printf "${BRIGHT_CYAN}    ╚══════════════════════════════════════════════════════════╝\n"
	@printf "${RESET}"
	@echo ""

help:
	@make info

# Test colors
test-colors:
	@printf "${BRIGHT_RED}BRIGHT_RED ${BRIGHT_GREEN}BRIGHT_GREEN ${BRIGHT_YELLOW}BRIGHT_YELLOW ${BRIGHT_BLUE}BRIGHT_BLUE ${BRIGHT_MAGENTA}BRIGHT_MAGENTA ${BRIGHT_CYAN}BRIGHT_CYAN${RESET}\n"
	@printf "${RED}RED ${GREEN}GREEN ${YELLOW}YELLOW ${BLUE}BLUE ${MAGENTA}MAGENTA ${CYAN}CYAN${RESET}\n"
	@printf "${BG_RED}${WHITE}BG_RED ${BG_GREEN}${BLACK}BG_GREEN ${BG_YELLOW}${BLACK}BG_YELLOW ${BG_BLUE}${WHITE}BG_BLUE${RESET}\n"
