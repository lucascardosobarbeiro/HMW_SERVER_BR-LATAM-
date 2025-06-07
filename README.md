# HorizonMW Cloud-Native Server Blueprint / Plano HorizonMW Cloud-Native

**A complete, bilingual reference architecture for deploying *****Call of Duty: Modern Warfare Remastered***** (HorizonMW mod) on Google Cloud Platform.** Hardened, monitored, self-healing, yet intuitive enough to fork, deploy, and manage.
**Uma arquitetura de referência completa e bilíngue para implantar *****Call of Duty: Modern Warfare Remastered***** (mod HorizonMW) na Google Cloud Platform.** Protegido, monitorado, auto-curável e suficientemente simples para clonar, implantar e administrar.

---

## 1 · Project Overview / Visão Geral do Projeto

**English:**
This repository provides an end-to-end blueprint: Terraform modules to provision network and Windows VM infrastructure; GitHub Actions CI/CD for validation, secret-scanning, and automated apply; Windows Task Scheduler XML definitions for self-healing startup of Steam, game lobbies, and IW4MAdmin; and Cloud Monitoring/Logging for observability. Ideal for showcasing DevOps expertise in a gaming context.

**Português:**
Este repositório oferece um blueprint completo: módulos Terraform para provisionar rede e infraestrutura de VM Windows; CI/CD com GitHub Actions para validação, auditoria de segredos e aplicação automatizada; definições XML do Agendador de Tarefas Windows para auto-recuperação de Steam, salas de jogo e IW4MAdmin; e Monitoramento/Logging no Cloud para observabilidade. Perfeito para demonstrar habilidades DevOps no contexto de games.

---

## 2 · Technical Infrastructure Details / Detalhes Técnicos da Infraestrutura

### 2.1 Terraform Structure / Estrutura Terraform

* **Backend:** GCS bucket regional com versionamento e `uniform_bucket_level_access`.
* **Providers:** Google Cloud (network, compute).
* **Modules:**

  * `network`: VPC, sub-rede, regras de firewall (UDP/TCP 27016–27030, TCP 1624, TCP 3389).
  * `compute`: endereço IP estático, Windows VM (`n2-standard-4`, SSD 100 GB, Shielded VM).
* **State Locking:** impede drifts e garante colaboração segura.

### 2.2 Network & Firewall / Rede & Firewall

* **VPC:** `10.10.0.0/24`, Private Google Access.
* **Sub‑rede:** configurable CIDR.
* **Regras:**

  * UDP/TCP 27016–27030 (jogos).
  * TCP 1624 (admin WebFront).
  * TCP 3389 (RDP — IPs de admin).
* **Política:** inbound-deny por padrão, egress allow.

### 2.3 Compute Engine / Máquina Virtual

* **Tipo:** `n2-standard-4` (4 vCPU, 16 GB RAM).
* **Disco:** SSD Balanced 100 GB.
* **Proteções:** Shielded VM (secure-boot, vTPM), OS Login desativado.
* **Scripts iniciais:** `startup.ps1` (legado, fallback).

### 2.4 Observability & Security / Observabilidade & Segurança

* **Logging:** Cloud Logging agent para Windows Event Log e logs customizados.
* **Monitoring:** Uptime check TCP 1624, alertas CPU > 85%, alerta de orçamento.
* **IAM:** service account com roles mínimos armazenada como secret no GitHub.

---

## 3 · Windows Automation Artefacts / Artefatos de Automação no Windows

Scripts legados (`startup.ps1`) residem em `infra/scripts/`, mas a orquestração real ocorre via XML:

| XML File                                 | Delay | Action                                         | Retry Policy      |
| ---------------------------------------- | ----- | ---------------------------------------------- | ----------------- |
| **INICIA\_STEAM.xml**                    | 0 min | Launch Steam.exe                               | none              |
| **Server\_start\_horizon-1-Startup.xml** | 3 min | Execute `server_default.bat` (UDP port 27016)  | 2 retries @ 5 min |
| **Server\_start\_horizon-2-Startup.xml** | 5 min | Execute `server2_default.bat` (UDP port 27017) | 2 retries @ 5 min |
| **IW4ADMIN.xml**                         | 7 min | Run `StartIW4MAdmin.cmd` (TCP port 1624)       | 3 retries @ 1 min |

**Import Steps / Passos de Importação:**

1. Abra Task Scheduler → **Import Task…**.
2. Selecione cada XML na ordem acima (Steam → Lobby 1 → Lobby 2 → IW4MAdmin).
3. Edite `<Arguments>` e `<WorkingDirectory>` para `<GAME_ROOT>` e `<STEAM_PATH>`.
4. Marque **Run whether user is logged on or not**.

---

## 4 · Usage Workflow / Fluxo de Uso Passo a Passo

1. **Clone & Fork**

   ```bash
   git clone https://github.com/<usuario>/HMW_SERVER_BR-LATAM-.git
   cd HMW_SERVER_BR-LATAM-
   git remote add upstream https://github.com/lucascardosobarbeiro/HMW_SERVER_BR-LATAM-.git
   ```
2. **Configure GitHub Secrets**

   * `GCP_PROJECT_ID`, `GCP_SA_KEY` (JSON), opcional `ALERT_EMAIL`.
3. **Populate Variables**

   * Copie `vars.auto.tfvars.example` → `vars.auto.tfvars` e ajuste parâmetros (`project_id`, `region`, IPs, portas).
4. **Deploy Infra (branch **\`\`**)**

   ```bash
   git checkout -B teste
   git add .
   git commit -m "Configure infra vars"
   git push -u origin teste
   ```
5. **Apply to Production (branch **\`\`**)**

   ```bash
   git checkout master
   git merge teste
   git push origin master
   ```
6. **RDP na VM**

   * Conecte ao IP estático exibido nos outputs.
7. **Install Game & Mod**

   * Instale Steam e *COD MWR* via client oficial.
   * Siga o guia: [https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/](https://docs.horizonmw.org/hmw-game-server-setup-guide-dedicated/).
   * Copie `server_default.bat/.cfg` e `server2_default.*` para `<GAME_ROOT>`.
8. **Import XML Tasks**

   * Use o ZIP: [Download ZIP](sandbox:/mnt/data/horizonmw_task_xmls.zip).
   * Importe na ordem e ajuste caminhos.
9. **Smoke Test / Teste de Fumaça**

   * `netstat -ano | findstr 27016 27017 1624`
   * Cliente: `connect <IP>:27016`, digite `!owner`.
   * Navegador: `http://<IP>:1624`.

---

## 5 · Final Notes / Observações Finais

* **Costs May Vary:** \~US \$35/mo per VM; scale-out (3 VMs) \~\$90/mo. Use the [GCP Pricing Calculator](https://cloud.google.com/products/calculator) for precise estimates.
* **Resilience:** Shielded VM + XML-driven self-healing + Monitoring form a robust recovery loop.
* **Portfolio Value:** Clear bilingual docs, diagrams, step-by-step instructions, and a modern DevOps showcase.

---

## 6 · Contribution / License / Contact

MIT License — contributions welcome!  Diagram sources in `/docs`.

**Contact / Contato:**
✉️ [lcb.barbeiro@gmail.com](mailto:lcb.barbeiro@gmail.com)
🔗 [LinkedIn](https://www.linkedin.com/in/lucascardosobarbeiro/)
