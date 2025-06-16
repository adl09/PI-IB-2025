# Custom-VM-Kernel Tutorial

This tutorial guides you through building the necessary files to use a Linux 4.9.337+ kernel with Wireguard as a VM in CAmkES examples.

## Steps:

### 1. Buildroot Setup

Clone Buildroot and build the root filesystem using the provided configuration (we need the 2023.11 version for compatibility with 4.9 kernels):

```sh
git clone --branch 2023.11 --depth 1 https://github.com/buildroot/buildroot.git
cp .buildroot-config ./buildroot/.config
cd buildroot
make -j$(nproc)
cd ..
```

### 2. Clone the Linux Kernel Source

```sh
git clone --branch linux-4.9.y --single-branch --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
```

### 3. Add Wireguard Support

Clone the Wireguard compatibility layer and apply it to the kernel tree:

```sh
git clone https://git.zx2c4.com/wireguard-linux-compat
./wireguard-linux-compat/kernel-tree-scripts/jury-rig.sh ./linux-stable
```

### 4. Configure and Build the Kernel using the provided configuration

```sh
cp .linux-config ./linux-stable/.config
cd linux-stable
make -j$(nproc)
cd ..
```

## Output

After completing these steps, you will find the required images at:

- Kernel image: `./linux-stable/arch/x86/boot/bzImage`
- Root filesystem: `./buildroot/output/images/rootfs.cpio`