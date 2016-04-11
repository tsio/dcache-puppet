#  modules/dcache/manifests/service.pp

class dcache::service {
  case $::dcache::service_ensure {
    'running' : {
      $_notify = Exec['dcache-start']
      $_before = [Exec["dcache-start"], Exec['Validate dcache config']]

    }
    'stopped' : {
      $_notify = Exec['dcache-stop']
      $_before = undef

    }
    default   : {
      fail("dCache service status must be running stopped ")
    }
  }

  Exec { 'Validate dcache config':
    command   => "echo 'dCache configuration contains error(s) !!!' && false",
    onlyif    => "test ; dcache check-config | grep -q ERROR ",
    cwd       => '/tmp',
    logoutput => 'on_failure',
    path      => $::path,
    before    => Exec['half_final'],
  }

  Exec { 'half_final':
    command => "true",
    path    => $::path,
    #    refreshonly => true,
    notify  => $_notify,
  }

  exec { 'dcache-stop':
    command     => "dcache stop",
    refreshonly => true,
    path        => $::path,
    before      => Exec['dcache-update_db'],
  }

  exec { 'dcache-update_db':
    command     => "dcache database update",
    refreshonly => true,
    path        => $::path,
  #    onlyif      => "dcache status ; if [ $? -eq 1 ] ; then echo true; else echo false; fi",
  #    before      => Exec['dcache-start'],
  }

  exec { 'dcache-start':
    command     => "dcache start",
    refreshonly => true,
    path        => $::path,
    onlyif      => "test ; if dcache check-config | grep -q ERROR ; then false; else true ; fi",
  }

  exec { 'dcache-refresh_layuot':
    command     => "cp -p  ${::dcache::dcache_layout}.puppet ${::dcache::dcache_layout}; touch ${::dcache::dcache_layout}",
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin/'],
    logoutput   => false,
    require     => Exec["dcache-stop"],
    notify      => Exec['dcache-update_db'],
    before      => $_before,

  #    before      => [Exec["dcache-start"], Exec['Validate dcache config']],
  }

}

