class dcache (
  $dcacheuser            = 'dcache',
  $dcachegroup           = 'dcache',
  $package_ensure        = 'lastest',
  $dcache_etc_dir        = '/etc/dcache',
  $package_name          = 'dcache',
  $conf                  = 'undef',
  $dcahe_poolmanagerconf = '/var/lib/dcache/config/poolmanager.conf',
  $dcache_layout         = "${dcache_etc_dir}/layouts/${hostname}.conf",
  $admin_ssh_keys        = 'nodeff',
  $lock_version          = false,) {
  anchor { 'dcache::start': }

  class { 'dcache::install': require => Anchor['dcache::start'], }

  class { 'dcache::config':
    conf    => $conf,
    require => Class['dcache::install'],
  }

  class { 'dcache::service':
    require => Class['dcache::config'],
  }

  anchor { 'dcache::end': }

}
