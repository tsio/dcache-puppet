class dcache::endit (
  $owner                  = 'root',
  $group                  = 'root',
  $cron_fix_tsm_ownership = true,
  $endit_dir              = '/opt/endit',
  $tsm_conf               = undef,) {
  define endit_file {
    file { "${dcache::endit::endit_dir}/${name}":
      ensure  => 'present',
      source  => "puppet:///modules/dcache/${name}",
      owner   => $dcache::endit::owner,
      group   => $dcache::endit::group,
      mode    => '0755',
      require => File[$dcache::endit::endit_dir],
    }
  }

  # ## fix tsm client root ownership
  # * * * * * (chown -R dcache:dcache /pool01/in; chmod 644 -f /pool01/in/*)

  if cron_fix_tsm_ownership {
    cron { 'tsm_hb':
      command => "(chown -R ${dcache::dcacheuser}:${dcache::dcachegroup} /pool01/in; chmod 644 -f /pool01/in/*)",
      user    => root,
      ensure  => present,
    }
  }

  file { $endit_dir:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
  }

  $tsm_files = hiera('tsm_files', 'nodef')

  endit_file { $tsm_files: }

  file { '/etc/init.d/start_endit':
    ensure => 'present',
    source => 'puppet:///modules/dcache/start_endit',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $endit_conf = hiera($tsm_conf, 'nodef')

  file { "${dcache::endit::endit_dir}/endit.conf":
    ensure  => 'present',
    owner   => $dcache::endit::owner,
    group   => $dcache::endit::group,
    mode    => '0644',
    content => template('dcache/endit.conf.erb'),
    require => File[$dcache::endit::endit_dir],
  }

}
