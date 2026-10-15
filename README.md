#Custom Lynis Security Audit Scripts

Author: ANEESH A

Project Overview

This project extends Linux security auditing with custom shell scripts designed to examine filesystem mount options and DNS resolver configuration.

Scripts

1) enhanced_mount_security.sh — checks effective filesystem mounts for nodev, nosuid, and noexec.

2) enhanced_dns_security.sh — checks DNS nameserver entries, duplicate entries, and resolver target permissions.

Requirements

1) Linux or WSL Ubuntu
2) Lynis
3) findmnt
4) Standard Linux shell utilities
