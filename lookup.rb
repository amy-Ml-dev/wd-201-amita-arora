def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument
dns_raw = File.readlines("zone")

def parse_dns(original)
  original = original.reject { |line| line.match(/^$/) }
  original = original.reject { |line| line.match(/^#/) }
  mapped = Array.new
  mapped = original.map { |line| line.strip.split(",") }
  hash = Hash.new
  hash = mapped.each_with_object({}) { |r, i| i[r[1].strip] = { type: r[0].strip, dest: r[2].strip } }
  return hash
end

def resolve(dns_records, lookup_chain, domain)
  rec = dns_records.fetch(domain, nil)
  if rec == nil
    lookup_chain << "Error: record not found for #{domain}"
  elsif rec[:type] == "A"
    lookup_chain << rec[:dest]
  elsif rec[:type] == "CNAME"
    lookup_chain << rec[:dest]

    resolve(dns_records, lookup_chain, rec[:dest])
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
