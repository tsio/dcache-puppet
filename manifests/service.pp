#  modules/dcache/manifests/service.pp

class dcache::service (
  #        $dcache_service_domains=[],  #
  $dcache_service_domains = split($dcache_domains, ','),
  $dcache_service_enable  = true,
  $dcache_service_ensure  = 'running',) {
  define dcache_domain_service ($service_ensure = 'stopped') {
    service { "dcahce-server ${name}":
      provider => 'base',
      ensure   => $service_ensure,
      start    => "dcache start ${name}",
      stop     => "'dcache stop ${name}",
      restart  => "dcache restart ${name}",
    }
  }

  service_dc_domain { $dcache_domains: service_ensure => 'running', }

  if $dcache_service_domains != [] {
    dcache_domain_service { $dcache_service_domains: service_ensure => 'running', }
  } else {
    service { 'dcache-server':
      ensure => $dcache_service_ensure,
      enable => $dcache_service_enable,
    }
  }

  #     $_dcache = hiera_hash('dcache', {})
  #  create_resources('service', $_dcache['services'])
}

