namespace :db do
<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:drop")
=======
  unless Rake::Task.task_defined?("db:drop")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    desc 'Drops all the collections for the database for the current Rails.env'
    task :drop => :environment do
      MongoModel.database.collections.each do |coll|
        coll.drop unless coll.name =~ /(.*\.)?system\..*/
      end
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:seed")
=======
  unless Rake::Task.task_defined?("db:seed")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    # if another ORM has defined db:seed, don't run it twice.
    desc 'Load the seed data from db/seeds.rb'
    task :seed => :environment do
      seed_file = File.join(Rails.root, 'db', 'seeds.rb')
      load(seed_file) if File.exist?(seed_file)
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:setup")
=======
  unless Rake::Task.task_defined?("db:setup")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    desc 'Create the database, and initialize with the seed data'
    task :setup => [ 'db:create', 'db:create_indexes', 'db:seed' ]
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:reseed")
=======
  unless Rake::Task.task_defined?("db:reseed")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    desc 'Delete data and seed'
    task :reseed => [ 'db:drop', 'db:seed' ]
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:create")
=======
  unless Rake::Task.task_defined?("db:create")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    task :create => :environment do
      # noop
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:migrate")
=======
  unless Rake::Task.task_defined?("db:migrate")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    task :migrate => :environment do
      # noop
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:schema:load")
=======
  unless Rake::Task.task_defined?("db:schema:load")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    namespace :schema do
      task :load do
        # noop
      end
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:test:prepare")
=======
  unless Rake::Task.task_defined?("db:test:prepare")
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
    namespace :test do
      task :prepare do
        # noop
      end
    end
  end

<<<<<<< HEAD
  if not Rake::Task.task_defined?("db:create_indexes")
    task :create_indexes do
       # "mongo_model:create_indexes"
       # noop
     end
  end
end
=======
  unless Rake::Task.task_defined?("db:create_indexes")
    task :create_indexes do
       # noop
    end
  end
end
>>>>>>> 1b7d23797d797675a1f889a103b97dbfed7e1f2a
