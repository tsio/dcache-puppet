# dcache #


The dCache module allows you to manage your instance with Puppet.

Module Description
-------------------

TBD

Setup
-----

**What puppet-dcache module affects:**

* package / services
* config files:  dcache.conf, poolmanager.conf, layout file
* creates dcache pools
* TSM Interface

Was tested only on : SL5 - SL7, CentOS7


###Configuring dCache

Simple usage: 

    class { 'dcache': }
  
 *install dcache package only*

customized usage  :
   


  class { 'dcache':
    package_ensure   => hiera('dcache_version'),
    conf             => hiera('dcache_conf', 'nodef'),
    admin_ssh_keys   => hiera('ssh_pub_keys', 'nodef'),
    layout           => hiera('dcache_layout', 'nodef'),
    pools_setup      => hiera('pools_setup', 'nodef'),
    poolmanager_conf => hiera('poolmanager_cfg_txt', 'nodef'),
    gplazma_conf     => hiera('gplazma_conf', 'nodef'),
    }
 
 
*example of hiera configuration entries "_dcache_node_".yaml :* 

 parameters for dcache.conf
***
<pre><code>

dcache_conf:
  dcache: 
    dcache.log.dir: '/var/log/dcache'
    dcache.layout    : '${host.name}'
    dcache.namespace : 'chimera'
    dcache.broker.host  : 'localhost.localdomain'
    dcache.upload-directory : 'localhost.localdomain'
    dcache.enable.space-reservation : 'false'
    dcache.user : 'dcache'
    dcache.paths.billing: '/data/billing'
    
  chimera:
    chimera.db.user  : 'chimera'
    chimera.db.url   : 'jdbc:postgresql://localhost/chimera?prepareThreshold=3'
    chimera.db.name  : 'chimera'


  ftp:
    ftp.limits.streams-per-client : '20'
    ftp.proxy.on-passive  : 'false'
    ftp.proxy.on-active : 'false'
    ftp.performance-marker-period : '30'
  
  billig:
    billing.enable.db : 'true'
    billing.db.name: 'billing'
    billing.db.user: 'srmdcache'

  httpd:
    httpd.enable.authn  : 'true'
    httpd.enable.plots.billing  : 'true'
    httpd.enable.plots.pool-queue : 'true'
    httpd.authz.admin-gid : '500'

  info-provider:
    info-provider.site-unique-id : 'DEMO'
    info-provider.se-unique-id : 'localhost.localdomain'
    info-provider.se-name : 'Puppet demo module'
    info-provider.dcache-architecture : 'tape'
    info-provider.paths.tape-info : '/var/opt/dcache/tape-info.xml'
    info-provider.http.host : 'localhost.localdomain'
  srm:
    srm.enable.pin-online-files : 'false'
    srm.persistence.enable.history  : 'true'
    srm.net.local-hosts : 'localhost.localdomain, localhost'

</code></pre> 

 layoutfile: 
***
<code><pre>

 dcache_layout:
  globals: 
    'dcache.java.memory.heap': '2048m'
    'dcache.java.memory.direct': '1024m'
  domains:
    dCacheDomain:
      poolmanager: 
      broadcast:  
      loginbroker: 
      topo: 
    dirDomain:
      dir:
    adminDoorDomain:
      admin:
    httpdDomain:
      httpd:
      billing:
    utilityDomain:
      pinmanager:
    gPlazma-dcache-lofarDomain:
      gplazma:
    namespaceDomain:
      pnfsmanager: 
         pnfsmanager.enable.acl: 'true'
      cleaner:
    statisticsDomain:
      statistics:
    nfsDomain:
      domainsettings: 
        dcache.java.memory.heap: '4096m'
      nfs:
        nfs.version: '4.1'
    srm-dcache-lofarDomain:
      srm:
      transfermanagers:
    infoDomain:
      info:
    gridftpDomain:
      domainsettings:
        dcache.java.memory.heap: '8192m'
        dcache.java.memory.direct: '2048m'
        dcache.java.options.extra: ' -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${dcache.log.dir} -d64'
      ftp:
        ftp.authn.protocol:  gsi
        ftp.net.port: '2811'
        ftp.cell.name: 'GFTP-${host.name}'
    01Domain: 
      pool:
        pool.name: '${host.name}_01'
        pool.path: '/pool01/pool'
        pool.size: '27T'
        pool.plugins.meta: 'org.dcache.pool.repository.meta.db.BerkeleyDBMetaDataRepository'
        pool.wait-for-files: '${pool.path}/data:${pool.path}/meta'
        pool.lfs: 'none'
        pool.tags: 'hostname=${host.name}'
    02Domain: 
      pool:
        pool.name: '${host.name}_02'
        pool.path: '/pool02/pool'
        pool.size: '27T'
        pool.plugins.meta: 'org.dcache.pool.repository.meta.db.BerkeleyDBMetaDataRepository'
        pool.wait-for-files: '${pool.path}/data:${pool.path}/meta'
        pool.lfs: 'none'
        pool.tags: 'hostname=${host.name}'

