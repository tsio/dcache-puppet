class dcache::config ($conf = 'nodeff',) {
  $dcache_conf = $conf

  if ($dcache_conf != 'nodeff') {
    file { "${dcache::dcache_etc_dir}/dcache.conf":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => template('dcache/dcache.conf.erb');
    }

    if deep_has_key($dcache_conf, 'dcache.log.dir') {
      file { $dcache_conf['dcache']['dcache.log.dir']:
        owner  => $dcache::dcacheuser,
        group  => $dcache::dcachegroup,
        ensure => directory,
      }
    }

    if deep_has_key($dcache_conf, 'dcache.paths.billing') {
      file { $dcache_conf['dcache']['dcache.paths.billing']:
        owner  => $dcache::dcacheuser,
        group  => $dcache::dcachegroup,
        ensure => directory,
      }
    }
  }
}
