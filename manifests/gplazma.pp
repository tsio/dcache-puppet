class dcache::gplazma ($gplazma_conf_path = $::dcache::gplazma_conf_path, $gplazma_conf = $::dcache::gplazma_conf,) {
  if ($gplazma_conf != 'nodef') {
    file { "${gplazma_conf_path}.puppet":
      owner   => $::dcache::dcacheuser,
      group   => $::dcache::dcachegroup,
      mode    => '0644',
      content => join([inline_template('<%= @gplazma_conf.join("\n") %>'), "\n"], ''),
      require => Exec["save_custom_gplazma"],
    }

    exec { "save_custom_gplazma":
      command => "/bin/cp -f ${gplazma_conf_path} ${gplazma_conf_path}.puppet;/bin/cp -f ${gplazma_conf_path} ${gplazma_conf_path}.puppet.save",
      onlyif  => "/usr/bin/test ${gplazma_conf_path} -nt ${gplazma_conf_path}.puppet",
      path    => $::path
    }

  }
}
