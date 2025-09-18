#!/bin/bash

# Script to create and install a systemd service for frpc
# This script must be run with sudo privileges

# --- Configuration ---
SERVER_ADDR="160.191.50.208"
SERVER_PORT="7000"
SERVICE_NAME="frpc.service"
# ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Lỗi: Vui lòng chạy tập lệnh này với quyền root (sử dụng sudo)."
  exit 1
fi

# 2. Determine the script's absolute directory
# This will be used as the WorkingDirectory for the service.
# All other paths (frpc, frpc.yaml) will be relative to this.
FRP_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Ensure frpc executable and config file exist
if [ ! -f "${FRP_DIR}/frpc" ]; then
    echo "Lỗi: Không tìm thấy tệp thực thi 'frpc' trong thư mục ${FRP_DIR}"
    exit 1
fi

if [ ! -f "${FRP_DIR}/frpc.yaml" ]; then
    echo "Lỗi: Không tìm thấy tệp cấu hình 'frpc.yaml' trong thư mục ${FRP_DIR}"
    exit 1
fi

# 3. Create the systemd service file content
echo "Đang tạo tệp dịch vụ systemd tại /etc/systemd/system/${SERVICE_NAME}..."

# Using a heredoc to create the service file content
cat > /etc/systemd/system/${SERVICE_NAME} << EOL
[Unit]
Description=FRP Client Service
Wants=network-online.target
After=network-online.target systemd-resolved.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=${FRP_DIR}

# Wait for the frps server to be reachable before starting (max ~60s)
ExecStartPre=/bin/sh -c 'for i in \$(seq 1 30); do nc -z -w2 ${SERVER_ADDR} ${SERVER_PORT} && exit 0; sleep 2; done; exit 1'

# Run frpc using the YAML config file
ExecStart=${FRP_DIR}/frpc -c ${FRP_DIR}/frpc.yaml

# Restart the service automatically on failure
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOL

# 4. Reload systemd, enable and start the service
echo "Tải lại systemd daemon..."
systemctl daemon-reload

echo "Kích hoạt dịch vụ frpc để khởi động cùng hệ thống..."
systemctl enable ${SERVICE_NAME}

echo "Khởi động dịch vụ frpc..."
systemctl start ${SERVICE_NAME}

# 5. Provide feedback
echo "Hoàn tất!"
echo "Dịch vụ frpc đã được cài đặt và đang chạy."
echo "Bạn có thể kiểm tra trạng thái bằng lệnh: systemctl status ${SERVICE_NAME}"
echo "Để xem log, bạn có thể dùng: journalctl -u ${SERVICE_NAME} -f"
