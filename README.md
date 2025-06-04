# PI-IB-2025

TESIS:
[Tesis](./docs/Tesis/PI_main.pdf)

camkes-vm-examples-manifest:
```yaml
    repo init https://github.com/adl09/camkes-vm-examples-manifest.git
    repo sync
```
Modified default.xml to use the following forked repositories:
```yaml
    https://github.com/adl09/camkes-vm-examples.git
    https://github.com/adl09/camkes-vm.git
```

Changes are updated to those repositories using:
```yaml
    git submodule add -f https://github.com/adl09/camkes-vm-examples.git camkes-vm-examples-manifest/projects/vm-examples
    git submodule add -f https://github.com/adl09/camkes-vm.git camkes-vm-examples-manifest/projects/vm
```

