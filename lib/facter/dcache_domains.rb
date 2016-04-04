Facter.add("dcache_domains") do
  setcode do
    domanis=[]
      dcache_domns = Facter::Core::Execution.exec('dcache status')
      if dcache_domns 
        dcache_domns.lines.to_a[1..-1].map do |line|
            domanis <<  line.split.first
      end
    end
    domanis * ","
  end
end
