# monkey patching inorder to suppress header hijacking by net/http, RFC -> headers are case insensitive
# File lib/net/http/header.rb, line 220, ruby 3.1.2

# def capitalize(name)
#   name.to_s.split(/-/).map {|s| s.capitalize }.join('-')
# end

class CustomGet < Net::HTTP::Get
    def capitalize(name)
      name
    end
end