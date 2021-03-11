# Windows Server 2019

This Vagrant project provisions Windows 2019 Server with Active Directory automatically, using Vagrant, a Windows 2019 Server box and several powershell scripts. This VM can also be used in conjunction with Docker based Oracle Engineering ([oehrlis/doe](https://github.com/oehrlis/doe)). A perfect companion when you plan to test *Oracle Centrally Managed Users* with your Docker based Oracle database.

## Prerequisites

Read the prerequisites in the top level [README](../README.md#prerequisites) to set up Vagrant and VirtualBox. The first time you provision a Windows 2019 Server VM, the basis Vagrant Box is loaded from the Vagrant Cloud, which may take a while. If preferred, you can download this VM in advance with Vagrant.

```bash
vagrant box add StefanScherer/windows_2019 --provider virtualbox
```

## Getting started

1. Clone this repository `git clone https://github.com/oehrlis/trivadislabs.com`.
2. Change into the `trivadislabs.com/win2019ad` directory
3. Run `vagrant up`
   1. The first time you run this it will provision everything and may take a while (20-40min). Ensure you have a good internet connection as the scripts will download a couple of tools via `Chocolatey`.
   2. The installation can be customized, if desired (see [Configuration](#configuration)).
4. Connect to the VM using `vagrant rdp` as *vagrant* or *administrator* user. Default password is either store in [vagrant.yml](common/config/vagrant.yml) or [default_pwd_windows.txt](../common/config/default_pwd_windows.txt).
5. If necessary, run the Windows Update manually.
6. You can shut down the VM via the usual `vagrant halt` and then start it up again via `vagrant up`

## Configuration

The different VMs respectively `Vagrantfile` can be used _as-is_, without any additional configuration. However, there are several parameters you can set to tailor the installation to your needs. All `Vagrantfile` are configured to use a common YAML file ([vagrant.yml](common/config/vagrant.yml)) within this file you can configure VM specific parameter like IP addresses, domain names, software packages etc. Either update the corresponding `Vagrantfile` or the section in the common YAML file.

## Other info

- If you need to, you can connect to the virtual machine via `vagrant rdp`.
- On the guest OS, the directory `C:\vagrant`, `C:\vagrant_common` and `C:\vagrant_labs` are a shared folder and maps to wherever you have this file checked out.

**HINT:** The Active Directory configuration for [win2019ad](./README.md) and [win2016ad](../win2016ad/README.md) are identically in term of IP address and AD domain name. Therefor you can not run both VMs at the same time. Either run the Windows Server 2019 AD or Windows Server 2016 AD VM.
