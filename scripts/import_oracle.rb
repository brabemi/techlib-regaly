require 'oci8'
require 'set'
require 'yaml'
require_relative '../app'

def get_sig_info(row)
  sig_clear = row[:signature].split(%r{\/\d+}, 2).join
  sig_data = row[:signature].split(/\s+/, 2)
  return [nil, nil, nil] if sig_data.length != 2
  sig_number = sig_data[1].split(/[^0-9]+/).first
  # p [row['signature'], sig_clear, sig_data[0], sig_number.to_i]
  [sig_clear, sig_data[0], sig_number.to_i]
end

def get_year(row)
  return [1999, 2000] if row[:year] == '1999/00'
  year = row[:year].split(/[^0-9]+/).reject { |e| e == '' }
  start_year = year.first
  end_year = year.last
  return nil, nil if end_year.length > start_year.length
  end_year = start_year[0, start_year.length - end_year.length] + end_year
  start_year = start_year.to_i
  end_year = end_year.to_i
  end_year = start_year if end_year < start_year
  return nil, nil if start_year <= 0 || end_year > Time.now.year
  [start_year, end_year]
end

config = YAML.load_file(ROOT_DIR + '/config/config-import.yml')

username = config['database']['username']
password = config['database']['password']
host = config['database']['host']
port = config['database']['port']
sid = config['database']['sid']
prefixes = config['prefixes']
log_level = config['log_level']
### growth
prefixes_growth = config['prefixes_growth']
###

ActiveRecord::Base.logger.level = log_level

conn_string = "(DESCRIPTION=
(ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=#{host})(PORT=#{port})))
(CONNECT_DATA=(SID=#{sid}))
)"

prefixes_all = prefixes.select { |e| /^[a-zA-Z0-9 ]+$/ =~ e }.join('|')

### growth
prefixes_growth_all = prefixes_growth.select { |e| /^[a-zA-Z0-9 ]+$/ =~ e }.join('|')

growth_year_1 = format('%02d', ((Time.now.year - 1) % 100))
growth_year_2 = format('%02d', ((Time.now.year - 2) % 100))
###

query = "select Z30_CALL_NO, Z30_CHRONOLOGICAL_I, count(*)
from STK50.Z30
where
    Z30_ITEM_PROCESS_STATUS != 'VY' and
    Z30_ITEM_PROCESS_STATUS != 'OP' and
    REGEXP_LIKE(Z30_CALL_NO, '^(#{prefixes_all}) [0-9].*$') and
    Z30_SUB_LIBRARY = 'STK' and
    Z30_CHRONOLOGICAL_I is not null
group by Z30_CALL_NO, Z30_CHRONOLOGICAL_I"

### growth
query_growth = "select Z30_CALL_NO
from STK50.Z30
where
  (Z30_INVENTORY_NUMBER like '#{growth_year_1}/%' or Z30_INVENTORY_NUMBER like '#{growth_year_2}/%') and
  Z30_MATERIAL = 'ISSBD' and
  REGEXP_LIKE(Z30_CALL_NO, '^(#{prefixes_growth_all}) [0-9].*$')"
###

# query = "select Z30_CALL_NO, Z30_CHRONOLOGICAL_I, count(*)
# from (select * from STK50.Z30 where REGEXP_LIKE(Z30_CALL_NO,  '^(#{prefixes_all}) [0-9].*$') and Z30_CHRONOLOGICAL_I is not null and rownum <= 100)
# where
#     Z30_ITEM_PROCESS_STATUS != 'VY' and
#     Z30_ITEM_PROCESS_STATUS != 'OP' and
#     REGEXP_LIKE(Z30_CALL_NO, '^(#{prefixes_all}) [0-9].*$') and
#     Z30_SUB_LIBRARY = 'STK' and
#     Z30_CHRONOLOGICAL_I is not null
# group by Z30_CALL_NO, Z30_CHRONOLOGICAL_I"

print 'Fetching data from aleph ... it may take a while', "\n"

conn = OCI8.new(username, password, conn_string)
result = []
conn.exec(query) do |r|
  result.push(signature: r[0], year: r[1], count: r[2].to_i)
end
### growth
growth = []
conn.exec(query_growth) do |r|
  growth.push(signature: r[0])
end
###
conn.logoff

print 'Parsing data from aleph (', result.length, ' rows)', "\n"

signatures = {}
signatures_growth = {}

result.each do |row|
  sig, sig_pref, sig_num = get_sig_info(row)
  start_year, end_year = get_year(row)
  if sig_pref && sig_num && start_year && end_year
    unless signatures.key?(sig)
      signatures[sig] = {
        prefix: sig_pref,
        number: sig_num,
        year_min: start_year,
        year_max: end_year,
        volumes_total: 0,
        volumes: Hash.new(0)
      }
    end
    signatures[sig][:year_min] = start_year if start_year < signatures[sig][:year_min]
    signatures[sig][:year_max] = end_year if end_year > signatures[sig][:year_max]
    signatures[sig][:volumes_total] += row[:count].to_i
    signatures[sig][:volumes][[start_year, end_year]] += row[:count].to_i
  else
    print 'Unable to parse: ', row, "\n"
  end
end

### growth
print 'Parsing growth data from aleph (', growth.length, ' rows)', "\n"

growth.each do |row|
  sig, sig_pref, sig_num = get_sig_info(row)
  if sig_pref && sig_num
    if signatures_growth.key?(sig)
      signatures_growth[sig] += 1
    else
      signatures_growth[sig] = 1
    end
  else
    print 'Unable to parse growth: ', row, "\n"
  end
end
###

# p signatures

# p signatures_growth

# p signatures_growthfire.sum { |e| e[1] }

# return 0

actual_items = Signature.all

new_signatures = Set.new(signatures.keys)
old_signatures = Set.new(actual_items.map(&:signature))

only_new = new_signatures - old_signatures
only_old = old_signatures - new_signatures
# intersection = old_signatures & new_signatures

existent_items = {}
old_items = {}

actual_items.each do |e|
  if only_old.include? e.signature
    old_items[e.signature] = e
  else
    existent_items[e.signature] = e
  end
end

print 'Updating data in database (', signatures.length, ' signatures) ... it may take a while', "\n"

signatures.each do |k, v|
  sig = if only_new.include? k
          Signature.new
        else
          existent_items[k]
        end
  sig.signature = k
  sig.signature_prefix = v[:prefix]
  sig.signature_number = v[:number]
  sig.year_min = v[:year_min]
  sig.year_max = v[:year_max]
  sig.volumes = v[:volumes]
  sig.volumes_total = v[:volumes_total]
  if signatures_growth.key?(k)
    pattern = sig.year_max.to_s + ']'
    sig.growth = sig.volumes.find_all { |v| v[0].end_with?(pattern) }.sum { |e| e[1] }
    # p sig.growth
  else
    sig.growth = 0
  end
    # sig.growth = sig.volumes.
  # sig.growth = signatures_growth.key?(k) ? signatures_growth[k] : 0
  # p sig if signatures_growth.key?(k)
  sig.save
end

old_items.each_value do |v|
  v.year_min = 0
  v.year_max = 0
  v.volumes = {}
  v.volumes_total = 0
  v.growth = 0
  v.save
end

print 'Task completed', "\n"
