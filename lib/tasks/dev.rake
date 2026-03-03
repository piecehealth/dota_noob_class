namespace :dev do
  desc "Load local development seed data (db/dev_seeds.rb)"
  task seed: :environment do
    abort "Do not run dev:seed in production!" if Rails.env.production?
    load Rails.root.join("db/dev_seeds.rb")
  end
end
