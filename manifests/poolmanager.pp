# Private class generates poolmanager.conf
class dcache::poolmanager (
  $poolmanager_conf_path = $::dcache::poolmanager_conf_path,
  $poolmanager_conf      = $::dcache::poolmanager_conf,) {
  if ($poolmanager_conf != 'nodef') {
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

    file { "${poolmanager_conf_path}.puppet":
      owner   => $::dcache::dcacheuser,
      group   => $::dcache::dcachegroup,
      mode    => '0644',
      content => $content,
      require => Exec["save_custom_pm"],
      notify  => Exec['reload_pm'],
    }

    exec { "save_custom_pm":
      command => "/bin/cp -f ${poolmanager_conf_path} ${poolmanager_conf_path}.puppet;/bin/cp -f ${poolmanager_conf_path} ${poolmanager_conf_path}.puppet.save  ",
      onlyif  => "/usr/bin/test ${poolmanager_conf_path} -nt ${poolmanager_conf_path}.puppet",
      path    => $::path
    }

    exec { 'reload_pm':
      command     => "cp -p  ${poolmanager_conf_path}.puppet ${poolmanager_conf_path}",
      refreshonly => true,
      #      onlyif      => "dcache status",
      path        => $::path,
      logoutput   => false,
    }
  }
}
