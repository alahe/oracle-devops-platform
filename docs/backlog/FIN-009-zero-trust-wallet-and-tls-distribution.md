# Jira Story: FIN-009 — Zero-Trust SEPS Wallet & TLS Distribution Automation

| Field | Value |
|:---|:---|
| **Story ID** | FIN-009 |
| **Epic** | Security, Encryption & Credential Governance |
| **Component** | Oracle SEPS Wallet / TLS 1.3 / Security Engine |
| **Priority** | High |
| **Estimation** | **5 Story Points** |
| **Target Environments** | DEV, TEST, PROD |
| **Dependencies** | FIN-001 |

---

## 1. User Story
**As a** Chief Information Security Officer (CISO) & Security Architect,  
**I want to** establish an automated, secure distribution workflow for Oracle SEPS Auto-Login Wallets (`cwallet.sso`) and TLS certificates across all remote server nodes,  
**So that** no credentials are ever transmitted in cleartext or cached in plain configuration files, strictly enforcing Zero-Trust architecture across all environments.

---

## 2. Business Value & Financial Compliance
- **Zero-Trust Rule 5 & ISO 27001 (A.9.4):** Prevents credential scraping, memory snooping, and file permission bypasses.
- **Audit Immunity:** Cryptographic hardware-level passwordless authentication passes strict financial IT audits and penetration tests.

---

## 3. Technical Scope & Architecture

### Files Created / Modified:
1. `scripts/internal/distribute-remote-wallet.sh`: Securely transfers and sets POSIX permissions (`chmod 0600`) for wallet files on target nodes over encrypted SSH.
2. `scripts/certs/generate-remote-tls.sh`: Issues or imports enterprise CA-signed SAN TLS certificates for each host.
3. `scripts/check-wallet.sh`: Verifies remote wallet decryption without revealing secret contents.

---

## 4. Definition of Done (DoD)
- [ ] Wallet files (`cwallet.sso`, `ewallet.p12`) created with AES-256 encryption.
- [ ] Wallet files transferred strictly to protected system directories with `0600` permissions.
- [ ] No plaintext database passwords present in `.env`, `.yml`, `.xml`, or script files on any host.
- [ ] TLS certificate on ORDS (8448) and Publisher (9502) verified with valid hostname matching SAN.
- [ ] Credential rotation tested: rotating password via `rotate-password.sh` propagates seamlessly.

---

## 5. Acceptance Criteria & Verification
```bash
# Verify wallet permissions and passwordless connectivity on remote ORDS host:
ssh opc@ords-dev.corp.bank "ls -la /etc/ords/wallet/cwallet.sso"

# Expected Output:
# -rw------- 1 opc opc 5632 Sep 07 14:00 /etc/ords/wallet/cwallet.sso
```
