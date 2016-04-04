class dcache::install ($lock_version = $dcache::lock_version) {
  $package_ensure = $dcache::package_ensure
  $package_name = $dcache::package_name

  #  notice ("!!!!!!!!!!!!! ${package_ensure} TEST  !!!!!!!!!!!!!!!")
  #        notify { "test":
  #           message => $dcache_version }


  if $lock_version {
    file_line { 'dcache_versionlock':
      ensure => present,
      path   => '/etc/yum/pluginconf.d/versionlock.list',
      line   => "dcache-${package_ensure}.*",
      match  => '^(\d+:|)dcache-\d+.\d+.\d+.*',
      before => Package['dcache'],
    }
  }

  $_package_ensure = $package_ensure ? {
    true     => 'present',
    false    => 'purged',
    'absent' => 'purged',
    default  => $package_ensure,
  }

  package { 'dcache':
    ensure => $_package_ensure,
    name   => $package_name,
    tag    => 'dcache',
  }

}
