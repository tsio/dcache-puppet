class dcache::install ($lock_version = $dcache::lock_version) {
  $package_ensure = $dcache::package_ensure
  $package_name = $dcache::package_name

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

  if $_package_ensure != 'purged' {
    $_notify = Exec['dcache-update_db']
  } else {
    $_notify = undef
  }

  package { 'dcache':
    ensure => $_package_ensure,
    name   => $package_name,
    tag    => 'dcache',
    notify => $_notify,
  }

}
