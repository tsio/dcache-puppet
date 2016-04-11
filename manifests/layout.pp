class dcache::layout ($l_file = $::dcache::dcache_layout, $layout_hash = 'nodef', $p_setup = 'nodef',) {
  if is_hash($layout_hash) {
    if deep_has_key($layout_hash, 'dCacheDomain') {
      class { 'dcache::poolmanager': }
    }

    if deep_has_key($layout_hash, 'gplazma') {
      class { 'dcache::gplazma': require => Class['dcache::install'], }
    }

    if deep_has_key($layout_hash, 'admin') and $::dcache::admin_ssh_keys != 'nodef' {
      file { "${::dcache::authorized_keys2}":
        owner   => $dcache::dcacheuser,
        group   => $dcache::dcachegroup,
        mode    => '0644',
        content => join([inline_template('<%= scope["::dcache::admin_ssh_keys"].join("\n") %>'), "\n"], ''),
        before  => Class['dcache::poolmanager']
      }
    }
  }

  if ($layout_hash != 'nodef') {
    file { "${l_file}.puppet":
      owner   => $dcache::dcacheuser,
      group   => $dcache::dcachegroup,
      mode    => '0644',
      content => template('dcache/layout.conf.erb'),
      notify  => Exec['dcache-refresh_layuot'],
    }

    if ($p_setup != 'nodef') {
      $pools = deep_merge($p_setup, collect_pools_paths($layout_hash['domains']))
    } else {
      $pools = collect_pools_paths($layout_hash['domains'])
    }
    create_resources(dcache::layout::pool, $pools)

  }

}
