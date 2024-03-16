# Vagrant

To create the `Vagrantfile`, we need to search the desired *box* to install: [debian boxes](https://app.vagrantup.com/debian).

After choosing the desired box, we proceed to initialize the vagrant project:

```bash
vagrant init debian/bookworm64
```

Then to start the vagrant VM, we can run it with: 

```bash
vagrant up
# To test it is working, we can ssh into the vm
vagrant ssh ciglesiaS
vagrant ssh ciglesiaSW
```

To make the changes effective while the vm is already up, we can use:

```bash
vagrant reload --provision
```