# Active-Record-Lite

Object-relational mapping (ORM), inspired by ActiveRecord, using Ruby
metaprogramming.

Here are the features I have built in so far:

* Attribute Accessor - create getter or setter methods
* SQL object - all, find, insert, update, and save methods
* Searchable - using where, while protecting against SQL injection
* belongs_to, has_many, and has_one_through associations


In order to use this ORM, download this project and require
'active-record-lite' within whichever file you are going to extend
SQLOject to a class.

For example, to use the Searchable module's where method to query a DB,
first have the class inherit from SQLObject. Now you can search the
class and its respective table by using ClassName.where(var: "var"). The
class now has access to Associations and many other useful SQLObject
methods without having to use heredocs to write SQL.

Enjoy!
