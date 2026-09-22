#!/usr/bin/env bash
# ========================================================
# Helper Script: Nginx Container Deployment Manager
# ========================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

run_podman() {
    print_step "Menjalankan Metode 1: Podman Run (Port 8080)..."
    cd "$DIR/podman-run"
    podman rm -f nginx-run 2>/dev/null || true
    podman run -d \
        --name nginx-run \
        -p 8080:80 \
        -v "$DIR/podman-run/index.html:/usr/share/nginx/html/index.html:Z" \
        nginx:alpine
    sleep 1
    echo -e "${YELLOW}Testing curl http://localhost:8080 :${NC}"
    curl -s http://localhost:8080 | head -n 10
    echo -e "\n${GREEN}✔ Sukses berjalan di http://localhost:8080${NC}"
}

run_compose() {
    print_step "Menjalankan Metode 2: Podman Compose (Port 8081)..."
    cd "$DIR/podman-compose"
    podman-compose down 2>/dev/null || true
    podman-compose up -d
    sleep 2
    echo -e "${YELLOW}Testing curl http://localhost:8081 :${NC}"
    curl -s http://localhost:8081 | head -n 10
    echo -e "\n${GREEN}✔ Sukses berjalan di http://localhost:8081${NC}"
}

run_tofu() {
    print_step "Menjalankan Metode 3: OpenTofu (Port 8082)..."
    systemctl --user start podman.socket 2>/dev/null || true
    cd "$DIR/opentofu"
    tofu init -upgrade
    tofu apply -auto-approve
    sleep 2
    echo -e "${YELLOW}Testing curl http://localhost:8082 :${NC}"
    curl -s http://localhost:8082 | head -n 10
    echo -e "\n${GREEN}✔ Sukses berjalan di http://localhost:8082${NC}"
}

clean_all() {
    print_step "Membersihkan semua container..."
    echo "1. Cleaning Podman Run..."
    podman rm -f nginx-run 2>/dev/null || true

    echo "2. Cleaning Podman Compose..."
    (cd "$DIR/podman-compose" && podman-compose down 2>/dev/null) || true

    echo "3. Cleaning OpenTofu..."
    (cd "$DIR/opentofu" && tofu destroy -auto-approve 2>/dev/null) || true

    echo -e "${GREEN}✔ Semua container telah dibersihkan!${NC}"
}

test_all() {
    print_step "Testing koneksi semua port..."
    echo -n "Port 8080 (Podman Run):     "
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080 || echo "Offline"
    echo -n "Port 8081 (Podman Compose): "
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8081 || echo "Offline"
    echo -n "Port 8082 (OpenTofu):       "
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8082 || echo "Offline"
}

show_menu() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "   ${GREEN}Nginx Container Manager (WSL Ubuntu)${NC}"
    echo -e "${BLUE}==============================================${NC}"
    echo "1) Jalankan Podman Run      (Port 8080)"
    echo "2) Jalankan Podman Compose  (Port 8081)"
    echo "3) Jalankan OpenTofu        (Port 8082)"
    echo "4) Cek Status & Curl Semua Port"
    echo "5) Bersihkan / Stop Semua Container"
    echo "0) Keluar"
    echo -n "Pilih opsi [0-5]: "
    read -r choice
    case "$choice" in
        1) run_podman ;;
        2) run_compose ;;
        3) run_tofu ;;
        4) test_all ;;
        5) clean_all ;;
        0) exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid!${NC}" ;;
    esac
}

case "$1" in
    1|run|podman-run)     run_podman ;;
    2|compose|podman-compose) run_compose ;;
    3|tofu|opentofu)      run_tofu ;;
    4|test)               test_all ;;
    5|clean|stop)         clean_all ;;
    *)                    show_menu ;;
esac
