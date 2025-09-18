# Hướng dẫn Cài đặt Dịch vụ `frpc` qua `systemd`

Dự án này cung cấp một tập lệnh để tự động cài đặt `frpc` (máy khách của `frp`) như một dịch vụ `systemd` trên Linux. Việc này đảm bảo `frpc` sẽ tự động khởi chạy khi hệ thống bật và tự động khởi động lại nếu gặp lỗi.

## 🚀 Tính năng
- **Cài đặt tự động**: Một tập lệnh duy nhất để cài đặt dịch vụ.
- **Tự động khởi động**: Dịch vụ tự chạy khi boot.
- **Tự động phục hồi**: Tự khởi động lại `frpc` nếu nó bị dừng đột ngột.
- **Cấu trúc linh hoạt**: Tập lệnh tự động xác định đường dẫn làm việc.

## 📋 Yêu cầu
- Hệ điều hành Linux có `systemd` (ví dụ: Ubuntu, CentOS 7+, Debian 8+).
- Quyền `sudo` hoặc `root`.
- Các tệp `frpc`, `frpc.yaml`, và `install_service.sh` đã được chuẩn bị.

## 📂 Cấu trúc Thư mục Yêu cầu
Để tập lệnh hoạt động chính xác, hãy đảm bảo các tệp sau nằm trong cùng một thư mục:

```
/your-frpc-directory/
├── frpc              (Tệp thực thi)
├── frpc.yaml         (Tệp cấu hình)
└── install_service.sh  (Tệp cài đặt)
```

---

## 🛠️ Hướng dẫn Cài đặt

### Bước 1: Chuẩn bị các Tệp
Tải file `frpc_package.tar.gz` về và giải nén.
Sau bước này, bạn sẽ có các tệp `frpc`, `frpc.yaml`, `install_service.sh` nằm cạnh nhau.

### Bước 2: Cấp quyền Thực thi cho Tập lệnh
Tập lệnh `install_service.sh` cần được cấp quyền để có thể chạy.

```bash
chmod +x install_service.sh
```

### Bước 3: Chạy Tập lệnh Cài đặt
Sử dụng `sudo` để chạy tập lệnh. Nó sẽ tự động tạo tệp dịch vụ, đặt đúng đường dẫn, và khởi chạy dịch vụ cho bạn.

```bash
sudo ./install_service.sh
```
Tập lệnh sẽ hiển thị các bước mà nó đang thực hiện.

---

## 📝 Hướng dẫn Cấu hình `frpc.yaml`
Phần quan trọng nhất để `frpc` hoạt động là cấu hình các `proxies`. Dưới đây là một số ví dụ phổ biến.

### Ví dụ 1: Proxy TCP chung (ví dụ: Remote Desktop, Game Server)
Proxy này chuyển tiếp một cổng TCP từ máy local ra một cổng public trên VPS.

```yaml
proxies:
  - name: win_web
    type: tcp
    localIP: 127.0.0.1
    localPort: 80              # Cổng của dịch vụ trên máy local (ví dụ: web server)
    remotePort: 12345          # Cổng public trên VPS (chọn một cổng chưa được sử dụng)
```
- **name**: Tên định danh cho proxy, không được trùng lặp.
- **type**: `tcp` cho các kết nối TCP.
- **localPort**: Cổng dịch vụ đang chạy trên máy của bạn.
- **remotePort**: Cổng bạn sẽ truy cập từ bên ngoài thông qua IP của VPS.

### Ví dụ 2: Proxy cho SQL Server
Tương tự như proxy TCP chung, nhưng dành riêng cho việc expose cổng- **`1433`** của SQL Server.

```yaml
proxies:
  - name: NoiBo52SqlServer
    type: tcp
    localIP: 127.0.0.1
    localPort: 1433          # Cổng mặc định của SQL Server
    remotePort: 21433        # Cổng public trên VPS
```

### Ví dụ 3: Proxy HTTP/HTTPS với Tên miền Tùy chỉnh
Loại proxy này cho phép bạn truy cập một trang web local thông qua một tên miền đã được trỏ DNS về IP của VPS. `frps` (trên VPS) cần được cấu hình để lắng nghe trên các cổng vhost (ví dụ `vhostHTTPPort = 8080`).

```yaml
proxies:
  - name: NoiBo52_web
    type: http
    localIP: 127.0.0.1
    localPort: 81              # Cổng web server đang chạy local
    customDomains:
      - tkb.c500.site          # Tên miền bạn muốn sử dụng
```
- **type**: `http` hoặc `https`
- **localPort**: Cổng của web server local (ví dụ: 80, 81, 8080).
- **customDomains**: Tên miền đã được trỏ A-Record đến IP của VPS. Khi truy cập tên miền này, `frps` sẽ tự động chuyển hướng traffic đến máy local của bạn.

---

## ⚙️ Quản lý Dịch vụ

### Kiểm tra Trạng thái
Để xem dịch vụ có đang chạy ổn định hay không:
```bash
systemctl status frpc.service
```
Trạng thái `active (running)` màu xanh lá cho biết dịch vụ đang hoạt động tốt.

### Xem Log
Để theo dõi log hoạt động của `frpc` trong thời gian thực:
```bash
journalctl -u frpc.service -f
```
Nhấn `Ctrl + C` để thoát khỏi chế độ xem log.

### Khởi động lại Dịch vụ
Nếu bạn thay đổi tệp cấu hình `frpc.yaml`, hãy khởi động lại dịch vụ để áp dụng thay đổi:
```bash
sudo systemctl restart frpc.service
```

---

## 🗑️ Hướng dẫn Gỡ Cài đặt
Nếu bạn không muốn sử dụng dịch vụ nữa, hãy làm theo các bước sau để gỡ bỏ hoàn toàn.

1.  **Dừng dịch vụ:**
    ```bash
    sudo systemctl stop frpc.service
    ```
2.  **Vô hiệu hóa dịch vụ (để không tự khởi động lại khi boot):**
    ```bash
    sudo systemctl disable frpc.service
    ```
3.  **Xóa tệp dịch vụ:**
    ```bash
    sudo rm /etc/systemd/system/frpc.service
    ```
4.  **Tải lại cấu hình `systemd`:**
    ```bash
    sudo systemctl daemon-reload
    ```
Dịch vụ `frpc` đã được gỡ bỏ hoàn toàn khỏi hệ thống của bạn.
