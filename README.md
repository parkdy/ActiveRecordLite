ActiveRecordLite
================

A clone of Rails' ActiveRecord class (models) written in Ruby and SQL. Makes use of Ruby's metaprogramming features and custom SQL queries.

Getting Started
---------------

1. Clone Git repository or download as ZIP.
2. Navigate to `ActiveRecordLite` directory in terminal.
3. Install required gems by entering:
    - `gem install sqlite3`
    - `gem install rspec`
4. Create database by entering:
    - `cat spec/cats.sql | sqlite3 spec/cats.db`
5. Run specs by entering:
    - `rake`
6. Source code is under the `lib/active_record_lite` directory
