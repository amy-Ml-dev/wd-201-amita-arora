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
  hash = mapped.each_with_object({}) { |record, i| i[record[1].strip] = { type: record[0].strip, destination: record[2].strip } }
  return hash
end

def resolve(dns_records, lookup_chain, domain)
  fetched_record = dns_records.fetch(domain, nil)
  if fetched_record == nil
    lookup_chain << "Error: record not found for #{domain}"
  elsif fetched_record[:type] == "A"
    lookup_chain << fetched_record[:destination]
  elsif fetched_record[:type] == "CNAME"
    lookup_chain << fetched_record[:destination]
    resolve(dns_records, lookup_chain, fetched_record[:destination])
  end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
