# Ansible Playbooks

Collection of Ansible playbooks. Mostly relating to Windows and VMware.

## VMware Notes

VM names are case sensitive; they must match how they are listed in vCenter.

## PowerShell Core

[PowerShell GitHub](https://github.com/PowerShell/PowerShell)

### PowerCLI

Not all modules work with PowerShell Core. Some scripts will require Windows bridge machine to operate.

```shell
sudo pwsh
Install-Module -Name VMware.PowerCLI
```

To ignore SSL cert: ```Set-PowerCLIConfiguration -InvalidCertificateAction Ignore```
