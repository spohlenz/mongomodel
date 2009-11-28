module CreateInstances
  def create_instances(n, model, attributes={})
    n.times { model.new(attributes).save }
  end
end
