def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  dns_raw.
    reject { |line| line.match(/^#/) }.reject { |line| line.empty? }.
    map { |line| line.strip.split(", ") }.reject do |record|
      record[0] != "A" && record[0] != "CNAME"
    end
  .each_with_object({}) do |i, records|
           records[i[1]] = { :type => i[0], :destination => i[2] }
         end
end

def resolve(dns_records, lookup_chain, domain)
  fetched_record = dns_records.fetch(domain, nil)
  if fetched_record == nil
    lookup_chain << "No record found for #{domain}"
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
puts lookup_chain.join("=>")

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join("=>")

