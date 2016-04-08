#  modules/dcache/manifests/service.pp

class dcache::service {
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
    notify      => Exec['dcache-start'],
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
    notify      => Exec['dcache-update_db'],
  }

}

