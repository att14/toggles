class Feature::ConstantLookup
  Error = Class.new(Feature::Error) do
    attr_reader :sym

    def initialize(sym)
      @sym = sym
      super(sym.join('::'))
    end
  end

  Resolver = Class.new do
    class << self
      attr_accessor :features
      attr_accessor :path

      def const_missing(sym)
        subtree_or_feature = features.fetch(
          sym.to_s.gsub(/([a-z])([A-Z])/) { |s| s.chars[0] + "_" + s.chars[1] }.downcase.to_sym,
        )
        if subtree_or_feature.is_a?(Hash)
          Feature::ConstantLookup.from(subtree_or_feature, path + [sym])
        else
          subtree_or_feature
        end
      rescue KeyError
        raise Error.new(path + [sym])
      end
    end
  end

  def self.from(features, path)
    Resolver.tap do |resolver|
      resolver.features = features
      resolver.path = path
    end
  end
end
