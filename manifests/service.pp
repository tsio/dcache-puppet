#  modules/dcache/manifests/service.pp

class dcache::service {
  exec { 'dcache-update_db':
    command     => "dcache database update",
    refreshonly => true,
    path        => $::path,
    logoutput   => 'on_failure',
  }

}

