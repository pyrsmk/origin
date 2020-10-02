require "./origin/**"

module Origin
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end
