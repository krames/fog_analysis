def constantize(sym)
  sym.to_s.split('_').collect{|s| s.capitalize}.join
end

def services
  return @klasses if @klasses
  @klasses = []
  Fog.services.keys.each do |service|
    begin
      base_name = constantize service
      @klasses << Fog.const_get(base_name)
    rescue NameError
      # class isnt directory under Fog namespace
    end
  end
  @klasses
end