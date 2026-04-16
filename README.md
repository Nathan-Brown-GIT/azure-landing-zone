# Azure Secure Landing Zone

A secure, enterprise-style Azure network topology built from scratch as a CV/portfolio project, demonstrating real-world cloud infrastructure design and Infrastructure as Code practices.

The environment was first deployed manually via the Azure Portal to validate the architecture, then fully rebuilt in VS Code using Terraform — reinforcing the principle of treating infrastructure as reproducible, version-controlled code.

No public IPs are exposed. All VM access is brokered through Azure Bastion, eliminating the attack surface of open RDP/SSH ports.

## Status
Complete

## Architecture Overview

Hub-and-spoke VNet topology:
- **Hub VNet** — hosts Azure Bastion and acts as the central connectivity point
- **Spoke VNet(s)** — isolated workload networks, peered to the hub
- All inter-VNet traffic flows through VNet Peering with NSG enforcement at the subnet level
- Linux VMs deployed in spoke networks, accessible only via Bastion (no public IP)

Architecture diagram available in the repository.

## Azure Services Used

| Azure Virtual Networks (Hub + Spoke) | Network segmentation and isolation |
| VNet Peering | Private connectivity between hub and spokes |
| Network Security Groups (NSGs) | Layer 4 traffic filtering at subnet/NIC level |
| Azure Bastion | Secure, browser-based RDP/SSH without public IPs |
| Azure Virtual Machines (Linux) | Workload compute in isolated spoke networks |

## Infrastructure as Code (Terraform)

The entire environment is defined and deployable via Terraform:
- Resources broken into logical `.tf` files (networking, compute, security)
- Remote state management
- Parameterised using `variables.tf` for reusability across environments
- Demonstrates a build-by-hand → codify workflow, mirroring real enterprise practices

## Skills Demonstrated

- **Cloud networking** — VNet design, subnetting, peering, and routing
- **Zero-trust access** — removing all public endpoints; access via PaaS bastion only
- **Infrastructure as Code** — full Terraform deployment of a multi-resource Azure environment
- **Security hardening** — NSG rule design, principle of least privilege applied at network layer
- **Azure Portal to IaC migration** — manually validated architecture before codifying, a common real-world workflow
- **Linux VM administration** — deployment and management within a private network

## Author
Nathan Brown
