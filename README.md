# Linux Security Auditing Using Custom Lynis Plugins

## Overview

This project focuses on developing and enhancing custom security auditing plugins using **Lynis**, an open-source security auditing tool for Linux systems.

The project covers two security areas:

1. Filesystem Mount Security
2. DNS Resolver Security

For each area, a reference plugin and an enhanced plugin are included. The enhanced versions introduce additional checks, improved reporting and security recommendations.

## Project Structure

```text
Lynis_DA1/
│
├── mount_security_reference.sh
├── mount_security_enhanced.sh
├── dns_security_reference.sh
├── dns_security_enhanced.sh
└── README.md
```

## 1. Filesystem Mount Security

### Reference Script
**File:** `mount_security_reference.sh`  
**Test ID:** `CUS-0501`  
**Version:** 1.0

Checks important filesystem mount points for the following security options:

- `nodev` – Prevents device files from being interpreted on the mount.
- `nosuid` – Prevents set-user-ID and set-group-ID bits from taking effect.
- `noexec` – Prevents direct execution of programs from the mount.

The script checks `/tmp`, `/var/tmp`, `/dev/shm`, `/run` and `/home`, reporting missing mount options with warnings and suggestions.

### Enhanced Script
**File:** `mount_security_enhanced.sh`  
**Test ID:** `MOUNT-0001`  
**Version:** 2.0

Enhancements include:

- Identifies the effective filesystem mount using `findmnt`.
- Detects when directories share the same underlying mount.
- Checks `nodev`, `nosuid` and `noexec` options.
- Provides individual OK/WARNING results.
- Generates detailed warnings and remediation suggestions.
- Includes checks for `/proc` and `/sys`.

## 2. DNS Resolver Security

### Reference Script
**File:** `dns_security_reference.sh`  
**Test ID:** `CUS-0502`  
**Version:** 1.0

Audits the DNS resolver configuration file `/etc/resolv.conf`.

The script checks:

- Existence of the resolver configuration file.
- Presence of DNS nameserver entries.
- Duplicate nameserver entries.
- Resolver file permissions, following symbolic links.

Warnings and suggestions are generated when configuration or permission issues are detected.

### Enhanced Script
**File:** `dns_security_enhanced.sh`  
**Test ID:** `CUS-0503`  
**Version:** 2.0

The enhanced version retains the reference checks and introduces:

- **DNS Server Redundancy:** Checks whether at least two unique DNS nameservers are configured.
- **DNS Timeout Configuration:** Checks whether an explicit timeout value between 1 and 5 seconds is configured.
- **DNS Retry Configuration:** Checks whether an explicit retry value between 1 and 5 is configured.
- **Improved Reporting:** Displays individual OK/WARNING results and provides recommendations.

The timeout and retry ranges are the audit thresholds selected for this project.

## Requirements

- Linux operating system or WSL Ubuntu.
- Lynis security auditing tool.
- Shell environment (`/bin/sh`).
- `findmnt`, `awk`, `grep`, `sort`, `uniq`, `stat` and other standard Linux utilities.

## Installation and Execution

### 1. Install Lynis

```bash
sudo apt update
sudo apt install lynis
```

### 2. Copy the plugins

Copy the required plugin scripts into the Lynis plugin directory:

```bash
sudo cp mount_security_reference.sh /etc/lynis/plugins/plugin_mount_security_phase1
sudo cp mount_security_enhanced.sh /etc/lynis/plugins/plugin_mount_security_phase2
sudo cp dns_security_enhanced.sh /etc/lynis/plugins/plugin_dns_security_phase1
```

The reference DNS plugin can be copied into the active plugin location separately when testing the reference version.

### 3. Configure plugin execution

Edit the Lynis default profile:

```bash
sudo nano /etc/lynis/default.prf
```

Ensure the following entries are present:

```text
skip-plugins=no
plugin=mount_security
plugin=dns_security
```

### 4. Run the security audit

```bash
sudo lynis audit system --quick
```

### 5. Check the audit log

```bash
sudo grep -E 'CUS-0501|MOUNT-0001|CUS-0502|CUS-0503' /var/log/lynis.log
```

## Learning Outcomes

- Gained practical experience in developing custom Lynis plugins using shell scripting.
- Learned to identify filesystem mount misconfigurations and DNS resolver configuration issues.
- Understood how to use Linux utilities such as `findmnt`, `awk`, `stat` and `grep` for security auditing.
- Improved the ability to generate security warnings and actionable recommendations through automated scripts.

## Conclusion

This project demonstrates the development of custom Lynis plugins for auditing filesystem mount configurations and DNS resolver settings. The enhanced plugins extend the reference implementations with additional checks and clearer reporting, helping identify potential security and reliability issues in Linux systems.

## Author

**ANEESH A**
