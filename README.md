# HorizonMW Server Infrastructure & Automation

> **Maintained by [Lucas Cardoso Barbeiro](https://github.com/lucascardosobarbeiro)**
> A cloud‐native, Infrastructure-as-Code solution for hosting a Call of Duty: Modern Warfare Remastered modded dedicated server in Google Cloud Platform, complete with CI/CD, automated startup scripts, and security best practices.

---

## 📖 Table of Contents

1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Architecture & Technologies](#architecture--technologies)

   * [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
   * [Cloud Provider (GCP)](#cloud-provider-gcp)
   * [CI/CD (GitHub Actions)](#cicd-github-actions)
   * [Startup Automation (PowerShell)](#startup-automation-powershell)
   * [Security & Monitoring](#security--monitoring)
4. [Getting Started](#getting-started)

   * [Prerequisites](#prerequisites)
   * [Clone & Branching Strategy](#clone--branching-strategy)
   * [Configure Variables & Secrets](#configure-variables--secrets)
   * [Deploying to GCP](#deploying-to-gcp)
   * [Testing & Validation](#testing--validation)
5. [How It Works](#how-it-works)

   * [Terraform Modules & Structure](#terraform-modules--structure)
   * [VM Startup Script](#vm-startup-script)
   * [CI/CD Pipeline](#cicd-pipeline)
   * [Networking & Firewall Rules](#networking--firewall-rules)
6. [Task Manager Files](#task-manager-files)
7. [Contributing & Support](#contributing--support)
8. [About the Author](#about-the-author)
9. [License](#license)

---

## 🚀 Project Overview

**HorizonMW Server** is a fully automated, cloud‐native solution designed to spin up and maintain a **Call of Duty: Modern Warfare Remastered** dedicated server (with the popular IW4MAdmin mod) on Google Cloud Platform. By leveraging **Terraform** for provisioning, **PowerShell** for VM startup automation, and **GitHub Actions** for continuous integration (CI) and security scanning, this project offers:

* **Automated Infrastructure Deployment** (IaC) with Terraform modules for networking and compute.
* **Secure Firewall & RDP Access** rules to minimize attack surface.
* **Startup Automation** that launches the game server and IW4MAdmin mod automatically upon VM boot.
* **CI/CD Pipeline** that enforces Terraform formatting, validation, and optional automated apply on merges to `master`.
* **Best Practices** for secrets management (no hard‐coded credentials), logging, and monitoring.

Whether you want to host a dedicated COD MWR server for competitive play, mod testing, or community events, HorizonMW Server provides a rock‐solid foundation—elegantly combining modern DevOps techniques with gaming culture.

---

## ⭐ Key Features

1. **Infrastructure as Code (IaC)**

   * Terraform modules for GCP VPC, subnets, firewall rules, static IPs, and Windows VM provisioning.
   * Separate `environments/default` folder with `main.tf` and `variables.tf` for environment‐specific configuration.

2. **Automated Startup & Health Checks**

   * PowerShell script (`startup.ps1`) ensures the game server (`server_default.bat`) and IW4MAdmin mod (`IW4MAdmin.dll`) start automatically on VM boot.
   * Dynamic health checks to wait for the game’s UDP port (27016) and the admin TCP port (1624) before marking startup as successful.
   * Detailed logs written to `C:\hmw_server_startup.log` for easy troubleshooting.

3. **Robust Security Posture**

   * Firewall rules locking down game ports and RDP using a customizable IP whitelist.
   * Google Monitoring Notification Channel configured to alert the admin via email if any VM or service metrics cross thresholds.
   * Optional GitHub Actions secret scanning to detect accidental credential commits.

4. **CI/CD with GitHub Actions**

   * **Lint & Validate**: Every push/PR to `teste` or `master` triggers `terraform fmt -check` and `terraform validate` to enforce code quality.
   * **Selective Deploy**: Pipeline applies Terraform on `master` only after validation.
   * **Branch Strategy**: Use `teste` for development; merge into `master` for production.

5. **Cloud Best Practices**

   * Remote state management using Terraform’s backend (e.g., GCS).
   * Service account with least‐privilege roles, stored securely as GitHub Secrets.
   * Separation of sensitive variables into `.auto.tfvars` (ignored in Git) and `vars.auto.tfvars.example` as a template.

---

## 🛠 Architecture & Technologies

### 🛠 Infrastructure as Code (Terraform)

* **HCL**: Terraform 1.6.0 compatible.
* **Modules**:

  * **network**: VPC, Subnet, Firewall.
  * **compute**: Windows VM, static IP, Service Account.
* **Environments**:

  * `/environments/default` references modules with environment-specific variables.
  * `vars.auto.tfvars.example` contains placeholder values; `vars.auto.tfvars` (gitignored) holds real secrets.

### ☁️ Cloud Provider (GCP)

* **Compute Engine**: Windows Server 2019 VM, `n2-standard-4`.
* **Networking**: Custom VPC, Subnet `10.10.0.0/24`, Firewall rules for UDP 27016–27017 and TCP 27016–27017 & 3389.
* **Monitoring**: Notification Channel to alert admin via email.

### 🔄 CI/CD (GitHub Actions)

* **Pipeline**: `.github/workflows/ci.yaml`.
* **Jobs**:

  1. **terraform-lint**: `fmt` & `validate`.
  2. **deploy** (on `master`): `terraform apply` using GCP credentials from GitHub Secrets.

### 🖥 Startup Automation (PowerShell)

* **`startup.ps1`**:

  1. Launches COD MWR server (`server_default.bat`).
  2. Waits for UDP port 27016 with dynamic health checks.
  3. Verifies & launches IW4MAdmin via `dotnet IW4MAdmin.dll`.
  4. Checks TCP port 1624.
  5. Logs to `C:\hmw_server_startup.log` and serial console.

### 🔒 Security & Monitoring

* **Firewall**: Allows game ports, restricts RDP with `allowed_admin_ips`.
* **Service Account**: Least-privilege roles; key stored as GitHub Secret.
* **.gitignore**: Ignores state files, lockfiles, logs, `.terraform`, and `vars.auto.tfvars`.

---

## 🏁 Getting Started

### Prerequisites

1. **GCP**:

   * Create a GCP project with billing.
   * Create a service account with `compute.instanceAdmin.v1`, `compute.networkAdmin`, `iam.serviceAccountUser`.
   * Generate JSON key; store in GitHub Secret `GCP_SA_KEY`.

2. **GitHub**:

   * Clone this repo.
   * Set secrets:

     * `GCP_PROJECT_ID = <YOUR_PROJECT_ID>`
     * `GCP_SA_KEY = { JSON_KEY_CONTENT }`

3. **Tools**:

   * Git >= 2.30, Terraform >= 1.6.0, gcloud CLI (optional).

---

### Clone & Branching Strategy

```bash
# Clone repository
git clone https://github.com/yourusername/HMW_SERVER_BR-LATAM-.git
cd HMW_SERVER_BR-LATAM-

# Ensure branches
git fetch origin
git checkout -b teste origin/teste
git checkout -b master origin/master
```

* **`teste`**: Development (CI validation).
* **`master`**: Production (CI validation + deploy).

---

### Configure Variables & Secrets

1. Copy `vars.auto.tfvars.example` → `vars.auto.tfvars`.
2. Edit `vars.auto.tfvars` with your values:

   ```hcl
   project_id           = "<YOUR_PROJECT_ID>"
   region               = "southamerica-east1"
   zone                 = "southamerica-east1-a"
   instance_name        = "cod-mwr-server"
   address_name         = "cod-mwr-static-ip"
   service_account_email = "<YOUR_SA_EMAIL>"
   allowed_admin_ips    = ["<YOUR_ALLOWED_IP>"]
   alert_email          = "<YOUR_EMAIL>"
   subnet_name          = "hmw-subnet"
   subnet_cidr          = "10.10.0.0/24"
   network_name         = "hmw-network"
   ```
3. Verify `.gitignore` includes:

   ```gitignore
   environments/default/vars.auto.tfvars
   ```

---

### Deploying to GCP

#### 1. Validate in `teste`

```bash
git checkout teste
git add .
git commit -m "Testing changes"
git push origin teste
```

* Runs Terraform `fmt` & `validate`.

#### 2. Merge & Deploy to `master`

```bash
git checkout master
git merge teste
git push origin master
```

* Runs `fmt` & `validate`, then `terraform apply` to provision/update GCP resources.

---

## 💼 Task Manager Files

To streamline day-to-day management and recurring checks, a set of Task Manager files (`.xml`) can be imported into **Windows Task Scheduler**. These tasks automate periodic health checks and restarts.

### 1. `HMW_Server_Health_Check.xml`

```xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <CalendarTrigger>
      <Repetition>
        <Interval>PT5M</Interval>
        <Duration>P1D</Duration>
      </Repetition>
      <StartBoundary>2025-01-01T00:00:00</StartBoundary>
      <Enabled>true</Enabled>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "C:\hmw_support\health_check.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
```

* **Interval**: Every 5 minutes.
* **Action**: Executes `health_check.ps1` (a PowerShell script) to verify game and IW4MAdmin ports.
* **Location**: Place this XML in `environments/default/infra/tasks/HMW_Server_Health_Check.xml`.

### 2. `HMW_Server_Restart_On_Failure.xml`

```xml
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <EventTrigger>
      <Subscription>
        <![CDATA[
        <QueryList>
          <Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
            <Select Path="Microsoft-Windows-TaskScheduler/Operational">
              *[System[(EventID=201)]] and *[EventData[Data[@Name='TaskName']='\\HMW_Server_Health_Check']]
            </Select>
          </Query>
        </QueryList>
        ]]>
      </Subscription>
      <Enabled>true</Enabled>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>Queue</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>false</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "C:\hmw_support\restart_on_failure.ps1"</Arguments>
    </Exec>
  </Actions>
</Task>
```

* **Trigger**: Listens for Task Scheduler Event ID 201 from the `HMW_Server_Health_Check` task (indicating failure).
* **Action**: Executes `restart_on_failure.ps1` to gracefully restart services.
* **Location**: Place this XML in `environments/default/infra/tasks/HMW_Server_Restart_On_Failure.xml`.

### 3. `health_check.ps1`

```powershell
# health_check.ps1
# Checks UDP 27016 and TCP 1624; if both fail, exits with code 1, else 0.

$gamePort = 27016
$adminPort = 1624
$udpOk = $false
$tcpOk = $false

try {
    $udpTest = New-Object System.Net.Sockets.UdpClient
    $udpTest.Connect('127.0.0.1', $gamePort)
    $udpTest.Close()
    $udpOk = $true
} catch {}

try {
    $tcpClient = New-Object System.Net.Sockets.TcpClient
    $tcpClient.Connect('127.0.0.1', $adminPort)
    $tcpClient.Close()
    $tcpOk = $true
} catch {}

if (-Not ($udpOk -and $tcpOk)) {
    exit 1
} else {
    exit 0
}
```

### 4. `restart_on_failure.ps1`

```powershell
# restart_on_failure.ps1
# Restarts server_default.bat and IW4MAdmin if health check fails.

$gameBat = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered\server_default.bat"
$adminDll = "C:\Program Files (x86)\Steam\steamapps\common\Call of Duty Modern Warfare Remastered\IW4MAdmin-2024.11.29.1\IW4MAdmin.dll"

# Stop existing processes
Get-Process -Name "iw4madmin" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "iw4" -ErrorAction SilentlyContinue | Stop-Process -Force

# Restart Game Server
Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"$gameBat`"" -WindowStyle Minimized
Start-Sleep -Seconds 180  # wait for server to bind

# Restart IW4MAdmin
$iw4Dir = Split-Path $adminDll
Set-Location $iw4Dir
Start-Process -FilePath "dotnet" -ArgumentList "`"$adminDll`"" -WindowStyle Minimized
```

Place these files in `environments/default/infra/tasks/` and import the XML files into Task Scheduler to automate health checks and restarts.

---

## 🤝 Contributing & Support

* **Development Branch**:

  * Create PRs to `teste`, wait for CI to pass.
* **Merge to Production**:

  * Merge `teste` → `master` only when stable.
* **Issues & Feedback**:

  * Use GitHub Issues.

Licensed under the MIT License. Contributions welcome!

---

## 🏆 About the Author

**Lucas Cardoso Barbeiro** is a DevOps & Cloud Engineer passionate about automated infrastructure and gaming. This project demonstrates IaC, CI/CD automation, and security best practices, providing a stable environment for COD MWR modded servers.

* 🔗 GitHub: [lucascardosobarbeiro](https://github.com/lucascardosobarbeiro)

---

## 📄 License

MIT License
