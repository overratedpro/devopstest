require 'json'


ANSIBLE_EXTRA_VARS   = {
    'provision_user_name'    => ENV['USER'],
    'provision_user_ssh_key' => File.read("#{Dir.home}/.ssh/id_rsa.pub"),
}
ANSIBLE_PLAYBOOK     = ENV.fetch('ANSIBLE_PLAYBOOK', '') + '.yml'
VM_APPDATA_DISK_FILE = './disks/hdx_appdata.vdi'
VM_APPDATA_DISK_SIZE = 2 * 1024
VM_GUI_ENABLED       = ENV.fetch('VM_GUI_ENABLED', '') != ''


def ansible_provision(vm)
    vm.provision :ansible do |ansible|
        ansible.groups = {
            "test_hosts" => ["ubuntu"]
        }
        ansible.playbook = "playbooks/" + ANSIBLE_PLAYBOOK
        ansible.raw_arguments = ["--extra-vars", ANSIBLE_EXTRA_VARS.to_json, "-vv", "--diff"]
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

        ansible_provision(ubuntu.vm)

    end

end
