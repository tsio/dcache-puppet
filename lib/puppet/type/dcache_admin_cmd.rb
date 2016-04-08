Puppet::Type.newtype(:dcache_admin_cmd) do

  newparam(:name) do
    desc "An arbitrary tag for your own reference; the name of the message."
    isnamevar
  end

  newproperty(:command) do
    desc 'The command to execute via dcache admin interface'

  newparam(:user) do
    desc "The user name to execute command."
    defaultto("admin")  
  end

  newparam(:port) do
    desc "The port of the admin console."
    defaultto("22224")  
  end

  newparam(:host) do
    desc "The host of the admin console"
    defaultto("localhost")  
  end

end