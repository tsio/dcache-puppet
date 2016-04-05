define dcache::layout::pool ($pool_path = 'nodef', $pool_wait_for_files = 'nodef', $setup = 'nodef',) {
  if ($pool_path != 'nodef') {
    exec { "Create ${pool_path}":
      creates => "${pool_path}",
      command => "mkdir -p ${pool_path}",
      path    => $::path
    } -> file { "${pool_path}":
      ensure => directory,
      owner  => $dcache::dcacheuser,
      group  => $dcache::dcachegroup,
    } -> file { "$pool_wait_for_files":
      ensure => directory,
      owner  => $dcache::dcacheuser,
      group  => $dcache::dcachegroup,
    }

    if ($setup != 'nodef') {
      file { "${pool_path}/setup":
        owner   => $dcache::dcacheuser,
        group   => $dcache::dcachegroup,
        content => $setup,
      }
    }
  }
}
