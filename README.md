# HorizonMW Server Blueprint 🚀

**A production-ready blueprint for deploying a Call of Duty: Modern Warfare Remastered dedicated server (HorizonMW mod) on Google Cloud Platform.** Secure, monitored, and self-healing, this project combines Infrastructure-as-Code, CI/CD, and automated Windows tasks to deliver a robust, scalable game server environment—ideal for community gaming, competitive events, or DevOps learning.

---

## 📋 Project Description

The HorizonMW Server Blueprint automates the full deployment of a COD MWR dedicated server enhanced with the HorizonMW mod. Core technologies include:

* **Terraform** for infrastructure provisioning (VPC, subnets, firewall, static IP, Shielded Windows VM).
* **GitHub Actions** for CI/CD: running `terraform fmt`/`validate`, secret scanning, and controlled applies on `master`.
* **Windows Task Scheduler** XML tasks for auto-start and self-healing of Steam, game lobbies, and IW4MAdmin.
* **Cloud Monitoring & Logging** for uptime checks, CPU and budget alerts, and centralized log collection.
***THIS PROJECT ONLY GIVE YOU THE INFRA, YOU MUST FOLLOW THIS STEPS AFTER CREATED IT -> https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/*** 

Use this blueprint to host public or private game lobbies with minimal downtime, support tournament-grade reliability, or learn modern DevOps practices in a gaming context.

---

## 📌 Features

* **Infrastructure as Code:** Versioned Terraform modules create and manage all cloud resources.
* **CI/CD Pipeline:** Automated checks and Terraform applies via GitHub Actions, gated by branch protection rules.
* **Self-Healing Automation:** XML-defined tasks restart services within 60 seconds of failure.
* **Observability:** Uptime checks on IW4MAdmin port (1624), CPU usage alerts, budget thresholds, and centralized logs via the Cloud Logging agent.
* **Scalability:** Horizontal scaling via Managed Instance Groups and UDP/TCP load balancers.
* **Portfolio-Ready:** Clear documentation, ASCII diagrams, step-by-step guide, and cost estimates (\~US \$35/mo per VM).

---

## ⚙️ Quick Start

### 1. Fork & Clone

```bash
git clone https://github.com/<your-username>/HMW_SERVER_BR-LATAM-.git
cd HMW_SERVER_BR-LATAM-
```

### 2. Configure GitHub Secrets

Go to **Settings → Secrets → Actions** and add:

* `GCP_PROJECT_ID` (your GCP project ID)
* `GCP_SA_KEY` (service account JSON key)
* `ALERT_EMAIL` (optional)

### 3. Copy & Edit Variables

```bash
cp environments/default/vars.auto.tfvars.example environments/default/vars.auto.tfvars
```

Edit `vars.auto.tfvars` with your values:

* `project_id`, `region` (e.g., `southamerica-east1`), `zone`
* `network_name`, `subnet_cidr`
* `instance_name`, `allowed_admin_ips`, etc.

### 4. Deploy Infrastructure

```bash
git checkout -B teste
git add . && git commit -m "Configure infrastructure variables"
git push -u origin teste
# After CI validation succeeds:
git checkout master
git merge teste
git push origin master
```

This triggers GitHub Actions to run `terraform apply` and provision your network, VM, and firewall.

---

## 🖥️ Install Game & Mod

1. RDP into the Windows VM using the static IP from Terraform outputs.
2. Install Steam and Modern Warfare Remastered (Multiplayer).
3. Follow the HorizonMW setup guide: [https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/](https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/)
4. Download and extract HorizonMW server files into your game root directory (`<GAME_ROOT>`).

---
## After finish this steps, you will proceed
## 📑 Import Windows Automation Tasks

On the VM, open **Task Scheduler → Import Task…** and import these XMLs in order:

1. `INICIA_STEAM.xml` (0 min delay)
2. `Server_start_horizon-1-Startup.xml` (3 min delay)
3. `Server_start_horizon-2-Startup.xml` (5 min delay)
4. `IW4ADMIN.xml` (7 min delay)

For each Server_start_horizon task:

* **Program/script:** `powershell.exe` or `cmd.exe`
* **Arguments:** full path to the script or batch file (e.g., `C:\Game\server_default.bat`)
* **Start in:** game root directory
* Enable **Run whether user is logged on or not** and **Run with highest privileges**

For Steam  task:

* **Program/script:** `powershell.exe` or `cmd.exe`
* **Arguments:** full path to the script or batch file (e.g., `C:\Program Files (x86)\Steam\steam.exe`)
* **Start in:** steam root directory
* Enable **Run whether user is logged on or not** and **Run with highest privileges**

For IW4ADMIN task task:

* **Program/script:** `Put DOT after the path, because it runs only with DOT"
* **Arguments:** full path to the script or batch file (e.g., `C:\Program Files (x86)\{your-local-path}`)
* **Start in:** file root directory
* Enable **Run whether user is logged on or not** and **Run with highest privileges**


##  After created, run manually each Task starting first  steam to ensure it will run 
---

## 🚦 Smoke Test

On the VM, verify ports:

```bash
netstat -ano | findstr "27016 27017 1624"
```

From a game client:

```bash
connect <EXTERNAL_IP>:27016
```

Type `!owner` to confirm admin privileges.
In a browser, visit `http://<EXTERNAL_IP>:1624` for the IW4MAdmin WebFront.

---

## 🔄 Optional Scale-Out

Edit `vars.auto.tfvars`:

```hcl
instance_count = 3
```

Commit and merge to `master` to deploy multiple instances in a Managed Instance Group with UDP/TCP load balancing.

---

## 🏗️ Architecture Diagram

```txt
Google Cloud (southamerica-east1)

VPC 10.10.0.0/24
 ├─ Firewall: UDP/TCP 27016-27030 (Game traffic)
 ├─ Firewall: TCP 1624 (IW4MAdmin WebFront)
 └─ Firewall: TCP 3389 (RDP)

Compute Engine VM
 ├─ n2-standard-4 (4 vCPU, 16 GB RAM)
 ├─ Shielded VM (secure-boot, vTPM)
 ├─ SSD Balanced 100 GB
 ├─ Static IP
 └─ Task Scheduler XMLs for auto-start & recovery

Monitoring & Logging
 ├─ Uptime Check: TCP 1624
 ├─ CPU Alert: > 85% for 5 min
 ├─ Budget Alert: $50
 └─ Cloud Logging agent (Windows Event + custom logs)
```

---

## 📈 Cost Estimate

* **1 VM:** \~US \$35/month
* **3 VMs:** \~US \$90/month
  Use the [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) for precise estimates.

---

## 🤝 Contributing & Contact

Fork the repository, open a pull request, and use the `teste` branch for development. Protect the `master` branch to ensure production changes only arrive via reviewed merges.

**Contact:**
✉️ [lcb.barbeiro@gmail.com](mailto:lcb.barbeiro@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/lucascardosobarbeiro/)

## 🙋 Questions & Suggestions

Have questions or ideas for improvement? Feel free to:

* Open a GitHub Issue in this repository.
* Email me at [lcb.barbeiro@gmail.com](mailto:lcb.barbeiro@gmail.com).
* Connect on LinkedIn: [https://www.linkedin.com/in/lucascardosobarbeiro/](https://www.linkedin.com/in/lucascardosobarbeiro/)

---

## 📄 License

MIT License.
