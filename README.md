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

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd <repo-name>