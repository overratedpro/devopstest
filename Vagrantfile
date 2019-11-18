require 'json'


ANSIBLE_PLAYBOOK     = ENV['provision_ansible_playbook'] || ""
ANSIBLE_USER         = ENV['USER']
SSH_PUBFILE          = File.read("#{Dir.home}/.ssh/id_rsa.pub")
VM_APPDATA_DISK_FILE = "./disks/hdx_appdata.vdi"
VM_APPDATA_DISK_SIZE = 2 * 1024
VM_GUI_ENABLED       = (ENV['VM_GUI_ENABLED'] || "") != ""


def ansible_provision(vm)
    vm.provision :ansible do |ansible|
        ansible.groups = {
            "test_hosts" => ["ubuntu"]
        }
        ansible.playbook = "ansible/playbooks/" + ANSIBLE_PLAYBOOK
        ansible.raw_arguments = ["--extra-vars", "{\"vagrant_extra_vars\": " + ANSIBLE_EXTRA_VARS.to_json + "}", "-vv", "--diff"]
    end
end


Vagrant.configure("2") do |config|

    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
        v.default_nic_type = "82543GC"
        v.gui = VM_GUI_ENABLED
        v.customize ["modifyvm", :id, "--cableconnected1", "on"]  # prevent the bug with first-time ansible ssh connection timeout
        v.customize ["modifyvm", :id, "--vrde", "off"]
    end

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.boot_timeout = 300
    config.vm.network "forwarded_port", guest: 22, host: 2222, host_ip: "127.0.0.1", id: 'ssh'

    config.vm.provision "configure account", type: "shell", privileged: true,
        inline: "mkdir -p /home && useradd -U -m -d /home/$1 -G sudo $1",
        args: [ANSIBLE_USER]
    config.vm.provision "prepare ssh config directory", type: "shell", privileged: true,
        inline: "mkdir -p /home/$1/.ssh",
        args: [ANSIBLE_USER]
    config.vm.provision "copy ssh public key", type: "shell", privileged: true,
        inline: "echo $1 | tee -a /home/$2/.ssh/authorized_keys",
        args: [SSH_PUBFILE, ANSIBLE_USER]

    config.vm.define "ubuntu" do |ubuntu|

        ubuntu.vm.box = "ubuntu/bionic64"
        ubuntu.vm.network "private_network", ip: "192.168.56.200"
        ubuntu.vm.provider "virtualbox" do |ubuntu_vbx|
            unless File.exists?(VM_APPDATA_DISK_FILE)
                ubuntu_vbx.customize ["createhd", "--filename", VM_APPDATA_DISK_FILE, "--size", VM_APPDATA_DISK_SIZE]
            end
            ubuntu_vbx.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 2, "--device", 0,
                                 "--type", "hdd", "--medium", VM_APPDATA_DISK_FILE]
        end

        ubuntu.vm.provision "install packages", type: "shell", privileged: true,
            inline: "apt -q update && apt -q install -y ansible sudo"

        # ansible_provision(ubuntu.vm)

    end

end
