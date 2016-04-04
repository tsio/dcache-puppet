Facter.add("dcache_version") do
  setcode do
    Facter::Util::Resolution.exec('rpm -q dcache --qf "%|epoch?{%{epoch}}:{0}|:%{name}-%{version}-%{release}\n"')
  end  
#    dcache_ver = Facter::Util::Resolution.exec('dcache version')
#    if dcache_ver
#      dcache_ver.match(/\d+\.\d+\.\d+/)[0]
#    end
#  end
end
