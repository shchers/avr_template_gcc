# Basic template for fast start with AVR uControllers in GCC

## Dependencies
  * Install AVR GCC toolchain
```
sudo apt install -y gcc-avr binutils-avr avr-libc
```
  * Install Avrdude for flashing
```
sudo apt install -y avrdude
```

## AVRmkII support
Avrdude support AVRmkII out of the box, but special rules for used still required:
  * Create rules file
```
echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-avr.rules
```
  * Update udev with new rules
```
sudo service udev restart
sudo udevadm trigger
```

## Building Avrdude from source code
  * Go to http://download.savannah.gnu.org/releases/avrdude/
  * Download latest version, in my case it is avrdude-6.3
```
wget http://download.savannah.gnu.org/releases/avrdude/avrdude-6.3.tar.gz
```
  * Extract archive
```
tar -xvf avrdude-6.3.tar.gz
cd avrdude-6.3
```
  * Run configuration script
```
./configure
```
  * Fix all dependencies. For example you will have the next output:
```
...
Configuration summary:
----------------------
DON'T HAVE libelf
DON'T HAVE libusb
DON'T HAVE libusb_1_0
DON'T HAVE libftdi1
DON'T HAVE libftdi
DON'T HAVE libhid
DO HAVE    pthread
DISABLED   doc
ENABLED    parport
DISABLED   linuxgpio
...
```

To support with AVRmkII we need to have USB support and ELF files support very required.
So, use apt and install these dependencies:
```
sudo apt install -y libelf-dev libusb-1.0-0-dev libusb-dev
``` 

Recheck. Output should be the next:
```
./configure
...
Configuration summary:
----------------------
DO HAVE    libelf
Do HAVE    libusb
DO HAVE    libusb_1_0
DON'T HAVE libftdi1
DON'T HAVE libftdi
DON'T HAVE libhid
DO HAVE    pthread
DISABLED   doc
ENABLED    parport
DISABLED   linuxgpio
...
```

  * Build avrdude
```
make -j$(nproc)
```

  * Make sure that avrdude installed using apt was removed, to avoid mess:
```
sudo apt purge avrdude
```

  * Install our version of Avrdude (by default binaries will be dropped to /usr/local/bin)
```
sudo make install
```
