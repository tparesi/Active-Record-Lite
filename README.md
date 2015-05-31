# Active-Record-Lite

Object-relational mapping (ORM), inspired by ActiveRecord, using Ruby
metaprogramming.

Here are the features I have built in so far:

* Attribute Accessor - create getter or setter methods
* SQL object - all, find, insert, update, and save methods
* Searchable - using where, while protecting against SQL injection
* belongs_to, has_many, and has_one_through associations

Here is an example on how to use this ORM:

```ruby
require 'active-record-lite.rb'

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id

  finalize!
end

cat = Cat.new(name: "Garfield", owner_id: 1)
cat.save

cats = Cat.where(name: "Garfield")
cats = Cat.where(name: "Garfield", owner_id: 1)

garfield = cat.find(1)
garfield.human #=>  <#Human:0x007f9ba9897d98 @first_name="Jon", @last_name="Arbuckle">

```


Enjoy!
