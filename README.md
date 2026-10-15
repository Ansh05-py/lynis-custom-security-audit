Custom Lynis Security Audit Scripts

Author: ANEESH A

Project Overview

This project extends Linux security auditing with custom shell scripts designed to examine filesystem mount options and DNS resolver configuration.

Scripts

enhanced_mount_security.sh — checks effective filesystem mounts for nodev, nosuid, and noexec.

enhanced_dns_security.sh — checks DNS nameserver entries, duplicate entries, and resolver target permissions.

Requirements

Linux or WSL Ubuntu

Lynis

findmnt

Standard Linux shell utilities
