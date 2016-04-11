# see README.markdown , ( but it will not help so much)

class dcache (
  $dcacheuser            = 'dcache',
  $dcachegroup           = 'dcache',
  $package_ensure        = 'present',
  $dcache_etc_dir        = '/etc/dcache',
  $bin_path              = '/bin',
  $package_name          = 'dcache',
  $conf                  = 'nodef',
  $admin_ssh_keys        = 'nodef',
  $layout                = 'nodef',
  $pools_setup           = 'nodef',
  $poolmanager_conf      = 'nodef',
  $gplazma_conf          = 'nodef',
  $poolmanager_conf_path = '/var/lib/dcache/config/poolmanager.conf',
  $dcache_layout         = "${dcache_etc_dir}/layouts/${hostname}.conf",
  $gplazma_conf_path     = "${dcache_etc_dir}/gplazma.conf",
  $authorized_keys2      = "${dcache_etc_dir}/admin/authorized_keys2",
  $lock_version          = false,
  #  $service_ensure        = 'stopped',
  $service_ensure        = 'running',) {
  if $::os[family] != 'RedHat' {
    fail("This module does NOT TESTED on ${::os[family]} ")
  }

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
  } ->
  anchor { 'dcache::end': }

}
