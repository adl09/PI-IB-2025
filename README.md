# PI-IB-2025

This tutorial guides you through replicating the setup used in this project.

## 1. Download the Thesis

You can find the thesis document here:  
[Tesis](./docs/Tesis/PI_main.pdf)

## 2. Clone the camkes-vm-examples-manifest

Initialize and sync the modified repository:

```sh
repo init -u https://github.com/adl09/camkes-vm-examples-manifest.git
repo sync
```
This repository uses a modified version of the `camkes-vm-examples-manifest` repository, with `default.xml` changed to include the modified `camkes-vm-examples` and `camkes-vm` repositories. This allows you to build the examples with the necessary modifications for this project.

It includes the following forked repositories:

- https://github.com/adl09/camkes-vm-examples.git
- https://github.com/adl09/camkes-vm.git

# Custom-VM-Kernel Tutorial
For instructions on building and using the custom VM kernel, see the [Custom-VM-Kernel README](./custom-vm-kernel/README.md).
