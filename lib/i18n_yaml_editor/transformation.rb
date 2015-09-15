# encoding: utf-8

module I18nYamlEditor
  class TransformationError < StandardError; end

  module Transformation
    def flatten_hash hash, namespace=[], tree={}
      hash.each {|key, value|
        child_ns = namespace.dup << key
        if value.is_a?(Hash)
          flatten_hash value, child_ns, tree
        else
          tree[child_ns.join(".")] = value
        end
      }
      tree
    end
    module_function :flatten_hash

    def nest_hash hash
      result = {}
      hash.each {|key, value|
        begin
          add_key_rec(result, key.split('.'), value)
        rescue => e
          raise TransformationError.new("Failed to nest key: #{key.inspect} with value: #{value.inspect}")
        end
      }
      result
    end

    def add_key_rec(hash, keys, value)
      key = keys.shift
      return value unless key
      hash[key] = add_key_rec(hash[key] || {}, keys, value)
      return hash[key] unless keys.empty?
      hash
    end

    module_function :nest_hash
  end
end
