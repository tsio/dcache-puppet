class dcache::admin ($ssh_tmp_dir = '/tmp',) {
  exec { "generate _ssh_key":
    command => "ssh-keygen -f ${ssh_tmp_dir}/dc_key.rsa -t rsa -N ''",
    path    => $::path,
    creates => ["${ssh_tmp_dir}/dc_key.rsa", "${ssh_tmp_dir}/dc_key.rsa.pub"],
  }

  file { "${ssh_tmp_dir}/dc_ssh_config":
    content => "Port=22224\nUser=adminn\nIdentityFile=/tmp/dc_key.rsa\nUserKnownHostsFile=/dev/null\nStrictHostKeyChecking=no",
    require => Exec["generate _ssh_key"],
  }

}
