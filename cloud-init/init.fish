virt-install --name=cloud-test --connect qemu:///session \
--ram=2048 --vcpus=1 --import \
--disk path=/mnt/archhdd/VMs/test.qcow2,format=qcow2 \
--disk path=/home/paul/Programming/orchestration/cloud-init/cloud-init.iso,device=cdrom \
--os-variant=debian11 \
--network bridge=virbr0,model=virtio \
--graphics vnc,listen=0.0.0.0 --noautoconsole
