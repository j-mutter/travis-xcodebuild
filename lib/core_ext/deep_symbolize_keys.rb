# This is Travis-CI's implementation instead of the current activesupport version
# https://github.com/travis-ci/travis-build/blob/master/lib/core_ext/hash/deep_symbolize_keys.rb
class Hash
  def deep_symbolize_keys
    inject({}) { |result, (key, value)|
      result[(key.to_sym rescue key) || key] = case value
      when Array
        value.map { |value| value.is_a?(Hash) ? value.deep_symbolize_keys : value }
      when Hash
        value.deep_symbolize_keys
      else
        value
      end
      result
    }
  end unless Hash.method_defined?(:deep_symbolize_keys)

  def deep_symbolize_keys!
    replace(deep_symbolize_keys)
  end unless Hash.method_defined?(:deep_symbolize_keys!)
end
