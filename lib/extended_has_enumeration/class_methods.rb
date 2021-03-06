module ExtendedHasEnumeration
  module ClassMethods
    # Declares an enumerated attribute called +enumeration+ consisting of
    # the symbols defined in +mapping+.
    #
    # When the database representation of the attribute is a string, +mapping+
    # can be an array of symbols. The string representation of the symbol
    # will be stored in the databased.  E.g.:
    #
    #   has_enumeration :color, [:red, :green, :blue]
    #
    # When the database representation of the attribute is not a string, or
    # if its values do not match up with the string versions of its symbols,
    # an hash mapping symbols to their underlying values may be used:
    #
    #   has_enumeration :color, :red => 1, :green => 2, :blue => 3
    #
    # By default, has_enumeration assumes that the column in the database
    # has the same name as the enumeration.  If this is not the case, the
    # column can be specified with the :attribute option:
    #
    #   has_enumeration :color, [:red, :green, :blue], :attribute => :hue
    #
    def has_enumeration(enumeration, mapping, options = {})
      unless mapping.is_a?(Hash)
        # Recast the mapping as a symbol -> string hash
        mapping_hash = {}
        mapping.each {|m| mapping_hash[m] = m.to_s}
        mapping = mapping_hash
      end

      if options[:initial].present?
        class_eval do
          after_initialize :"initialize_#{enumeration}"

          define_method :"initialize_#{enumeration}" do
            self.send("#{enumeration}=", self.send(enumeration).blank? ? options[:initial] : self.send(enumeration))
          end
        end
      end


      # The underlying attribute
      attribute = options[:attribute] || enumeration

      # ActiveRecord's composed_of method will do most of the work for us.
      # All we have to do is cons up a class that implements the bidirectional
      # mapping described by the provided hash.
      klass = create_enumeration_mapping_class(mapping, options)
      attr_enumeration_mapping_classes[enumeration] = klass

      # Bind the class to a name within the scope of this class
      mapping_class_name = enumeration.to_s.camelize
      const_set(mapping_class_name, klass)
      scoped_class_name = [self.name, mapping_class_name].join('::')

      composed_of(enumeration,
        :class_name => scoped_class_name,
        :mapping => [attribute.to_s, 'raw_value'],
        :constructor => :constructor,
        :converter => :from_sym
      )

      if ActiveRecord::VERSION::MAJOR >= 3 && ActiveRecord::VERSION::MINOR == 0
        # Install this attributes mapping for use later when extending
        # Arel attributes on the fly.
        ::Arel::Table.has_enumeration_mappings[table_name][attribute] = mapping
      else
        # Install our aggregate condition handling override, but only once
        unless @aggregate_conditions_override_installed
          extend ExtendedHasEnumeration::AggregateConditionsOverride
          @aggregate_conditions_override_installed = true
        end
      end
    end

  private
    def attr_enumeration_mapping_classes
      @attr_enumeration_mapping_classes ||= {}
    end

    def create_enumeration_mapping_class(mapping, options={})
      mapping = mapping.with_indifferent_access
      default = options[:default]
      allow_blank = options[:allow_blank]
      Class.new do
        # attr_reader :raw_value
        # alias_method :humanize, :raw_value
        delegate :blank?, to: :raw_value

        define_method :initialize do |raw_value|
          @raw_value = raw_value
          @value = mapping[@raw_value]
        end

        define_method :raw_value do
          @raw_value.blank? ? default : @raw_value
        end

        define_method :to_sym do
          raw_value.try(:to_sym)
        end

        define_method :value do
          mapping[raw_value]
        end

        define_method :to_s do
          raw_value.to_s
        end

        define_method :humanize do
          to_s.humanize
        end

        mapping.keys.each do |sym|
          predicate = "#{sym}?".to_sym
          define_method predicate do
            to_sym == sym.to_sym
          end
        end

        (class <<self;self;end).class_eval do
          define_method :source do
            mapping
          end
          define_method :from_sym do |sym|
            if !mapping.has_key?(sym) && !sym.blank?
              raise ArgumentError.new(
                "#{sym.inspect} is not one of {#{mapping.keys.map(&:inspect).sort.join(', ')}}"
              )
            elsif !allow_blank && sym.blank?
              raise ArgumentError.new(
                "#{name.split('::').last} can't be blank"
              )
            end
            new(sym)
          end
          define_method :constructor do |sym|
            new(sym)
          end
        end
      end
    end
  end
end
