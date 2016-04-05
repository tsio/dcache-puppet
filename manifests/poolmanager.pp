# Private class
class dcache::poolmanager (
  $poolmanagerconf_file = '/var/lib/dcache/config/poolmanager.conf',
  $poolmanager_conf     = 'nodeff',
  # $poolmanager_conf=hiera('poolmanager_cfg','nodeff'),
  ) {
  if ($poolmanager_conf != 'nodeff') {
    #  dump poolmamager as multiline string : e.g.
    #  poolmanager_cfg: |
    #    cm set debug off
    #    rc set max threads 2147483647
    #    pm set -sameHostRetry=notchecked -p2p-oncost=yes -stage-oncost=no
    #
    if is_string($poolmanager_conf) {
      $content = $poolmanager_conf
    } else {
      #   gererate poolmanager.conf from hash : e.g.
      #   poolmanager_cfg:
      #    cm:
      #       - 'set debug off'
      #     rc:
      #       - 'set max threads 2147483647'
      #     pm:
      #        default:
      #         type: 'wass'
      #         options:
      #          sameHostRetry: 'notchecked'
      #     psu:
      #       set:
      #         - 'regex off'
      #       unitgroups:
      $content = template('dcache/poolmanager.conf.erb')
    }

    filebucket { 'poolmanager.conf': path => "/tmp/", }
    $timestamp = generate('/bin/date', '+%Y%d%m%H%M%S')

    file { "${poolmanagerconf_file}.puppet":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => $content,
      require => Exec["backup_pm"],
      backup  => 'poolmanager.conf',
      notify  => Exec[reload_pm],
    }

    exec { "backup_pm":
      command => "/bin/cp -f ${poolmanagerconf_file} ${poolmanagerconf_file}.puppet",
      onlyif  => "/usr/bin/test ${poolmanagerconf_file} -nt ${poolmanagerconf_file}.puppet",
    }

    exec { 'reload_pm':
      command     => "/etc/init.d/dcache-server stop; cp -p  ${poolmanagerconf_file}.puppet ${poolmanagerconf_file}; echo /etc/init.d/dcache-server start",
      refreshonly => true,
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin/'],
      logoutput   => false,
    }

  }

}
