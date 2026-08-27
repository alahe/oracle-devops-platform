| Veebiteenuse Nimi | Kontrollitud URL | HTTP Kood | TLS Usaldus | Staatus |
| :--- | :--- | :--- | :--- | :--- |
| ORDS Root HTTP | `http://localhost:8088/ords/` | `HTTP 302` | N/A | ✅ OK |
| ORDS Root HTTPS | `https://localhost:8448/ords/` | `HTTP 302` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (Default) | `https://localhost:8448/ords/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (PROXY) | `https://localhost:8448/ords/proxy/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 400` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (PROXY) | `https://localhost:8448/ords/proxy/apex_admin` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (PROXY) | `https://localhost:8448/ords/proxy/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| APEX Builder (LIS) | `https://localhost:8448/ords/lis/r/apex/workspace-sign-in/oracle-apex-sign-in` | `HTTP 400` | ⚠️ Self-Signed | ✅ OK |
| APEX Instance Admin (LIS) | `https://localhost:8448/ords/lis/apex_admin` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |
| ORDS Database Actions (LIS) | `https://localhost:8448/ords/lis/_/landing` | `HTTP 200` | ⚠️ Self-Signed | ✅ OK |

