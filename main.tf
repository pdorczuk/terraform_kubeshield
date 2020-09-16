terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.2"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

# Create a storage pool to keep libvirt objects
resource "libvirt_pool" "pool" {
  name = "libvirt_storage"
  type = "dir"
  path = "/home/phil/libvirt-storage/"
}

module "kube-master" {
  source = "./modules/libvirt_vm"
  count = 1
  name = "master-${count.index +1}"
  ip_addr = "192.168.1.10${count.index}"
  vm_memory = "3072"
  depends_on = [libvirt_pool.pool]
}

module "kube-worker" {
  source = "./modules/libvirt_vm"
  count = 1
  name = "worker-${count.index +1}"
  ip_addr = "192.168.1.11${count.index}"
  vm_memory = "18432"
  depends_on = [libvirt_pool.pool]
}

resource "null_resource" "kubespray" {
  depends_on = [module.kube-master, module.kube-worker]
  provisioner "local-exec" {
    command = "echo ' ' > /home/phil/.ssh/known_hosts && ansible-playbook -i ../../ansible/kubespray/inventory/kubeshield/inventory --become --become-user=root ../../ansible/kubespray/cluster.yml --extra-vars 'ansible_user=robot'"
  }
}

resource "null_resource" "kubectl_cert" {
  depends_on = [null_resource.kubespray]
  provisioner "local-exec" {
    command = "mkdir -p /home/phil/.kube && cp ../../ansible/kubespray/inventory/kubeshield/artifacts/admin.conf /home/phil/.kube/config"
  }
}