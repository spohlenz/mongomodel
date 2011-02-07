namespace :db do
  desc "Migrate string-based object ids to BSON object ids"
  task :migrate_ids => :environment do
    MongoModel.database.collections.each do |collection|
      unless collection.name =~ /(.*\.)?system\..*/
        puts "Updating collection #{collection.name}..."
        
        updated_documents = 0
        updated_ids = 0
        updated_fks = 0
        updated_fk_arrays = 0
        
        collection.find.each do |doc|
          id = doc['_id']
          
          update_required = false
          
          doc.each do |k, v|
            if k =~ /_id$/ && v.is_a?(String) && BSON::ObjectId.legal?(v)
              doc[k] = BSON::ObjectId(v)
              update_required = true
              
              if k == "_id"
                updated_ids += 1
              else
                updated_fks += 1
              end
            elsif k =~ /_ids$/ && v.is_a?(Array)
              ids = v.map { |id| id.is_a?(String) && BSON::ObjectId.legal?(id) ? BSON::ObjectId(id) : id }
              
              unless doc[k] == ids
                doc[k] = ids
                update_required = true
                updated_fk_arrays += 1
              end
            end
          end
          
          if id != doc['_id']
            collection.remove('_id' => id)
          end
          
          if update_required
            collection.save(doc)
            updated_documents += 1
          end
        end
        
        puts "  (updated #{updated_documents} documents, #{updated_ids} ids, #{updated_fks} foreign keys, #{updated_fk_arrays} foreign key arrays)\n\n"
      end
    end
  end
  
  unless Rake::Task.task_defined?("db:drop")
    desc 'Drops all the collections for the database for the current Rails.env'
    task :drop => :environment do
      MongoModel.database.collections.each do |collection|
        collection.drop unless collection.name =~ /(.*\.)?system\..*/
      end
    end
  end

  unless Rake::Task.task_defined?("db:seed")
    # if another ORM has defined db:seed, don't run it twice.
    desc 'Load the seed data from db/seeds.rb'
    task :seed => :environment do
      seed_file = File.join(Rails.root, 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end
  end

  unless Rake::Task.task_defined?("db:setup")
    desc 'Create the database, and initialize with the seed data'
    task :setup => [ 'db:create', 'db:create_indexes', 'db:seed' ]
  end

  unless Rake::Task.task_defined?("db:reseed")
    desc 'Delete data and seed'
    task :reseed => [ 'db:drop', 'db:seed' ]
  end

  unless Rake::Task.task_defined?("db:create")
    task :create => :environment do
      # noop
    end
  end

  unless Rake::Task.task_defined?("db:migrate")
    task :migrate => :environment do
      # noop
    end
  end

  unless Rake::Task.task_defined?("db:schema:load")
    namespace :schema do
      task :load do
        # noop
      end
    end
  end

  unless Rake::Task.task_defined?("db:test:prepare")
    namespace :test do
      task :prepare do
        # noop
      end
    end
  end

  unless Rake::Task.task_defined?("db:create_indexes")
    task :create_indexes do
       # noop
    end
  end
end
