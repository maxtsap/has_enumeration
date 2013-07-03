require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ExtendedHasEnumeration, 'with invalid values' do
  before(:each) do
    @model = ExplicitlyMappedModel.new
  end

  it 'raises an exception when assigned an invalid value' do
    lambda do
      @model.color = :beige
    end.should raise_error(ArgumentError, ':beige is not one of {"blue", "green", "red"}')
  end

  if ActiveRecord::VERSION::MAJOR >= 3
    context 'with ActiveRecord 3.x' do
      it 'raises an exception when finding with an invalid value' do
        lambda do
          ExplicitlyMappedModel.where(:color => :beige).all
        end.should raise_error(ArgumentError, ':beige is not one of {"blue", "green", "red"}')
      end

      #TODO: handle porting to some other meta_where equivalent that is forward compatible with ActiveRecord 3.1.x+
      #it 'raises an exception when finding with an invalid value via meta_where' do
      #  lambda do
      #    ExplicitlyMappedModel.where(:color.not_eq => :beige).all
      #  end.should raise_error(ArgumentError, ':beige is not one of {:blue, :green, :red}')
      #end
    end
  else
    context 'With ActiveRecord 2.x' do
      it 'raises an exception when finding with an invalid value' do
        lambda do
          ExplicitlyMappedModel.find(:all, :conditions => {:color => :beige})
        end.should raise_error(ArgumentError, ':beige is not one of {"blue", "green", "red"}')
      end
    end
  end
end

describe ExtendedHasEnumeration, 'with an uninitialied value' do
  context 'in a newly-created object' do
    it 'returns nil for the value of the enumeration' do
      ExplicitlyMappedModel.new.color.raw_value.should be_nil
    end
  end

  context 'in an existing object' do
    it 'returns nil for the value of the enumeration' do
      object = ExplicitlyMappedModel.find(ExplicitlyMappedModel.create!.id)
      object.color.raw_value.should be_nil
    end
  end
end

describe ExtendedHasEnumeration, 'assignment of nil' do
  it 'sets the enumeration to nil' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color = nil
    object.color.raw_value.should be_nil
  end

  it 'persists across a trip to the database' do
    object = ExplicitlyMappedModel.create!(:color => :red)
    object.color = nil
    object.save!
    ExplicitlyMappedModel.find(object.id).color.raw_value.should be_nil
  end
end

describe ExtendedHasEnumeration, 'string formatting' do
  it 'returns the value as a string if to_s is called on it' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color.to_s.should == 'red'
  end
end

describe ExtendedHasEnumeration, 'symbol formatting' do
  it 'returns the value as a string if to_s is called on it' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color.to_sym.should == :red
  end
end

describe ExtendedHasEnumeration, 'symbol formatting' do
  it 'returns the value as a string if to_s is called on it' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color.value.should == 'Red color'
  end
end

describe ExtendedHasEnumeration, 'hash value' do
  it 'returns the raw value as a string if raw_value is called on it' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color.raw_value.should == :red
  end

  it 'returns the raw value as a string if humanize is called on it' do
    object = ExplicitlyMappedModel.new(:color => :red)
    object.color.humanize.should == 'Red'
  end
end

describe ExtendedHasEnumeration, 'source' do
  it 'returns the passed hash' do
    ExplicitlyMappedModel::Color.source.should == {'red' => 'Red color', 'green' => 2, 'blue' => 3}
  end
end

describe ExtendedHasEnumeration, 'has hash with with_indifferent_access' do
  it 'allows assign string' do
    object = ExplicitlyMappedModel.create!(:color => 'red')
    object.color.raw_value.should == 'red'
  end
end

describe ExtendedHasEnumeration, 'constructor' do
  it 'returns class without passing value' do
    object = ExplicitlyMappedModel.create!
    object.color.class.should == ExplicitlyMappedModel::Color
  end

  it 'returns nil on raw_value without passing value' do
    object = ExplicitlyMappedModel.create! color: nil
    object.color.raw_value.should be_blank
  end
end

describe ExtendedHasEnumeration, 'default value' do

  it 'returns true when calls red? on it' do
    object = ExplicitlyMappedModelWithDefault.create!
    object.color.red?.should be_true
  end

  it 'returns default value' do
    object = ExplicitlyMappedModelWithDefault.create!
    object.color.raw_value.should == :red
  end

  it 'returns default value of hash' do
    object = ExplicitlyMappedModelWithDefault.create!
    object.color.value.should == 'Red color'
  end

  it 'returns nil if default is wrong' do
    object = ModelWithWrongDefault.create!
    object.color.value.should be_nil
  end
end

describe ExtendedHasEnumeration, 'initial value' do

  it 'returns true when calls red? on it' do
    object = MappedModelWithInitial.create!
    object.color.red?.should be_true
  end

  it 'returns initial value' do
    object = MappedModelWithInitial.create!
    object.color.raw_value.should == :red
  end

  it 'returns initial value of hash' do
    object = MappedModelWithInitial.create!
    object.color.value.should == 'Red color'
  end

  it 'returns nil after seting to it' do
    object = MappedModelWithInitial.create!
    object.color = nil
    object.color.raw_value.should be_nil
  end

  it 'returns nil if default is wrong' do
    object = ModelWithWrongDefault.create!
    object.color.value.should be_nil
  end
end
