## Overclocking the Raspberry Pi 4

Overclock the Raspberry Pi 4 if you wish

```bash
sudo nano /boot/config.txt
```

I found the following settings stable running Raspberry Pi OS 32 Bit (Raspbian) on my Raspberry Pi 4 4GB.

```text
over_voltage=6
arm_freq=2000
gpu_freq=700
```

## Raspberry Pi 4 Boot from USB

At the time of writing Raspberry Pi 4 boot from USB was in beta. See [How to Boot Raspberry Pi 4 From a USB SSD or Flash Drive](https://www.tomshardware.com/how-to/boot-raspberry-pi-4-usb) for more information.
