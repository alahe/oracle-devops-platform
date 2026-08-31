| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 000` | N/A | ❌ Kättesaamatu |
| Developer Hub (HTTPS) | `https://localhost:8448/dev-hub.html` | `HTTP 200` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 404` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 404` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 404` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (ALISE) | `https://localhost:8448/ords/alise/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| APEX Instance Admin (ALISE) | `https://localhost:8448/ords/alise/apex_admin` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| ORDS Database Actions (ALISE) | `https://localhost:8448/ords/alise/_/landing` | `HTTP 574` | ⚠️ Self-Signed | ❌ Kättesaamatu |
| Publisher UI (HTTP) | `http://localhost:9502/xmlpserver` | `HTTP 000` | N/A | ❌ Kättesaamatu |

