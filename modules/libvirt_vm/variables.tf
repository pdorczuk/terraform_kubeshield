variable "name" {
    type = string
}

variable "pool_path" {
    type = string
    default = "/home/phil/libvirt-storage/"
}

variable "img_source" {
    type = string
    default = "../../packer/build/focal-0.1.0"
}

variable "ip_addr" {
    type = string
}

variable "vm_memory" {
    type = string
    default = "2048"
}

variable "libvirt_network" {
    type = string
    default = "host-bridge"
}