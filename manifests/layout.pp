class dcache::layout ($l_file = "${dcache::dcache_etc_dir}/layouts/${hostname}.conf", $layout_hash = 'nodeff', $p_setup = 'nodef',) 
{
  if is_hash($layout_hash) {
    if deep_has_key($layout_hash, 'dCacheDomain') {
      class { 'dcache::poolmanager': }
    }

    if deep_has_key($layout_hash, 'admin') and $dcache::admin_ssh_keys != 'nodeff' {
      file { '/etc/dcache/admin/authorized_keys2':
        owner   => $dcache::dcacheuser,
        group   => $dcache::dcachegroup,
        mode    => '0644',
        content => join([inline_template('<%= scope["dcache::admin_ssh_keys"].join("\n") %>'), "\n"], ''),
        before  => Class['dcache::poolmanager']
      }
    }
  }

  if ($p_setup != 'nodeff') {
    $pools = deep_merge($p_setup, collect_pools_paths($layout_hash['domains']))
  } else {
    $pools = collect_pools_paths($layout_hash['domains'])
  }

  create_resources(dcache::layout::pool, $pools)

  if ($layout_hash != 'nodeff') {
    file { "${l_file}.puppet":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => template('dcache/layout.conf.erb'),
      notify  => Exec['dcache-reload']
    }
  }

  # Ugly method but it prevents java orphaned processes.
  exec { 'dcache-reload':
    command     => "echo /etc/init.d/dcache-server stop; cp -p  ${l_file}.puppet ${l_file}; touch ${l_file} ; echo /etc/init.d/dcache-server start",
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin/'],
    logoutput   => false,
  }

}
