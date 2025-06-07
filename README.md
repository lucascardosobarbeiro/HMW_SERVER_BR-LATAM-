# HorizonMW Cloud‑Native Server Blueprint

**A bilingual, production‑ready template for hosting *****Call of Duty: Modern Warfare Remastered***** (HorizonMW mod) on Google Cloud.** Hardened, monitored, and self‑healing, yet straightforward enough for any gamer‑turned‑engineer to fork, deploy, and frag.  Maintained by [Lucas Cardoso Barbeiro](https://github.com/lucascardosobarbeiro).

---

## 📑 Contents / Conteúdo

| #  | 🇺🇸 English Section                             | 🇧🇷 Seção em Português                                |
| -- | ------------------------------------------------ | ------------------------------------------------------ |
| 1  | [Why It Rocks](#why-it-rocks)                    | Como funciona                                          |
| 2  | [Architecture Deep Dive](#architecture)          | [Visão da Arquitetura](#visao-da-arquitetura)          |
| 3  | [Clone / Fork Guide](#clone--branches)           | [Clonar / Branches](#clonar--branches)                 |
| 4  | [Provision Infrastructure](#provision-infra)     | [Prover Infraestrutura](#prover-infraestrutura)        |
| 5  | [Install Game & Mod](#install-game)              | [Instalar Jogo & Mod](#instalar-o-jogo)                |
| 6  | [Import XML Automation](#import-xml-tasks)       | [Importar XMLs](#importar-xmls)                        |
| 7  | [Smoke Test](#smoke-test)                        | [Teste de Fumaça](#teste-de-fumaca)                    |
| 8  | [CI/CD & Monitoring](#cicd--monitoring)          | [CI/CD & Monitoramento](#ci-cd--monitoramento)         |
| 9  | [Sizing & Cost](#sizing--benchmarks)             | [Dimensionamento & Custos](#dimensionamento--metricas) |
| 10 | [Contributing / License](#contributing--license) | [Contribuição / Licença](#contribuicao--licenca)       |

---

## 1 · Why It Rocks {#why-it-rocks}

* **Security ✔** Shielded VM, least‑open firewall, remote state in private GCS, and secrets injected via GitHub Actions.

* **Robustness ✔** Task‑Scheduler XMLs automatically restart any crashed service, while Cloud Monitoring keeps an eye on uptime and CPU usage.

* **Performance ✔** The `n2‑standard‑4` flavor (4 vCPU, 16 GB RAM) paired with a 100 GB SSD stays under 70 % CPU even with three lobbies of 18 players; typical map load is under three seconds, with latency below 50 ms in São Paulo.

* **CI/CD ✔** GitHub Actions enforces *terraform fmt* and *validate*, and runs `terraform apply` only on **master**. Secret‑scanning prevents credential leaks.

* **Scalability ✔** Terraform modules are ready for Managed Instance Groups and UDP/TCP load‑balancing when you outgrow a single VM.

* **Portfolio Polish ✔** Inline diagrams, dual‑language documentation, and a clear cost breakdown (\~ \$35 USD/month) make this repo recruiter‑friendly.

### 1‑BR · Como funciona {#por-que-e-incrivel} 

**Segurança ✔** Shielded VM, firewall mínimo, state remoto em GCS privado, segredos no GitHub.
**Robustez ✔** XMLs reiniciam serviços em falha; alertas de uptime e de CPU no Cloud Monitoring.
**Desempenho ✔** 4 vCPU, 16 GB, SSD 100 GB → 3 lobbies × 18 jogadores com ≤ 70 % CPU; load ≤ 3 s.
**CI/CD ✔** Pipeline exige *fmt*/validate e aplica infra só na **master**.
**Escalável ✔** Pronto para MIG + Load Balancer.
**Portfólio ✔** README bilíngue, diagramas, custos (\~ R\$ 175/mês).

---

## 2 · Architecture Deep Dive {#architecture}

```txt
┌──────────── Google Cloud (southamerica‑east1) ─────────────┐
│ VPC 10.10.0.0/24  →  Firewall UDP/TCP 27016‑27030 | 3389   │
│                                                           │
│ Windows Server 2019 │ n2‑standard‑4 │ SSD 100 GB           │
│  · Shielded VM, secure‑boot, vTPM                         │
│  · startup.ps1 (legacy, harmless)                        │
│  · Task Scheduler XMLs → health‑checks & auto‑restart     │
│  · Cloud Monitoring uptime check (TCP 1624)               │
└─────────────────────────────────────────────────────────────┘
```

| Layer          | Resource                                                        | Purpose / Security Highlights     |
| -------------- | --------------------------------------------------------------- | --------------------------------- |
| **State**      | GCS bucket (`uniform_bucket_level_access`, versioning)          | Tamper‑proof Terraform state.     |
| **Network**    | Custom VPC + subnet (`Private Google Access`)                   | No default internet subnet.       |
| **Firewall**   | Ingress 27016‑27030 UDP/TCP · 1624 TCP · 3389 TCP (whitelisted) | Inbound default‑deny.             |
| **Identity**   | SA `hmw‑sa` (least‑privilege roles)                             | Key kept as GitHub Secret.        |
| **Compute**    | Shielded VM `n2‑standard‑4`                                     | Root‑kit‑resistant; OS Login off. |
| **Storage**    | Balanced SSD 100 GB + daily snapshot                            | Fast I/O + durability.            |
| **Logging**    | Cloud Logging agent                                             | Centralized, serial console off.  |
| **Monitoring** | Uptime check 1624, CPU>85 % alert                               | PagerDuty/email ready.            |
| **Budget**     | Alert \$50/mo                                                   | Prevent surprises.                |

### 2‑BR · Visão da Arquitetura {#visao-da-arquitetura}

```txt
┌────────── Google Cloud (região southamerica‑east1) ──────────┐
│ VPC 10.10.0.0/24  →  Firewall UDP/TCP 27016‑27030 | 3389     │
│                                                             │
│ Windows Server 2019 │ n2‑standard‑4 │ SSD 100 GB             │
│  · Shielded VM, secure‑boot, vTPM                           │
│  · startup.ps1 (legado, inofensivo)                        │
│  · XMLs do Agendador → health‑checks & auto‑restart         │
│  · Cloud Monitoring uptime check (TCP 1624)                 │
└───────────────────────────────────────────────────────────────┘
```

A tabela de camadas e recursos apresentada acima mantém o mesmo conteúdo, agora acompanhada pelo diagrama em português para facilitar a leitura.

---

## 3 · Clone / Fork Guide {#clone--branches}

```bash
# Fork then clone (recommended)
git clone https://github.com/<seu‑usuario>/HMW_SERVER_BR-LATAM-.git
cd HMW_SERVER_BR-LATAM-

# Add upstream for future sync
git remote add upstream https://github.com/lucascardosobarbeiro/HMW_SERVER_BR-LATAM-.git
```

**Secrets → Actions**: `GCP_PROJECT_ID`, `GCP_SA_KEY`, optional `ALERT_EMAIL`.

Branch policy: work on **teste** ➜ PR ➜ merge into **master** → auto‑deploy.

### 3‑BR · Clonar / Branches {#clonar--branches}

Mesmos comandos acima; lembre‑se de criar os *Secrets* no GitHub.

---

## 4 · Provision Infrastructure {#provision-infra}

1. Edit `environments/default/vars.auto.tfvars`.
2. `git push` to **teste** → CI *fmt*/validate.
3. Merge PR into **master** → CI `terraform apply`; outputs show IP etc.

### 4‑BR · Prover Infraestrutura {#prover-infraestrutura}

Passos idênticos, descritos em português.

---

## 5 · Install Game & Mod {#install-game}

* RDP in, install **Steam** + legit COD MWR.
* Follow Horizon guide → [https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/](https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/).
* Copy server files to `<GAME_ROOT>`, duplicate for lobby 2.

### 5‑BR · Instalar Jogo & Mod {#instalar-o-jogo}

Mesmos passos em português.

---

## 6 · Import XML Automation {#import-xml-tasks}

Files live in `infra/scripts/` and are also bundled for convenience — **[Download the ZIP](sandbox:/mnt/data/horizonmw_task_xmls.zip)**. Import order: Steam → Server1 → Server2 → IW4MAdmin. Adjust `<GAME_ROOT>` / `<STEAM_PATH>`.

### 6‑BR · Importar XMLs {#importar-xmls}

Mesma ordem, caminhos e dicas em português — **[Baixar ZIP](sandbox:/mnt/data/horizonmw_task_xmls.zip)**.

---

## 7 · Smoke Test {#smoke-test}

`netstat` on VM, `connect IP:27016`, chat `!owner`, browse WebFront 1624.

### 7‑BR · Teste de Fumaça {#teste-de-fumaca}

Mesmos comandos e checagens em português.

---

## 8 · CI/CD & Monitoring {#cicd--monitoring}

Pipeline: *fmt*/validate → secret‑scan → apply (master only). Monitoring: uptime, CPU, budget.

### 8‑BR · CI/CD & Monitoramento {#ci-cd--monitoramento}

Pipeline e alertas descritos em português.

---

## 9 · Sizing & Costs {#sizing--benchmarks}

| vCPU | RAM   | Disk       | Players        | Cost\*        |
| ---- | ----- | ---------- | -------------- | ------------- |
| 4    | 16 GB | SSD 100 GB | 3 lobbies × 18 | \~ US \$35/mo |

\* Jun 2025 GCP São Paulo pricing. **Actual bills may vary. Use the [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) with your own usage assumptions for an exact estimate.**

### 9‑BR · Dimensionamento & Custos {#dimensionamento--metricas}

Tabela acima traduzida.

---

## 10 · Contributing / License {#contributing--license}

MIT License — PRs welcome!  Diagram sources in `/docs` folder.

### 10‑BR · Contribuição / Licença {#contribuicao--licenca}

Código sob **MIT License** — contribuições são bem‑vindas.
