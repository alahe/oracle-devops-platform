# Jira Story: FIN-008 — PROD Active/Standby Golden Snapshot Sync & Failover

| Field | Value |
|:---|:---|
| **Story ID** | FIN-008 |
| **Epic** | High Availability & Disaster Recovery (DR) |
| **Component** | Golden Snapshots / Rsync Daemon / Failover Automation |
| **Priority** | Critical |
| **Estimation** | **8 Story Points** |
| **Target Environments** | PROD (DC-1 Active vs DC-2 Standby) |
| **Dependencies** | FIN-002, FIN-003, FIN-004, FIN-005 |

---

## 1. User Story
**As an** Enterprise Continuity Officer & Lead Production DBA,  
**I want to** establish automated periodic synchronization of database Golden Snapshots from the Active datacenter to the Standby datacenter, coupled with a 1-click failover script,  
**So that** in the event of hardware, network, or site failure in DC-1, the standby nodes in DC-2 can be activated with **RTO < 60 seconds** and **RPO < 15 minutes**.

---

## 2. Business Value & Financial Compliance
- **DORA Continuity Obligation (Chapter II, Article 11):** Mandatory requirement to maintain tested, documented disaster recovery and redundant capacity in a secondary location.
- **SLA & Financial Loss Prevention:** Prevents catastrophic business stoppage during primary datacenter disruptions.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `scripts/dr/sync-standby.sh`: Daemon / cron script running on Active nodes to create encrypted snapshots and rsync to Standby.
2. `scripts/dr/failover-standby.sh`: Disaster recovery activation script executed on Standby host or by orchestration.
3. `scripts/dr/status-dr.sh`: Health monitoring script checking snapshot age and replication lag.

### Failover Execution Flow (`scripts/dr/failover-standby.sh`):
1. Verifies snapshot integrity in `/var/lib/oracle-snapshots/`.
2. Restores volume into Podman storage using `./scripts/snapshots/restore-golden-snapshots.sh --auto`.
3. Starts containers `db-proxy`, `db-publisher`, `app-ords`, and `app-publisher`.
4. Executes `./scripts/check-wallet.sh` to confirm database listener readiness.
5. Invokes F5 API or local script to switch Virtual IP to DC-2 nodes.

---

## 4. Definition of Done (DoD)
- [ ] Cron job configured on Active host executing `sync-standby.sh` every 15 minutes.
- [ ] Standby host maintains valid, untampered snapshot files in sync.
- [ ] `scripts/dr/failover-standby.sh` executed successfully during a simulated failover drill.
- [ ] Failover duration measured from command invocation to HTTP 200 is $< 60$ seconds.
- [ ] Recovery benchmark metrics recorded in `metrics/setup_benchmarks.json` (Rule 1).

---

## 5. Acceptance Criteria & Verification
```bash
# Execute simulated disaster recovery failover drill on Standby host:
./scripts/dr/failover-standby.sh --environment PROD --verify

# Expected Output:
# ⏱️ [FAILOVER] Restoring Golden Snapshot on Standby Node... (14s)
# 🚀 [FAILOVER] Starting Podman Containers db-proxy, db-publisher, app-ords... (8s)
# 🛡️ [FAILOVER] Checking SEPS Wallet connection: OK (2s)
# 🌐 [FAILOVER] Switching F5 VIP to Standby: SUCCESS (1s)
# 🎉 Total Failover Duration: 25s (SLA < 60s: MET)
```
