class dcache::config ($conf = 'nodeff',) {
  $dcache_conf = $conf

  if ($dcache_conf != 'nodeff') {
    file { "${dcache::dcache_etc_dir}/dcache.conf":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => template('dcache/dcache.conf.erb');
    }
  }
}
