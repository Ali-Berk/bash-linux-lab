<a id="readme-top"></a>

<h3 align="center">Bash & Linux Administration Lab</h3>

  <p align="center">
    Bundle of my Linux CLI Bash scripting and administration journey
  </p>
</div>

## About The Project
This repo includes the tools automation scripts and configuration files I created while learning Linux system administration and Bash scripting it shows my progress and what I have learned during this process.

### Built With

<div align="left">
  <a href="https://www.linux.org/">
    <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  </a>
  <a href="https://www.gnu.org/software/bash/">
    <img src="https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white" alt="Bash">
  </a>
</div>

## Usage
The scripts are designed in a modular structure. They do not require any installation and can be run directly from the terminal.     
`cd bash-linux-lab`  
`./script_name.sh {parameter}...`   
 You need to give execute permission to the related script to use it .   
`chmod +x script_name.sh`    
 All you have to do is run the script with -h flag for detailed useage information   
`./script_name.sh -h`  

## Repository Content

| # | Script Name | Description | Key Concepts Covered |
| :---: | :--- | :--- | :--- |
| **00** | `first-shell-approach.sh` | The genesis. My very first steps into the Bash environment. | Basic syntax, variables, I/O |
| **01** | `user-auditor.sh` | A tool to audit system users and check security baselines. | User & Permissions |
| **02** | `log-analyzer.sh` | An automated log parsing and reporting tool. | Text processing (`awk`, `sed`, `grep`) |
| **03** | `service-watchdog-daemon.sh` | A background daemon that monitors critical services and restarts them if they fail. | Daemons, systemd, cron & Timers |
| **04** | `crash-recovery-and-zombie-sweeper.sh` | Sweeps zombie processes and recovers crashed states safely. | Process management |
| **05** | `disk-space-alert-system.sh` | Monitors storage and triggers alerts when thresholds are breached. | Disks & Filesystems (LVM) |
| **06** | `port-scanner.sh` | A lightweight network port scanner built entirely in Bash. | Networking & SSH |
| **07** | `dp-coin-optimizer.sh` | Algorithmic resource/coin optimization script. | Dynamic programming with bash|
| **08** | `automated-backup-system.sh` | A backup system with SSH & Cloud (rclone) support, including smart retention and lifecycle management. | Synthesis of learnings |

<!-- MARKDOWN LINKS & IMAGES -->
[Linux-badge]: https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black
[Linux-url]: https://www.linux.org/
[Bash-badge]: https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white
[Bash-url]: https://www.gnu.org/software/bash/
