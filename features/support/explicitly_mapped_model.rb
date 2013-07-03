class ExplicitlyMappedModel < ActiveRecord::Base
  has_enumeration :color, {:red => 'Red color', :green => 2, :blue => 3}, {allow_blank: true}
end
