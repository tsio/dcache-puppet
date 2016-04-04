module Puppet::Parser::Functions

  newfunction(:deep_has_key, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
    Determine if a hash has a certain key value.

    Example:

    $my_hash = {'one' => 1, 'two'=> {'three' =>3}  }
        if has_key($my_hash, 'three') {
          notice('we will not reach here')
        }
        if deep_has_key($my_hash, 'three') {
          notice('this will be printed')
        }

    ENDHEREDOC

    unless args.length == 2
      raise Puppet::ParseError, ("deep_has_key(): wrong number of arguments (#{args.length}; must be 2)")
    end
    unless args[0].is_a?(Hash)
      raise Puppet::ParseError, "deep_has_key(): expects the first argument to be a hash, got #{args[0].inspect} which is of type #{args[0].class}"
    end

     
    deep_has_key = Proc.new do |hash,key|
      hash.has_key?(key)|| hash.any? {|k, v| deep_has_key.call(v,key) if v.is_a? Hash}
    end
      
    return  deep_has_key.call(args[0],args[1])
  end
end
