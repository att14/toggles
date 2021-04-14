class Feature::ConstantLookup
  Error = Class.new(Feature::Error) do
    attr_reader :sym

    def initialize(sym)
      @sym = sym
      super(sym.join('::'))
    end
  end


  # Return a tree walker that translates Module#const_missing(sym) into the next child node
  #
  # So Features::Cat::BearDog walks as:
  # * next_features = Feature.features # root
  # * const_missing(:Cat) => next_features = next_features['cat']
  # * const_missing(:BearDog) => next_features['bear_dog']
  #
  # Defined at Toggles.features_dir + "/cat/bear_dog.yaml"
  #
  # @raise [Error] if constant cannot be resoled
  def self.from(features, path)
    Class.new {
      class << self
        attr_accessor :features
        attr_accessor :path

        def const_missing(sym)
          subtree_or_feature = features.fetch(
            # translate class name into path part i.e :BearDog #=> 'bear_dog'
            sym.to_s.gsub(/([a-z])([A-Z])/) { |s| s.chars.join('_') }.downcase.to_sym,
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
    }.tap do |resolver|
      resolver.features = features
      resolver.path = path
    end
  end
end
