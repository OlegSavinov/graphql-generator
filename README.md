# GraphQLGenerator

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphql-generator

## Usage

To run generator of model Book, run:

    $ rails generate graphql_model a title:string! num_pages:int! color:str is_for_sale:bool! author:ref!:users --name book

This will generate

1. migration
2. model
3. GraphQL type
4. GraphQL mutations: create, update, delete
5. Facotry
6. Rspec tests for mutations: create, update, delete

Follow instructions, add mutation names in your 'mutation_type.rb' file
### Note
* '!' defines if the field is required
* 'ref' param will create field author with reference to table users. If names are the same, you may not specity reference table
* 'string, str' note, that both string and str can be used, as well as int:integer, bool:boolean
* Additional parameter '--input_type true' will create input type of the model

Run migration

    $ rails db:migrate

Run tests

    $ rspec --tag current
