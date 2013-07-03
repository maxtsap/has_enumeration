class MappedModelWithInitial < ActiveRecord::Base
  has_enumeration :color, {:red => 'Red color', :green => 2, :blue => 3}, {initial: :red, allow_blank: true}
end
