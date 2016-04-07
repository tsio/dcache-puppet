class dcache (
  $dcacheuser            = 'dcache',
  $dcachegroup           = 'dcache',
  $package_ensure        = 'lastest',
  $dcache_etc_dir        = '/etc/dcache',
  $package_name          = 'dcache',
  $conf                  = 'nodef',
  $admin_ssh_keys        = 'nodef',
  $layout                = 'nodef',
  $pools_setup           = 'nodef',
  $poolmanager_conf      = 'nodef',
  $poolmanager_conf_path = '/var/lib/dcache/config/poolmanager.conf',
  $dcache_layout         = "${dcache_etc_dir}/layouts/${hostname}.conf",
  $lock_version          = false,) {
  anchor { 'dcache::start': }

  class { 'dcache::install': require => Anchor['dcache::start'], }

  class { 'dcache::config':
    conf    => $conf,
    require => Class['dcache::install'],
  }

  class { 'dcache::layout':
    layout_hash => $layout,
    p_setup     => $pools_setup,
    require     => Class['dcache::config'],
  }

  class { 'dcache::service':
    require => Class['dcache::layout'],
  }

  anchor { 'dcache::end': }

}
