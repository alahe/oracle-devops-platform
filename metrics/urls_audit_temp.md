| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 574` | N/A | ✅ OK |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 574` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Builder (ALISE) | `https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 574` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (ALISE) | `https://localhost:8448/ords/alise/apex_admin` | `HTTP 574` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (ALISE) | `https://localhost:8448/ords/alise/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Web IDE (HTTP) | `http://localhost:8090` | `HTTP 200` | N/A | ✅ OK |

