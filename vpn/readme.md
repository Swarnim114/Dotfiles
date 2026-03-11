# ProtonVPN Setup (CachyOS / Hyprland)

## Context
The official ProtonVPN GTK app crashes on Python 3.14 due to a kill switch timeout bug.
This setup uses NetworkManager + OpenVPN directly, bypassing the broken app entirely.

## Files
| File | Destination |
|------|-------------|
| `sg-free-11.protonvpn.tcp.nmconnection` | `/etc/NetworkManager/system-connections/` |
| `sg-free-11.protonvpn.tcp-ca.pem` | `/home/USERNAME/.local/share/networkmanagement/certificates/nm-openvpn/` |
| `sg-free-11.protonvpn.tcp-tls-crypt.pem` | `/home/USERNAME/.local/share/networkmanagement/certificates/nm-openvpn/` |

---

## Connection File
Save as `/etc/NetworkManager/system-connections/sg-free-11.protonvpn.tcp.nmconnection`

```ini
[connection]
id=sg-free-11.protonvpn.tcp
uuid=bfe98102-2c49-4d0c-a3d6-978badd70506
type=vpn

[vpn]
ca=/home/USERNAME/.local/share/networkmanagement/certificates/nm-openvpn/sg-free-11.protonvpn.tcp-ca.pem
cipher=AES-256-GCM
connection-type=password
dev=tun
mssfix=0
password-flags=0
proto-tcp=yes
remote=149.50.211.154:443, 149.50.211.154:8443, 149.50.211.154:7770
remote-cert-tls=server
remote-random=yes
reneg-seconds=0
tls-crypt=/home/USERNAME/.local/share/networkmanagement/certificates/nm-openvpn/sg-free-11.protonvpn.tcp-tls-crypt.pem
tunnel-mtu=1500
service-type=org.freedesktop.NetworkManager.openvpn
user-name=YOUR_OPENVPN_USERNAME

[vpn-secrets]
password=YOUR_OPENVPN_PASSWORD

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
```

> Replace `USERNAME`, `YOUR_OPENVPN_USERNAME`, and `YOUR_OPENVPN_PASSWORD` with your actual values.
> Get OpenVPN credentials from: https://account.proton.me/u/0/vpn/OpenVpnIKEv2

---

## Install on a New Machine

### 1. Install dependencies
```bash
sudo pacman -S networkmanager-openvpn openvpn
```

### 2. Copy cert files
```bash
mkdir -p ~/.local/share/networkmanagement/certificates/nm-openvpn/
cp sg-free-11.protonvpn.tcp-ca.pem ~/.local/share/networkmanagement/certificates/nm-openvpn/
cp sg-free-11.protonvpn.tcp-tls-crypt.pem ~/.local/share/networkmanagement/certificates/nm-openvpn/
```

### 3. Copy and secure the connection file
```bash
sudo cp sg-free-11.protonvpn.tcp.nmconnection /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/sg-free-11.protonvpn.tcp.nmconnection
sudo nmcli connection reload
```

### 4. Add aliases to ~/.zshrc
```bash
alias vpnon='nmcli connection up sg-free-11.protonvpn.tcp'
alias vpnoff='nmcli connection down sg-free-11.protonvpn.tcp'
alias vpnstatus='nmcli connection show --active | grep vpn'
```

```bash
source ~/.zshrc
```

---

## Usage
```bash
vpnon           # connect instantly, no password prompt
vpnoff          # disconnect
vpnstatus       # check if connected
curl ipinfo.io  # verify IP and location
```

---

## Notes
- Server: ProtonVPN Singapore Free (SG-FREE#11)
- Protocol: OpenVPN TCP
- Password is stored in plaintext in the .nmconnection file — keep your dotfiles repo **PRIVATE**
- If connection stops working, get a fresh .ovpn from ProtonVPN dashboard and redo setup
- To add more servers, download a new .ovpn and run:
```bash
nmcli connection import type openvpn file ~/Downloads/newserver.ovpn
```
Then edit the new .nmconnection file to set `password-flags=0` and add `[vpn-secrets]` section as above.
