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
    command     => "echo dcache start",
    refreshonly => true,
    path        => $::path,
    unless      => "dcache check-config | grep -q ERROR ",
  }
}

