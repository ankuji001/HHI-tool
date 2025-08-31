Perfect 🚀 since you’ve shown me the actual CLI output of your **Host Header Injection Scanner**, I’ll prepare a clean **README.md** file for GitHub. It’ll explain installation, usage, sample output, features, and disclaimer in a professional bug-bounty style.

Here’s a polished draft:

---

# 🛡️ Host Header Injection Scanner (HHI-tool)

A **CLI-based Host Header Injection Scanner** built with **Shell Scripting**, designed for penetration testers, bug bounty hunters, and security researchers.

This tool automates detection of **Host Header Injection vulnerabilities** by fuzzing multiple request headers with crafted payloads. It helps identify potential misconfigurations that could lead to:

* Web cache poisoning
* Authentication bypass
* Password reset poisoning
* Access control bypass

---

## ✨ Features

* 🔍 Tests multiple headers automatically:

  * `Host`
  * `X-Forwarded-Host`
  * `X-Host`
  * `X-Original-Host`
  * `Forwarded`
  * `X-Forwarded-Server`
  * `X-HTTP-Host-Override`
  * `Origin`
  * `Referer`
* 🛠️ Generates multiple payload variants (`evil.com`, `127.0.0.1`, `localhost`, custom subdomains, etc.)
* 📊 Displays results in a clean **table format** with risk levels (`LOW`, `MEDIUM`, `HIGH`).
* ⚡ 100% Bash script – lightweight and portable (requires only `curl`).
* 🎨 ASCII banner & progress bar for a better CLI experience.

---

## 📦 Installation

Clone the repository and make the script executable:

```bash
git clone https://github.com/ankuji001/HHI-tool.git
cd HHI-tool
chmod +x bash.sh
```

---

## 🚀 Usage

Basic usage:

```bash
./bash.sh -u https://target.com
```

Options:

* `-u <url>` → Target URL
* `-p <payload>` → Custom base payload (default: `evil.com`)

Example:

```bash
./bash.sh -u https://google.com -p attacker.com
```

---

## 📋 Example Output

```bash
anku@anku:~/HHI-tool$ ./bash.sh -u https://google.com


 ██╗  ██╗ ██████╗ ███████╗████████╗    ██╗  ██╗███████╗ █████╗ ██████╗ ██████╗ ███████╗██████╗ 
 ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝    ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
 ███████║██║   ██║███████╗   ██║       ███████║█████╗  ███████║██║  ██║██████╔╝█████╗  ██║  ██║
 ██╔══██║██║   ██║╚════██║   ██║       ██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══██╗██╔══╝  ██║  ██║
 ██║  ██║╚██████╔╝███████║   ██║       ██║  ██║███████╗██║  ██║██████╔╝██║  ██║███████╗██████╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝       ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ 

        Host Header Injection Scanner
        build by Anku (https://github.com/ankuji001)

[*] Target URL: https://google.com
[*] Payload base: evil.com
[*] Checking dependencies...

[*] Generating payload variants...
[+] Generated 21 payload variants

[*] Starting scan...
[██████████████████████████████████████] 100%

══════════════════════════════════════════════════════════════
                    SCAN RESULTS
══════════════════════════════════════════════════════════════
HEADER               PAYLOAD                 STATUS  RISK
──────────────────────────────────────────────────────────────
Host                 evil.com                404     MEDIUM
Host                 127.0.0.1               301     HIGH
X-Forwarded-Host     evil.com                301     HIGH
X-Original-Host      127.0.0.1:8080          301     HIGH
Forwarded            localhost               301     HIGH
X-Forwarded-Server   admin.evil.com          301     HIGH
Origin               dev.evil.com            301     HIGH
Referer              staging.evil.com        301     HIGH
──────────────────────────────────────────────────────────────

[+] Found 189 interesting responses!
══════════════════════════════════════════════════════════════
```

---

## ⚠️ Disclaimer

This tool is created **strictly for educational purposes, security testing, and authorized penetration testing engagements**.
Do **not** use it on systems you don’t own or don’t have explicit permission to test.
Unauthorized use of this tool may be illegal.

---

## 👤 Author

* **Anku**
* 🔗 GitHub: [@ankuji001](https://github.com/ankuji001)
* 📷 Instagram: [@ig.anku](https://www.instagram.com/ig.anku/)

---

👉 Would you like me to also add a **“How it works”** section (explaining curl requests + headers injection logic) so people on GitHub know what’s happening behind the scenes?
