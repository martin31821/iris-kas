# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/buster64"

  user_id = (`id -u`)
  group_id = (`id -g`)

  # allow setting SSH_DIR variable
  if ENV["SSH_DIR"]
    ssh_dir = ENV["SSH_DIR"]
  else
    ssh_dir = "~/.ssh"
  end

  # disable default folder sync
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  # mount necessary folders
  config.vm.synced_folder ssh_dir, "/etc/skel/.ssh", automount: true
  config.vm.synced_folder (Dir.getwd), "/mnt/yocto-kas", automount: true


  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |v|

    v.name = "iris-kas"
    v.gui = true

    # dynamically set ram size and number of cpus
    case RbConfig::CONFIG['host_os']
    when /linux/
      v.memory = (`cat /proc/meminfo | grep MemTotal | tr -d [:alpha:],[:blank:],[=\:=]`.to_i / 1024 * 0.75).floor
      v.cpus = (`cat /proc/cpuinfo | grep processor | wc -l`.to_i) - 1 
    else
      raise StandardError, "Unsupported host platform"
    end

    # install KAS and dependencies
    config.vm.provision "shell", inline: <<-SHELL
      set -ex
      apt-get update
      apt-get install --no-install-recommends -y \
        python3 \
        python3-pip \
        python3-jsonschema \
        python3-yaml \
        python3-setuptools \
        git
      pip3 install kas
    SHELL
    
    # add user and group matching the host user
    config.vm.provision "shell", env: {"USER_ID" => user_id, "GROUP_ID" => group_id}, inline: <<-SHELL
      set -ex
      adduser --gecos '' --disabled-password --uid ${USER_ID} --gid ${GROUP_ID} builder
      echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
    SHELL
  end

end
