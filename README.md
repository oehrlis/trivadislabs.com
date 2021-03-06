# Trivadis LAB Environment

This repository contains *Trivadis LAB* a VM based environment for testing and engineering various Oracle features and use cases. The various environments are based on Oracle VM VirtualBox and are provisioned with Vagrant. The Oracle VM VirtualBox images themselves are based on Oracle's [Oracle Linux Box](https://yum.oracle.com/boxes/) or [Stefan Scherrer's Windows Box](https://app.vagrantup.com/StefanScherer) from the Vagrant Cloud. As shown in the figure below, Trivadis LAB was initially set up for engineering in the context of Oracle Enterprise User Security, Centrally Managed Users and Kerberos. However, the corresponding VMs can also be used individually or in combination for all kind of use- and test cases. More detailed information on Trivadis LAB is available in the [doc](doc) folder or in the [LAB and Example](labs) folder.

![Trivadis LAB Environment](./doc/images/LabEnvironment.png)
*Figure. 1: Trivadis LAB Environment*

Trivadis LAB currently contains the configuration for the following VM environments:

| VM                     | Type          | Description                                     |
|------------------------|---------------|-------------------------------------------------|
| [ol7db112](ol7db112)   | Linux DB VM   | Linux VM with Oracle 11.2.0.4                   |
| [ol7db122](ol7db122)   | Linux DB VM   | Linux VM with Oracle Database 12.2.0.2          |
| [ol7db18](ol7db18)     | Linux DB VM   | Linux VM with Oracle Database 18c (18.11.0.0)   |
| [ol7db19](ol7db19)     | Linux DB VM   | Linux VM with Oracle Database 19c (19.8.0.0)    |
| [ol7db112](ol7db112)   | Linux DB VM   | Linux VM with Oracle Database 11.2.0.4          |
| [ol7oud12](ol7oud12)   | Linux OUD VM  | Linux VM with Oracle Unified Directory 12.2.1.4 |
| [win2016ad](win2016ad) | Windows AD VM | Windows Server 2016 Active Directory VM         |
| [win2019ad](win2019ad) | Windows AD VM | Windows Server 2019 Active Directory VM         |

Table: Trivadis LAB environments

## Prerequisites

All projects in this repository require Vagrant and Oracle VM VirtualBox or Window Server Virtualbox with the vagrant-libvirt plugin.

1. Install [Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://vagrantup.com/)

## Getting started

1. Clone this repository `git clone https://github.com/oehrlis/trivadislabs.com`.
2. Change into the desired folder for the VM environment.
3. Follow the README.md instructions inside the folder.

Depending on the VM environment it may be necessary to download additional Oracle software or Vagrant boxes.

## Configuration

The different VMs respectively `Vagrantfile` can be used _as-is_, without any additional configuration. However, there are several parameters you can set to tailor the installation to your needs. All `Vagrantfile` are configured to use a common YAML file ([vagrant.yml](common/config/vagrant.yml)) within this file you can configure VM specific parameter like IP addresses, domain names, software packages etc. Either update the corresponding `Vagrantfile` or the section in the common YAML file.

## Feedback and Issues

Please file your bug reports, enhancement requests, questions and other support requests within Github's issue tracker:

* [Existing issues](https://github.com/oehrlis/trivadislabs.com/issues)
* [submit new issue](https://github.com/oehrlis/trivadislabs.com/issues/new)

## License

To download and run Oracle Database, Oracle Unified Directory, Oracle Directory Server Enterprise Edition and Oracle JDK, regardless whether inside or outside a Docker container, you must download the binaries from the Oracle website and accept the license indicated at that page.

