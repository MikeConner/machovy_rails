web: bundle exec rails server thin -p $PORT
persistent_worker: bundle exec rake jobs:work
worker: bundle exec rake jobs:work
