module Utilities
  GLOBAL_TRUNCATED_BODY_DEFAULT = 280
  
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
        elsif (value.class.name == 'BigDecimal' or value.class.name == 'Float') and hash2[key].class.name == 'String' and value == Float(hash2[key])
        elsif value.class.name == 'String' and hash2[key].class.name == 'FalseClass' and value.to_i == 0
        elsif value.class.name == 'String' and hash2[key].class.name == 'TrueClass' and value.to_i == 1
        elsif value.class.name == hash2[key].class.name and value == hash2[key]
          # head scratcher -- you'd think diff would reject this...
        else
          real_changes[key] = value
        end
      else
        # Controversial whether to do this or not. If you add it it will consider anything not in the attributes list as a change, this includes array
        #   properties like categories, and derivative things like the properties of promotion strategy dates. It's not perfect. Without it you can't
        #   see changes to categories or those derived things; with it, you see them whether they're changed or not.
        # Current compromise is to show *all* differences, so that we won't miss anything, but mark the ones that might not be changes with a "?"
        real_changes["(?)#{key}"] = value
      end
    end
    
    real_changes 
  end
  
  # An HTML-safe truncation using nokogiri, based off of:
  # http://blog.madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html
  #
  # but without monkey-patching, and behavior more consistent with Rails
  # truncate. 
  #
  # It's hard to get all the edge-cases right, we probably mis-calculate slightly
  # on edge cases, and we aren't always able to strictly respect :separator, sometimes
  # breaking on tag boundaries instead. But this should be good enough for actual use
  # cases, where those types of incorrect results are still good enough. 
  #
  # ruby 1.9 only, in 1.8.7 non-ascii won't be handled quite right. 
  #
  # Pass in a Nokogiri node, probably created with Nokogiri::HTML::DocumentFragment.parse(string)
  #
  # Might want to check length of your string to see if, even with HTML tags, it's
  # still under limit, before parsing as nokogiri and passing in here -- for efficiency.
  #
  # Get back a Nokogiri node, call #inner_html on it to go back to a string 
  # (and you probably want to call .html_safe on the string you get back for use
  # in rails view)
  #
  # WARNING: Cannot set ommission to "&hellip;" or similar html-escaped string, since it will
  #          get escaped again, and you get: &amp;hellip;
  def self.nokogiri_truncate(node, max_length, omission, separator = nil)
    if node.kind_of?(::Nokogiri::XML::Text)   
      if node.content.length > max_length
        allowable_endpoint = [0, max_length - omission.length].max
        if separator
          allowable_endpoint = (node.content.rindex(separator, allowable_endpoint) || allowable_endpoint)
        end        
        
        ::Nokogiri::XML::Text.new(node.content.slice(0, allowable_endpoint) + omission, node.parent)
      else
        node.dup
      end
    else # DocumentFragment or Element
      return node if node.inner_text.length <= max_length
      
      truncated_node = node.dup
      truncated_node.children.remove
      remaining_length = max_length 
      
      node.children.each do |child|
        #require 'debugger'
        #debugger
        if remaining_length == 0
          truncated_node.add_child ::Nokogiri::XML::Text.new(omission, truncated_node)
          break
        elsif remaining_length < 0          
          break        
        end
        truncated_node.add_child nokogiri_truncate(child, remaining_length, omission, separator)
        # can end up less than 0 if the child was truncated to fit, that's
        # fine: 
        remaining_length = remaining_length - child.inner_text.length

      end
      truncated_node
    end
  end  

  # Like rails truncate helper, and taking the same options, but html_safe.
  # 
  # If no HTML tags, just call default Rails truncate
  #
  # Default omission marker is unicode elipsis unlike rails three periods. 
  #
  # :length option will also default to 280, what we think is a good
  # length for abstract/snippet display, unlike rails 10. 
  def self.html_truncator(str, options = {})
    options.reverse_merge!(:omission => '...', :length => GLOBAL_TRUNCATED_BODY_DEFAULT)
    
    # works for non-html of course, but for html a quick check
    # to avoid expensive nokogiri parse if the whole string, even
    # with tags, is still less than max length. 
    return str.html_safe if str.length < options[:length]
    
    if str.index('<').nil?
      str.truncate(options.delete(:length), options)
    else
      noko = Nokogiri::HTML::DocumentFragment.parse(str)
      Utilities.nokogiri_truncate(noko, options[:length], options[:omission], options[:separator]).inner_html.html_safe
    end
  end
end