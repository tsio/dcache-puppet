Puppet::Type.newtype(:dcache_admin_cmd) do

  newparam(:name) do
    desc "An arbitrary tag for your own reference; the name of the message."
    isnamevar
  end

  newproperty(:command) do
    desc 'The command to execute via dcache admin interface'

    defaultto { @resource[:name] }

    def retrieve
      if @resource.should_run_sql
        return :notrun
      else
        return self.should
      end
    end

    def sync
      output, status = provider.run_sql_command(value)
      self.fail("Error  #{status}: '#{output}'") unless status == 0
    end
  end


  newparam(:db) do
    desc "The name of the database to execute the SQL command against."
  end

  newparam(:port) do
    desc "The port of the database server to execute the SQL command against."
  end

  newparam(:search_path) do
    desc "The schema search path to use when executing the SQL command"
  end

  newparam(:psql_path) do
    desc "The path to psql executable."
    defaultto("psql")
  end

  newparam(:psql_user) do
    desc "The system user account under which the psql command should be executed."
    defaultto("postgres")
  end

  newparam(:psql_group) do
    desc "The system user group account under which the psql command should be executed."
    defaultto("postgres")
  end

  newparam(:cwd, :parent => Puppet::Parameter::Path) do
    desc "The working directory under which the psql command should be executed."
    defaultto("/tmp")
  end

  newparam(:environment) do
    desc "Any additional environment variables you want to set for a
      SQL command. Multiple environment variables should be
      specified as an array."

    validate do |values|
      Array(values).each do |value|
        unless value =~ /\w+=/
          raise ArgumentError, "Invalid environment setting '#{value}'"
        end
      end
    end
  end

  newparam(:refreshonly, :boolean => true) do
    desc "If 'true', then the SQL will only be executed via a notify/subscribe event."

    defaultto(:false)
    newvalues(:true, :false)
  end

  def should_run_sql(refreshing = false)
    unless_param = @parameters[:unless]
    return false if !unless_param.nil? && !unless_param.value.nil? && unless_param.matches(unless_param.value)
    return false if !refreshing && @parameters[:refreshonly].value == :true
    true
  end

  def refresh
    self.property(:command).sync if self.should_run_sql(true)
  end

end
