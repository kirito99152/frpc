# Hướng dẫn cài đặt dịch vụ frpc với systemd

Tài liệu này hướng dẫn cách cài đặt frpc như một dịch vụ systemd trên Linux, giúp nó tự động chạy khi khởi động và tự khởi động lại khi có lỗi.

## Yêu cầu
- Hệ điều hành Linux hỗ trợ `systemd` (ví dụ: Ubuntu, CentOS 7+, Debian 8+).
- Bạn có quyền `sudo` hoặc `root` trên hệ thống.
- Các tệp `frpc`, `frpc.yaml`, và `install_service.sh` đã có sẵn.

## Cấu trúc thư mục yêu cầu
Để tập lệnh cài đặt hoạt động chính xác, hãy đảm bảo các tệp sau nằm trong cùng một thư mục:
/your_chosen_directory/
|-- frpc              (tệp thực thi)
|-- frpc.yaml         (tệp cấu hình)
|-- install_service.sh  (tệp cài đặt)

---

## Các bước cài đặt

### Bước 1: Chuẩn bị các tệp cần thiết
Nếu bạn vừa giải nén tệp `frp_...tar.gz`, tệp `frpc` sẽ nằm trong một thư mục con. Hãy di chuyển nó ra ngoài.

Mở terminal và di chuyển đến thư mục chứa các tệp của bạn, sau đó chạy lệnh:
```bash
# Di chuyển tệp frpc ra thư mục hiện tại
mv frp_0.64.0_linux_amd64/frpc .
```
Lệnh này giả định bạn đang ở trong thư mục `/root/frpc`. Sau bước này, bạn sẽ có các tệp `frpc`, `frpc.yaml`, `install_service.sh` nằm cạnh nhau.

### Bước 2: Cấp quyền thực thi cho tập lệnh cài đặt
Tập lệnh `install_service.sh` cần được cấp quyền để có thể chạy.
```bash
chmod +x install_service.sh
```

### Bước 3: Chạy tập lệnh cài đặt với quyền sudo
Tập lệnh sẽ tự động tạo tệp dịch vụ, đặt đúng đường dẫn, và khởi chạy dịch vụ cho bạn.
```bash
sudo ./install_service.sh
```
Sau khi chạy, tập lệnh sẽ thông báo các bước nó đã thực hiện.

---

## Quản lý dịch vụ

### Kiểm tra trạng thái dịch vụ
Để xem dịch vụ có đang chạy ổn định hay không:
```bash
systemctl status frpc.service
```
Nếu dịch vụ đang chạy, bạn sẽ thấy trạng thái `active (running)`.

### Xem log của dịch vụ
Để theo dõi log hoạt động của `frpc` trong thời gian thực:
```bash
journalctl -u frpc.service -f
```
Nhấn `Ctrl + C` để thoát.

### Khởi động lại dịch vụ
Nếu bạn thay đổi tệp `frpc.yaml` và muốn áp dụng cấu hình mới:
```bash
sudo systemctl restart frpc.service
```

---

## Gỡ cài đặt
Nếu bạn không muốn sử dụng dịch vụ này nữa, hãy làm theo các bước sau để gỡ bỏ hoàn toàn.

1.  **Dừng dịch vụ:**
    ```bash
    sudo systemctl stop frpc.service
    ```
2.  **Vô hiệu hóa dịch vụ (để nó không tự khởi động lại):**
    ```bash
    sudo systemctl disable frpc.service
    ```
3.  **Xóa tệp dịch vụ:**
    ```bash
    sudo rm /etc/systemd/system/frpc.service
    ```
4.  **Tải lại cấu hình systemd:**
    ```bash
    sudo systemctl daemon-reload
    ```

Dịch vụ đã được gỡ bỏ hoàn toàn khỏi hệ thống.
