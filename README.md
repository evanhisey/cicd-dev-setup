# AWS RHEL 9 Dev Stack Add-On Playbook

This Ansible playbook is an **add-on module** designed to safely layer a strict, RPM-based Infrastructure as Code (IaC) development stack on top of a pre-provisioned RHEL 9 workstation. 

## Features
* **Core Stack**: VS Code, Terraform, PowerShell, Git, jq.
* **Ansible Environment**: `ansible-core` and `ansible-lint` installed natively via the RHEL AppStream and EPEL repositories.
* **Pre-Configured IDE**: Installs VS Code extensions natively into the executing user's profile.

## Execution Requirements
**This playbook must be executed by the developer account that will be using the workstation.** To keep the code clean and prevent profile mapping issues, the playbook installs system packages via standard privilege escalation, but seamlessly drops back to your user account to install the IDE extensions.

* **Requirement 1:** You must run this playbook as your standard user (e.g., `ec2-user`, `jdoe`). Do *not* run this as the `root` user.
* **Requirement 2:** Your user account must have `sudo` privileges to install the RPM packages.

## Prerequisites
* **Ansible** installed on the control node or local machine (`sudo dnf install ansible-core`).
* Administrator (`sudo`) privileges on the target node.

## Usage

**Clone the repository:**
```bash
git clone <your-repo-url>
cd <repo-name>

### Playbook Execution Guide

This guide details how to execute the Dev Stack Add-On playbook. **You must run this playbook as the standard developer account** that will be using the workstation (e.g., `ec2-user`, `jdoe`). Do not run this as the `root` user. Your user account must have `sudo` privileges to install the required system packages.

## Prerequisites
* **Ansible** installed on the control node or local machine (`sudo dnf install ansible-core`).
* Administrator (`sudo`) privileges on the target node.

---

#### Option A: Local Execution (Default)

Use this method if you are already logged into the pre-provisioned RHEL 9 GUI instance (e.g., via RDP or console) and want to apply the configuration directly to your current session. 

The playbook assumes local execution by default. The `-K` (or `--ask-become-pass`) flag is required to prompt for your user's `sudo` password to install system packages.

```bash
ansible-playbook install_dev_stack.yml -K

#### Option B: Remote Execution via SSH
Use this method if you are pushing this configuration from a central control node (like your laptop or a bastion host) to one or more remote workstations.

You must define your target hosts in an inventory file and pass the target group using the -e target_hosts extra variable.

Create an inventory file (e.g., inventory.ini):

```Ini, TOML
[dev_workstations]
198.51.100.10
198.51.100.11
Execute the playbook:

```Bash
ansible-playbook -i inventory.ini install_dev_stack.yml -e "target_hosts=dev_workstations" -u <developer-username> --private-key=/path/to/your/key.pem -K

Note: If your SSH key is already added to your ssh-agent, you can omit the --private-key flag.
