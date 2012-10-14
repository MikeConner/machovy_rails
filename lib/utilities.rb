module Utilities
  # Want to compare params coming back from a form with the record on disk. The trouble is the disk attributes have database types (e.g., integers)
  #   whereas params always has strings. So diff doesn't work well. Call this instead, and it will ignore integer/string differences.
  def self.type_insensitive_diff(hash1, hash2)
    changes = hash1.diff(hash2)
    real_changes = Hash.new
    # It takes values from hash1
    # Real changes are if both have the key and
    changes.each do |key, value|
      if hash2.has_key?(key)
        if value.class.name == 'String' and hash2[key].class.name == 'Fixnum' and Integer(value) == hash2[key]
        elsif value.class.name == 'Fixnum' and hash2[key].class.name == 'String' and value == Integer(hash2[key])
        elsif value.class.name == 'String' and (hash2[key].class.name == 'BigDecimal' or hash2[key].class.name == 'Float') and Float(value) == hash2[key]
        elsif (value.class.name == 'BigDecimal' or value.class.name == 'Float') and hash2[key].class.name == 'String' and value == Float(hash2[key])
        elsif value.class.name == hash2[key].class.name and value == hash2[key]
          # head scratcher -- you'd think diff would reject this...
        else
          real_changes[key] = value
        end        
      end
    end
    
    real_changes 
  end
end