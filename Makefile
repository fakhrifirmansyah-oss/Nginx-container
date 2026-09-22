.PHONY: help run compose tofu test clean status

help:
	@echo "Perintah Cepat Nginx Container Deployment:"
	@echo "  make run      - Jalankan Task 1 (Podman Run, Port 8080)"
	@echo "  make compose  - Jalankan Task 2 (Podman Compose, Port 8081)"
	@echo "  make tofu     - Jalankan Task 3 (OpenTofu IaC, Port 8082)"
	@echo "  make test     - Test curl ke seluruh port"
	@echo "  make clean    - Hentikan & hapus semua container"
	@echo "  make status   - Tampilkan container yang sedang aktif"

run:
	@./run.sh run

compose:
	@./run.sh compose

tofu:
	@./run.sh tofu

test:
	@./run.sh test

clean:
	@./run.sh clean

status:
	@podman ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
