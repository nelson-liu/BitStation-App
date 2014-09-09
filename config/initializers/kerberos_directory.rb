KERBEROS_DIRECTORY = YAML.load_file(Rails.root.join('config/directory.yml'))

kerberos_directory_hash = {}

KERBEROS_DIRECTORY.each_with_index do |e, i|
  tokens = e[:common_name].split(' ') + [e[:kerberos]]
  tokens.map!(&:downcase)

  tokens.each do |t|
    1.upto(t.length) do |l|
      kerberos_directory_hash[t.slice(0, l)] ||= []
      kerberos_directory_hash[t.slice(0, l)] << i
    end
  end
end

KERBEROS_DIRECTORY_HASH = kerberos_directory_hash