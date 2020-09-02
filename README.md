# Trivadis LAB Environment

This repository contains *Trivadis LAB* a VM based environment for testing and engineering various Oracle features and use cases. The various environments are based on Oracle VM VirtualBox and are provisioned with Vagrant. The Oracle VM VirtualBox images themselves are based on Oracle's [Oracle Linux Box](https://yum.oracle.com/boxes/) or [Stefan Scherrer's Windows Box](https://app.vagrantup.com/StefanScherer) from the Vagrant Cloud. As shown in the figure below, Trivadis LAB was initially set up for engineering in the context of Oracle Enterprise User Security, Centrally Managed Users and Kerberos. However, the corresponding VMs can also be used individually or in combination for all kind of use- and test cases. More detailed information on Trivadis LAB is available in the [doc](doc) folder.

![Trivadis LAB Environment](./doc/images/LabEnvironment.png)
*Figure. 1: Trivadis LAB Environment*

## Prerequisites

All projects in this repository require Vagrant and Oracle VM VirtualBox or Window Server Virtualbox with the vagrant-libvirt plugin.

1. Install Oracle VM VirtualBox
2. Install Vagrant

## Getting started

1. Clone this repository `git clone https://github.com/oehrlis/trivadislabs.com`.
2. Change into the desired folder for the VM environment.
3. Follow the README.md instructions inside the folder.

Depending on the VM environment it may be necessary to download additional Oracle software.

## Trivadis LAB VM Enviroment

Trivadis LAB currently contains the configuration for the following VM environments:

+-----------+------------+------+------------------------------------------------+
| Version   | Date       | Visa | Comment                                        |
+===========+============+======+================================================+
| 0.1       | 2020.07.25 | soe  | Initialer Release                              |
+-----------+------------+------+------------------------------------------------+
| 0.2       | 2020.08.26 | soe  | Update PoC Informationen und Anhang            |
+-----------+------------+------+------------------------------------------------+
| 0.3       | 2020.08.27 | soe  | Installationsdokumentation hinzufügen          |
+-----------+------------+------+------------------------------------------------+
| 0.4       | 2020.08.28 | soe  | Ergänzung der OUD Konfiguration                |
+-----------+------------+------+------------------------------------------------+

## Feedback and Issues

Please file your bug reports, enhancement requests, questions and other support requests within Github's issue tracker:

* [Existing issues](https://github.com/oehrlis/trivadislabs.com/issues)
* [submit new issue](https://github.com/oehrlis/trivadislabs.com/issues/new)
