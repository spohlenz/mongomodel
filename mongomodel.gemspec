# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mongomodel}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Pohlenz"]
  s.date = %q{2010-04-21}
  s.default_executable = %q{console}
  s.description = %q{MongoModel is a MongoDB ORM for Ruby/Rails similar to ActiveRecord and DataMapper.}
  s.email = %q{sam@sampohlenz.com}
  s.executables = ["console"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "LICENSE",
     "README.md",
     "Rakefile",
     "bin/console",
     "lib/mongomodel.rb",
     "lib/mongomodel/attributes/mongo.rb",
     "lib/mongomodel/attributes/store.rb",
     "lib/mongomodel/attributes/typecasting.rb",
     "lib/mongomodel/concerns/abstract_class.rb",
     "lib/mongomodel/concerns/activemodel.rb",
     "lib/mongomodel/concerns/associations.rb",
     "lib/mongomodel/concerns/associations/base/association.rb",
     "lib/mongomodel/concerns/associations/base/definition.rb",
     "lib/mongomodel/concerns/associations/base/proxy.rb",
     "lib/mongomodel/concerns/associations/belongs_to.rb",
     "lib/mongomodel/concerns/associations/has_many_by_foreign_key.rb",
     "lib/mongomodel/concerns/associations/has_many_by_ids.rb",
     "lib/mongomodel/concerns/attribute_methods.rb",
     "lib/mongomodel/concerns/attribute_methods/before_type_cast.rb",
     "lib/mongomodel/concerns/attribute_methods/dirty.rb",
     "lib/mongomodel/concerns/attribute_methods/protected.rb",
     "lib/mongomodel/concerns/attribute_methods/query.rb",
     "lib/mongomodel/concerns/attribute_methods/read.rb",
     "lib/mongomodel/concerns/attribute_methods/write.rb",
     "lib/mongomodel/concerns/attributes.rb",
     "lib/mongomodel/concerns/callbacks.rb",
     "lib/mongomodel/concerns/logging.rb",
     "lib/mongomodel/concerns/pretty_inspect.rb",
     "lib/mongomodel/concerns/properties.rb",
     "lib/mongomodel/concerns/record_status.rb",
     "lib/mongomodel/concerns/serialization.rb",
     "lib/mongomodel/concerns/timestamps.rb",
     "lib/mongomodel/concerns/translation.rb",
     "lib/mongomodel/concerns/validations.rb",
     "lib/mongomodel/concerns/validations/associated.rb",
     "lib/mongomodel/document.rb",
     "lib/mongomodel/document/callbacks.rb",
     "lib/mongomodel/document/dynamic_finders.rb",
     "lib/mongomodel/document/indexes.rb",
     "lib/mongomodel/document/optimistic_locking.rb",
     "lib/mongomodel/document/persistence.rb",
     "lib/mongomodel/document/scopes.rb",
     "lib/mongomodel/document/validations.rb",
     "lib/mongomodel/document/validations/uniqueness.rb",
     "lib/mongomodel/embedded_document.rb",
     "lib/mongomodel/locale/en.yml",
     "lib/mongomodel/support/collection.rb",
     "lib/mongomodel/support/configuration.rb",
     "lib/mongomodel/support/core_extensions.rb",
     "lib/mongomodel/support/dynamic_finder.rb",
     "lib/mongomodel/support/exceptions.rb",
     "lib/mongomodel/support/mongo_operator.rb",
     "lib/mongomodel/support/mongo_options.rb",
     "lib/mongomodel/support/mongo_order.rb",
     "lib/mongomodel/support/scope.rb",
     "lib/mongomodel/support/scope/dynamic_finders.rb",
     "lib/mongomodel/support/scope/finder_methods.rb",
     "lib/mongomodel/support/scope/query_methods.rb",
     "lib/mongomodel/support/scope/spawn_methods.rb",
     "lib/mongomodel/support/types.rb",
     "lib/mongomodel/support/types/array.rb",
     "lib/mongomodel/support/types/boolean.rb",
     "lib/mongomodel/support/types/custom.rb",
     "lib/mongomodel/support/types/date.rb",
     "lib/mongomodel/support/types/float.rb",
     "lib/mongomodel/support/types/hash.rb",
     "lib/mongomodel/support/types/integer.rb",
     "lib/mongomodel/support/types/object.rb",
     "lib/mongomodel/support/types/string.rb",
     "lib/mongomodel/support/types/symbol.rb",
     "lib/mongomodel/support/types/time.rb",
     "lib/mongomodel/version.rb",
     "mongomodel.gemspec",
     "spec/mongomodel/attributes/store_spec.rb",
     "spec/mongomodel/concerns/activemodel_spec.rb",
     "spec/mongomodel/concerns/associations/belongs_to_spec.rb",
     "spec/mongomodel/concerns/associations/has_many_by_foreign_key_spec.rb",
     "spec/mongomodel/concerns/associations/has_many_by_ids_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/before_type_cast_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/dirty_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/protected_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/query_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/read_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/write_spec.rb",
     "spec/mongomodel/concerns/attributes_spec.rb",
     "spec/mongomodel/concerns/callbacks_spec.rb",
     "spec/mongomodel/concerns/logging_spec.rb",
     "spec/mongomodel/concerns/pretty_inspect_spec.rb",
     "spec/mongomodel/concerns/properties_spec.rb",
     "spec/mongomodel/concerns/serialization/json_serialization_spec.rb",
     "spec/mongomodel/concerns/timestamps_spec.rb",
     "spec/mongomodel/concerns/translation_spec.rb",
     "spec/mongomodel/concerns/validations_spec.rb",
     "spec/mongomodel/document/callbacks_spec.rb",
     "spec/mongomodel/document/dynamic_finders_spec.rb",
     "spec/mongomodel/document/finders_spec.rb",
     "spec/mongomodel/document/indexes_spec.rb",
     "spec/mongomodel/document/optimistic_locking_spec.rb",
     "spec/mongomodel/document/persistence_spec.rb",
     "spec/mongomodel/document/scopes_spec.rb",
     "spec/mongomodel/document/validations/uniqueness_spec.rb",
     "spec/mongomodel/document/validations_spec.rb",
     "spec/mongomodel/document_spec.rb",
     "spec/mongomodel/embedded_document_spec.rb",
     "spec/mongomodel/mongomodel_spec.rb",
     "spec/mongomodel/support/collection_spec.rb",
     "spec/mongomodel/support/mongo_operator_spec.rb",
     "spec/mongomodel/support/mongo_options_spec.rb",
     "spec/mongomodel/support/mongo_order_spec.rb",
     "spec/mongomodel/support/property_spec.rb",
     "spec/mongomodel/support/scope_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/specdoc.opts",
     "spec/support/callbacks.rb",
     "spec/support/helpers/define_class.rb",
     "spec/support/helpers/document_finder_stubs.rb",
     "spec/support/helpers/specs_for.rb",
     "spec/support/matchers/be_a_subclass_of.rb",
     "spec/support/matchers/be_truthy.rb",
     "spec/support/matchers/find_with.rb",
     "spec/support/matchers/respond_to_boolean.rb",
     "spec/support/matchers/run_callbacks.rb",
     "spec/support/models.rb",
     "spec/support/time.rb"
  ]
  s.homepage = %q{http://github.com/spohlenz/mongomodel}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{MongoDB ORM for Ruby/Rails}
  s.test_files = [
    "spec/mongomodel/attributes/store_spec.rb",
     "spec/mongomodel/concerns/activemodel_spec.rb",
     "spec/mongomodel/concerns/associations/belongs_to_spec.rb",
     "spec/mongomodel/concerns/associations/has_many_by_foreign_key_spec.rb",
     "spec/mongomodel/concerns/associations/has_many_by_ids_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/before_type_cast_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/dirty_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/protected_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/query_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/read_spec.rb",
     "spec/mongomodel/concerns/attribute_methods/write_spec.rb",
     "spec/mongomodel/concerns/attributes_spec.rb",
     "spec/mongomodel/concerns/callbacks_spec.rb",
     "spec/mongomodel/concerns/logging_spec.rb",
     "spec/mongomodel/concerns/pretty_inspect_spec.rb",
     "spec/mongomodel/concerns/properties_spec.rb",
     "spec/mongomodel/concerns/serialization/json_serialization_spec.rb",
     "spec/mongomodel/concerns/timestamps_spec.rb",
     "spec/mongomodel/concerns/translation_spec.rb",
     "spec/mongomodel/concerns/validations_spec.rb",
     "spec/mongomodel/document/callbacks_spec.rb",
     "spec/mongomodel/document/dynamic_finders_spec.rb",
     "spec/mongomodel/document/finders_spec.rb",
     "spec/mongomodel/document/indexes_spec.rb",
     "spec/mongomodel/document/optimistic_locking_spec.rb",
     "spec/mongomodel/document/persistence_spec.rb",
     "spec/mongomodel/document/scopes_spec.rb",
     "spec/mongomodel/document/validations/uniqueness_spec.rb",
     "spec/mongomodel/document/validations_spec.rb",
     "spec/mongomodel/document_spec.rb",
     "spec/mongomodel/embedded_document_spec.rb",
     "spec/mongomodel/mongomodel_spec.rb",
     "spec/mongomodel/support/collection_spec.rb",
     "spec/mongomodel/support/mongo_operator_spec.rb",
     "spec/mongomodel/support/mongo_options_spec.rb",
     "spec/mongomodel/support/mongo_order_spec.rb",
     "spec/mongomodel/support/property_spec.rb",
     "spec/mongomodel/support/scope_spec.rb",
     "spec/spec_helper.rb",
     "spec/support/callbacks.rb",
     "spec/support/helpers/define_class.rb",
     "spec/support/helpers/document_finder_stubs.rb",
     "spec/support/helpers/specs_for.rb",
     "spec/support/matchers/be_a_subclass_of.rb",
     "spec/support/matchers/be_truthy.rb",
     "spec/support/matchers/find_with.rb",
     "spec/support/matchers/respond_to_boolean.rb",
     "spec/support/matchers/run_callbacks.rb",
     "spec/support/models.rb",
     "spec/support/time.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0.beta3"])
      s.add_runtime_dependency(%q<activemodel>, [">= 3.0.0.beta3"])
      s.add_runtime_dependency(%q<mongo>, [">= 0.20.1"])
      s.add_runtime_dependency(%q<bson>, [">= 0.20.1"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.0.beta3"])
      s.add_dependency(%q<activemodel>, [">= 3.0.0.beta3"])
      s.add_dependency(%q<mongo>, [">= 0.20.1"])
      s.add_dependency(%q<bson>, [">= 0.20.1"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.0.beta3"])
    s.add_dependency(%q<activemodel>, [">= 3.0.0.beta3"])
    s.add_dependency(%q<mongo>, [">= 0.20.1"])
    s.add_dependency(%q<bson>, [">= 0.20.1"])
  end
end

