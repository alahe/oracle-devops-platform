#!/usr/bin/env bash
# ============================================================================
# Oracle eDelivery Download Script for macOS / Linux
# Downloads V1055080-01.zip and V1045135-01.zip into binaries/publisher/
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

LANG=C
export LANG

OUTPUT_DIR="$WORKSPACE_DIR/binaries/publisher"
mkdir -p "$OUTPUT_DIR"

LOGDIR="$WORKSPACE_DIR/install_logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/publisher_download_$(date +%Y%m%d_%H%M%S).log"

log_info() {
   echo "[INFO] [$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

log_error() {
   echo "[ERROR] [$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE" >&2
}

ACCESS_TOKEN="eyJ4NXQjUzI1NiI6InVMYjc0SjlySGUxR1JISzZYZHFCcGh1cjlQb1drdmlFdjZNRC16NnBQRTgiLCJ4NXQiOiJtd2J0Zm9GTFBSVFRYUndfYXRsNENoUmwwSWciLCJraWQiOiJTSUdOSU5HX0tFWSIsImFsZyI6IlJTMjU2In0.eyJjbGllbnRfb2NpZCI6Im9jaWQxLmRvbWFpbmFwcC5vYzEudXMtY2hpY2Fnby0xLmFtYWFhYWFhYXF0cDViYWF3cmpxaWVyYWo2ZTRmbWIyYnhzbGt3czM3NXltbDNkN215anlycTVzc2lsYSIsInVzZXJfdHoiOiJBbWVyaWNhL0NoaWNhZ28iLCJzdWIiOiJhbGxhbi5sYWhlQHN3ZWRiYW5rLmVlIiwidXNlcl9sb2NhbGUiOiJlbiIsInNpZGxlIjo4ODAsImlkcF9uYW1lIjoiVXNlck5hbWVQYXNzd29yZCIsInVzZXIudGVuYW50Lm5hbWUiOiJsb2dpbi1leHQiLCJpZHBfZ3VpZCI6IlVzZXJOYW1lUGFzc3dvcmQiLCJhbXIiOlsiVVNFUk5BTUVfUEFTU1dPUkQiLCJTTVMiXSwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiZG9tYWluX2hvbWUiOiJ1cy1jaGljYWdvLTEiLCJjYV9vY2lkIjoib2NpZDEudGVuYW5jeS5vYzEuLmFhYWFhYWFhbDNvbWg2d3RzeXdyZzNoeXYzNnZjbGF2YTU3NDN3ZXo0anB1YmRuazJsaTd0NjJ2NDY3YSIsInVzZXJfdGVuYW50bmFtZSI6ImxvZ2luLWV4dCIsImNsaWVudF9pZCI6IjRiMzQxMGZjZjMyMDRhNDc4NDhlNzc0NmI1ZGJiODkyIiwic2lkIjoiN2I4NDNiYmVmMDY3NGFlODllYTM0NTFhNjZiMGYyMWY6YzQ0ZWE4IiwiZG9tYWluX2lkIjoib2NpZDEuZG9tYWluLm9jMS4uYWFhYWFhYWFkYXl0cHRhdTdtemh2ZDd0ZnRzNnVsMmZ5ZTVqZ3hqaDRzeHk0aWRkNzI1NmppMmUzampxIiwic3ViX3R5cGUiOiJ1c2VyIiwic2NvcGUiOiJyZXN0LmRvd25sb2FkcyBvcGVuaWQiLCJ1c2VyX29jaWQiOiJvY2lkMS51c2VyLm9jMS4uYWFhYWFhYWE0d3R5amZ4aGdleDVrM2M0dGVpdGFxbGhnc3R0ZXJpbXRuZzU2M3F4a2N2bWdyanNrdmVhIiwiY2xpZW50X3RlbmFudG5hbWUiOiJsb2dpbi1leHQiLCJyZWdpb25fbmFtZSI6InVzLWNoaWNhZ28taWRjcy0yIiwidXNlcl9sYW5nIjoiZW4iLCJleHAiOjE3ODcyMTY5MjQsImlhdCI6MTc4NzIxMzMyNCwiY2xpZW50X2d1aWQiOiJiMTA2NTNmMzllNDI0ZjAyOTcwZDJhMzAwMTU5MzFjMyIsImNsaWVudF9uYW1lIjoib3NkY19kb3dubG9hZHNfcHJvZF9jbGllbnQiLCJpZHBfdHlwZSI6IkxPQ0FMIiwidGVuYW50IjoibG9naW4tZXh0IiwianRpIjoiYzhiZGI2MzJkYTk5NDJjOGExM2E2YjhkYjk3OWRmYTIiLCJndHAiOiJhemMiLCJ1c2VyX2Rpc3BsYXluYW1lIjoiIiwib3BjIjpmYWxzZSwic3ViX21hcHBpbmdhdHRyIjoidXNlck5hbWUiLCJwcmltVGVuYW50IjpmYWxzZSwidG9rX3R5cGUiOiJBVCIsImNhX2d1aWQiOiJsb2dpbi1leHQiLCJhdWQiOlsiaHR0cHM6Ly9sb2dpbi1leHQuaWRlbnRpdHkub3JhY2xlY2xvdWQuY29tOjQ0MyIsImVkZWxpdmVyeS8iXSwiY2FfbmFtZSI6ImNvcnBleHRlcm5hbHByb2QiLCJ1c2VyX2lkIjoiM2U1YmU3NDI3YTcwNDdkMGJiMGY2MzNkZDJmYjdjMWUiLCJkb21haW4iOiJDb3JwRXh0ZXJuYWxQcm9kIiwidGVuYW50X2lzcyI6Imh0dHBzOi8vbG9naW4tZXh0LmlkZW50aXR5Lm9yYWNsZWNsb3VkLmNvbTo0NDMiLCJyZXNvdXJjZV9hcHBfaWQiOiI4ZmY2NTZhNTcwYjE0ZjQ0OTc5MGQ0OTJkMjFkNTc1ZCJ9.bQcpMdMAf5FOwdlMnKeg34cvOx4NbQB5_uXz8pdd4X4LdKhvucjLezrGGi7WWf8xruG_JyRLD0mYTLwgV_xi6xS4NFGuNLLCqfB9oY7i9oUzD-Me0gObf-DSYE5ASzV5gW90QODW_BuvOOWR20JCBWmbn_NiDwD9rDQ06M6wx36v4Rje5Ku13um59yUmCwHxOl8ZzgrZbXYYu4350nksRoFMVB2z5JFmXbl5UosbXzU5GBuyNL7MscV5FuAhmbMoy3_6vghT6xShHERaHYNDox1W1-RL08A5Y7IT7gUJpdfye5YmSnax42D09n55EXUOnfOcz6NM6cD1ve7sEomXRw"

download_file() {
   FILE="$1"
   URL="$2"
   log_info "Download initiated for: $FILE into $OUTPUT_DIR/$FILE"
   if command -v curl >/dev/null 2>&1; then
      curl -L -H "Authorization: Bearer $ACCESS_TOKEN" -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36" --progress-bar "$URL" -o "$OUTPUT_DIR/$FILE"
      log_info "Download completed: $FILE"
   elif command -v wget >/dev/null 2>&1; then
      wget --header="Authorization: Bearer $ACCESS_TOKEN" --user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" -nv --show-progress "$URL" -O "$OUTPUT_DIR/$FILE"
      log_info "Download completed: $FILE"
   else
      log_error "Neither curl nor wget is installed!"
      exit 1
   fi
}

log_info "==== Oracle eDelivery Download Started ===="

download_file "V1055080-01.zip" "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1055080-01.zip&token=TFNtVHlSRDFCSU16TCtVVXhIVWVXUSE6OiFmaWxlSWQ9MTI4MTYyNzUzJmZpbGVTZXRDaWQ9MTIxNjY5OCZyZWxlYXNlQ2lkcz0xMjEwMTEyJnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTI5ODA3NzgmZW1haWxBZGRyZXNzPWFsbGFuLmxhaGVAc3dlZGJhbmsuZWUmdXNlck5hbWU9RVBELUFMTEFOLkxBSEVAU1dFREJBTksuRUUmaXBBZGRyZXNzPTkwLjE5MS4xNDkuMTEmdXNlckFnZW50PU1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS8xNTEuMC4wLjAgU2FmYXJpLzUzNy4zNiZjb3VudHJ5Q29kZT1FRSZkbHBDaWRzPTEyMTcwMzY"
download_file "V1045135-01.zip" "https://edelivery.oracle.com/osdc/softwareDownload?fileName=V1045135-01.zip&token=bHcrWWFJYVhuMVQvV3pTYVUrWVEydyE6OiFmaWxlSWQ9MTE5NTc5MjI2JmZpbGVTZXRDaWQ9MTE2NjIxMSZyZWxlYXNlQ2lkcz0xMDA3NDcwJnBsYXRmb3JtQ2lkcz0zNSZkb3dubG9hZFR5cGU9OTU3NjQmYWdyZWVtZW50SWQ9MTI5ODA3NzgmZW1haWxBZGRyZXNzPWFsbGFuLmxhaGVAc3dlZGJhbmsuZWUmdXNlck5hbWU9RVBELUFMTEFOLkxBSEVAU1dFREJBTksuRUUmaXBBZGRyZXNzPTkwLjE5MS4xNDkuMTEmdXNlckFnZW50PU1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzUzNy4zNiAoS0hUTUwsIGxpa2UgR2Vja28pIENocm9tZS8xNTEuMC4wLjAgU2FmYXJpLzUzNy4zNiZjb3VudHJ5Q29kZT1FRSZkbHBDaWRzPTEyMTcwMzY"

log_info "==== Oracle eDelivery Download Finished ===="
