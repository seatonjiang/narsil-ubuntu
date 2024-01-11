**English** | [简体中文](README.zh-CN.md)

## 💻 Screenshot

### Script Execution

![script-execution](.github/script-execution.png)

### Login Information

![login-information](.github/login-information.png)

### Mount disk

![mount-disk](.github/mount-disk.png)

## ✨ Features

-   Password can be used for a maximum of 30 days.
-   After 30 days of password expiration, the account will be disabled.
-   The interval between two password changes is 1 day.
-   Warning 7 days before password expiration.
-   Set the system default encryption algorithm to SHA512.
-   Set a session timeout policy of 900 seconds.
-   Each created user will be given their own group.
-   The newly created user home directory permissions are changed to 0750.
-   Modify the permissions of the home directory of the stock user to 0750.
-   Remove useless users and packages.
-   Hardened OpenSSH config (Some configs need to be done manually).
-   Disable login for users without home directory.
-   Disable login by default for new users.
-   Disable apport and popular-contest statistics for uploading user information.
-   Disable ads in the welcome message.
-   Disable root account.
-   Disable synchronous deletion of user groups when deleting users.

There are many more settings that are not listed, and you can refer to the files in the `scripts` directory for more information.

## 🚀 Quick start

### Step 1: Clone the repo

Make sure you have Git installed on your server, otherwise you'll need to install the `git` software first.

```bash
git clone https://github.com/seatonjiang/narsil-ubuntu.git
```

### Step 2: Edit the config file

Go to project directory.

```bash
cd narsil-ubuntu/
```

Be sure to authenticate the contents of the config file.

```bash
vi narsil.conf
```

### Step 3: Running script

If you are root, you can run it directly, if you are a normal user please use `sudo` and you must run the script with `bash`.

```bash
sudo bash narsil.sh
```

## 📝 Config options

```ini
# Verify Operation
VERIFY='Y'

# Cloud Server Metadata Overlay (DNS Server/NTP Server/Hostname)
METADATA='Y'

# Production Environment Reminder
PROD_TIPS='Y'

# SSH Port Config
SSH_PORT='22'

# Time Zone Config
TIME_ZONE='Asia/Shanghai'

# Hostname Config
HOSTNAME='Ubuntu'

# DNS Server Config
DNS_SERVER='119.29.29.29 223.5.5.5'

# NTP Server Config
NTP_SERVER='ntp1.tencent.com ntp2.tencent.com ntp3.tencent.com ntp4.tencent.com ntp5.tencent.com'

# Docker Config
DOCKER_CE_REPO='https://mirrors.cloud.tencent.com/docker-ce'
DOCKER_HUB_MIRRORS='https://hub-mirror.c.163.com'
```

## 📂 Structure

A quick look at the folder structure of this project.

```bash
narsil-ubuntu
├── narsil.conf
├── narsil.sh
├── config
│   └── (some config files)
└── scripts
    └── (some script files)
```

## 🔨 Modular

Narsil contains a number of standalone functions that are not in the auto-executed script and need to be used separately using parameters, which can be viewed using the `sudo bash narsil.sh -h` for all standalone functions.

### Clear system

Clear all system logs, cache and backup files.

```bash
sudo bash narsil.sh -c
```

### Install docker

Install docker service and set registry mirrors, and add run permission for non-root accounts.

> After installation, please use `docker run hello-world` to test docker.

```bash
sudo bash narsil.sh -d
```

### Mount disk

Interactively mount the data disk, the data is priceless, remember to be careful during the operation!

> If the selected hard disk is already mounted, you will be prompted to unmount and format the operation.

```bash
sudo bash narsil.sh -f
```

### Modify hostname

The default is `Ubuntu`, if `METADATA=Y` then the default name is the name of the metadata fetch.

> The metadata feature is currently only supported on Tencent Cloud servers.

```bash
sudo bash narsil.sh -n
```

### Modify the SSH port

Interactively modify the SSH port.

> The port range is recommended to be between 10000 and 65535.

```bash
sudo bash narsil.sh -p
```

### Uninstall agent

Uninstalls various monitoring components installed into the server by the service provider.

> This feature is currently only supported on Tencent Cloud servers.

```bash
sudo bash narsil.sh -r
```

### Add swap space

If memory is too small, it is recommended to add swap space.

```bash
sudo bash narsil.sh -s
```

## 🤝 Contributing

We welcome all contributions. You can submit any ideas as Pull requests or as Issues, have a good time!

## 📃 License

The project is released under the MIT License, see the [LICENCE](https://github.com/seatonjiang/narsil-ubuntu/blob/main/LICENSE) file for details.
