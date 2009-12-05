module SpecsFor
  def specs_for(*klasses, &block)
    klasses.each do |klass|
      describe(klass, &block)
    end
  end
  
  def specing?(klass)
    described_class == klass
  end
end
