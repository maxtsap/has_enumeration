class ModelWithWrongDefault < ActiveRecord::Base
  has_enumeration :color, {:red => 'Red color', :green => 2, :blue => 3}, {allow_nil: true, default: :yellow}
end