</code></pre>

pool setup 
***

<code><pre>

 pools_setup:
  '${host.name}_01':
     setup: |
       #
       # Created by dcachepool15_02(Pool) at Mon Jul 20 09:03:34 CEST 2015
       #
       csm set checksumtype ADLER32
       csm set policy -scrub=off
       csm set policy -onread=off -onwrite=off -onflush=off -onrestore=off -ontransfer=on -enforcecrc=on -getcrcfromhsm=off
       #
       # Flushing Thread setup
       #
       flush set max active 1000
       flush set interval 60
       flush set retry delay 60
       #
       # Nearline storage
       #
       hsm create osm osm script -command=/opt/endit/endit.pl -c:gets=0 -c:puts=5 -c:removes=1
       jtm set timeout -queue=regular -lastAccess=3600 -total=86400
       jtm set timeout -queue=p2p -lastAccess=3600 -total=86400
       jtm set timeout -queue=io -lastAccess=3600 -total=86400
       #
       # MigrationModule
       #
       set heartbeat 30
       set report remove on
       set breakeven 0.5
       set mover cost factor 0.1
       set gap 322122547200
       set duplicate request none
       mover set max active -queue=regular 100
       mover set max active -queue=p2p 10
       #
       #  Pool to Pool (P2P) [$Revision$]
       #
       pp set max active 10
       pp set pnfs timeout 300
       set max diskspace 25288767438848
       rh set timeout 691200
       st set timeout 172800
       rm set timeout 14400

  '${host.name}_02':
     setup: |
       #
       # Created by dcachepool15_02(Pool) at Mon Jul 20 09:03:34 CEST 2015
       #
       csm set checksumtype ADLER32
       csm set policy -scrub=off
       csm set policy -onread=off -onwrite=off -onflush=off -onrestore=off -ontransfer=on -enforcecrc=on -getcrcfromhsm=off
       #
       # Flushing Thread setup
       #
       flush set max active 1000
       flush set interval 60
       flush set retry delay 60
       #
       # Nearline storage
       #
       hsm create osm osm script -command=/opt/endit/endit.pl -c:gets=0 -c:puts=5 -c:removes=1
       jtm set timeout -queue=regular -lastAccess=3600 -total=86400
       jtm set timeout -queue=p2p -lastAccess=3600 -total=86400
       jtm set timeout -queue=io -lastAccess=3600 -total=86400
       #
       # MigrationModule
       #
       set heartbeat 30
       set report remove on
       set breakeven 0.5
       set mover cost factor 0.1
       set gap 322122547200
       set duplicate request none
       mover set max active -queue=regular 100
       mover set max active -queue=p2p 10
       #
       #  Pool to Pool (P2P) [$Revision$]
       #
       pp set max active 10
       pp set pnfs timeout 300
       set max diskspace 25288767438848
       rh set timeout 691200
       st set timeout 172800
       rm set timeout 14400

</code></pre>
 
 
 
