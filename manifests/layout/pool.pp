define dcache::layout::pool ($pool_path = 'nodef', $pool_wait_for_files = 'nodef', $setup = 'nodef',) {
  if ($pool_path != 'nodef') {
    exec { "Create ${pool_path}":
      creates => "${pool_path}",
      command => "mkdir -p ${pool_path}",
      path    => $::path
    }

    file { "${pool_path}":
      ensure  => directory,
      owner   => $::dcache::dcacheuser,
      group   => $::dcache::dcachegroup,
      require => Exec["Create ${pool_path}"],
    }

    file { $pool_wait_for_files:
      ensure  => directory,
      owner   => $::dcache::dcacheuser,
      group   => $::dcache::dcachegroup,
      require => Exec["Create ${pool_path}"],
    }

    if ($setup != 'nodef') {
      file { "${pool_path}/setup.puppet":
        owner   => $::dcache::dcacheuser,
        group   => $::dcache::dcachegroup,
        content => $setup,
        require => Exec["save_pool_setup_${pool_path}"],
        notify  => Exec["reload_pool_${pool_path}"],
      }

      exec { "save_pool_setup_${pool_path}":
        command => "/bin/cp -f ${pool_path}/setup ${pool_path}/setup.puppet;/bin/cp -f ${pool_path}/setup ${pool_path}/setup.puppet.save  ",
        onlyif  => "/usr/bin/test ${pool_path}/setup -nt ${pool_path}/setup.puppet",
        path    => $::path
      }

      exec { "reload_pool_${pool_path}":
        command     => "cp -p  ${pool_path}/setup.puppet ${pool_path}/setup",
        refreshonly => true,
        #      onlyif      => "dcache status",
        path        => $::path,
        logoutput   => false,
      }

    }
  }
}
