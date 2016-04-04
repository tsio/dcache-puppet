module Puppet::Parser::Functions

  newfunction(:collect_pools_paths, :type => :rvalue, :doc => <<-'ENDDOC') do |args|
     Collect all path of the pools in dcahce layuot.
    
    ENDDOC

    unless args.length == 1
      raise Puppet::ParseError, ("collect_pools(): wrong number of arguments (#{args.length}; must be 1)")
    end
    unless args[0].is_a?(Hash)
      raise Puppet::ParseError, "collect_pools(): expects the argument to be a hash, got #{args[0].inspect} which is of type #{args[0].class}"
    end
  
  pools={}
   temp_hash={}      
  
   args[0].each do |hash,key|
       if key.has_key?('pool')

         temp_hash.merge!({ key['pool']['pool.name']=>key['pool'].clone.keep_if  {|k,v| ['pool.path','pool.wait-for-files'].include? k } })
           if   key['pool']['pool.wait-for-files'].include? "pool.path" 
         temp_hash[key['pool']['pool.name']]['pool.wait-for-files']=temp_hash[key['pool']['pool.name']]['pool.wait-for-files'].split(":").map {|p| p.gsub("${pool.path}",key['pool']['pool.path'])}  
         end
         temp_hash[key['pool']['pool.name']].keys.each { |k| 
              temp_hash[key['pool']['pool.name']][k.gsub(/[\.-]/, '_')]= temp_hash[key['pool']['pool.name']][k] ;
              temp_hash[key['pool']['pool.name']].delete(k) }  

         pools.merge!(temp_hash) 
#         pools<<temp_hash[key['pool']['pool.name']]['pool.wait-for-files'].split(":")
         temp_hash={}
       end   
   end
      
   return  pools
  end 
end
