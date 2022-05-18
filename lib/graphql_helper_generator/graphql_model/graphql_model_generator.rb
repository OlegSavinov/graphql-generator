require 'rails/generators'
require 'fileutils'

class GraphqlModelGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :fields, type: :array, default: [], banner: "field_name:field_type"
	class_option :name, type: :string
	class_option :input_type, type: :boolean

	def create_graphql_model_file
    @camelize_name = options[:name].camelize
    @snake_case_name = options[:name].underscore

    parse_variables

    generate_migration
    generate_type
    generate_model
    generate_create_mutation
    generate_update_mutation
    generate_delete_mutation
    generate_factory
    generate_create_test
    generate_update_test
    generate_delete_test

    if options[:input_type].present? then generate_input_type end

    print_note
  end

  private

  def generate_migration
    migration_fields
    prefix_name = Time.now.utc.to_s.delete_suffix(' UTC').delete('^0-9')
    migration_name = @snake_case_name + ".rb"
    migration_dir = "db/migrate/" + prefix_name + "_create_" + migration_name

    template "migration_template.erb", migration_dir
  end

  def generate_model
    generate_model_lines
    filename = @snake_case_name + ".rb"
    dir = "app/models/" + filename

    template "model_template.erb", dir
  end

  def generate_type
    generate_type_fields
    filename = @snake_case_name + "_type.rb"
    dir = "app/graphql/types/" + filename

    template "graphql_types/type_template.erb", dir
  end

  def generate_create_mutation
    generate_create_mutation_lines
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/create_" + filename

    template "mutations/create_mutation_template.erb", dir
  end

  def generate_update_mutation
    generate_update_mutation_lines
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/update_" + filename

    template "mutations/update_mutation_template.erb", dir
  end

  def generate_delete_mutation
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/delete_" + filename

    template "mutations/delete_mutation_template.erb", dir
  end

  def generate_input_type
    filename = @snake_case_name + "_input_type.rb"
    dir = "app/graphql/types/inputs/" + filename

    template "graphql_types/input_type_template.erb", dir
  end

  def generate_factory
    len = @snake_case_name.length-1
    if @snake_case_name[len] == 'y'
      filename = @snake_case_name[0..-1] + "ies.rb"
    else
      filename = @snake_case_name + "s.rb"
    end
    dir = "spec/factories/" + filename

    template "tests/factory_template.erb", dir
  end

  def generate_create_test
    generate_create_test_lines
    filename = "create_" + @snake_case_name + "_spec.rb"
    dir = "spec/requests/" + filename

    template "tests/create_test_template.erb", dir
  end

  def generate_update_test
    generate_update_test_lines
    filename = "update_" + @snake_case_name + "_spec.rb"
    dir = "spec/requests/" + filename

    template "tests/update_test_template.erb", dir
  end

  def generate_delete_test
    filename = "delete_" + @snake_case_name + "_spec.rb"
    dir = "spec/requests/" + filename

    template "tests/delete_test_template.erb", dir
  end

  def parse_variables
    @parsed_fields =
    fields.map{|field|
      option = field.split(':')
      name = option[0]
      required = option[1].ends_with?('!')
      type = handle_type(option[1])
      array = array?(option[1])
      reference = handle_reference(option, type)
      if array then type = type.delete_suffix(']').delete_prefix('[') end

      {name: name, type: type, required: required, array: array, reference: reference}
    }

    # print_array(@parsed_fields, "Parsed vars")
  end

  def generate_update_mutation_lines
    @update_mutation_lines =
      @parsed_fields.map{|field|
        str = 'argument :'
        if field[:reference].present? || field[:type] == 'references'
          str = '# ' + str + field[:name].underscore + "s"
        else
          str += field[:name].underscore
        end

        str += ", "

        type = cast_to_graphql(field)
          
        if field[:reference].present? then type = field[:name].camelize + "InputType" end
        if field[:array].present? then type = "[" + type + "]" end
        str += type + ', required: false'
        str
      }
  end

  def generate_create_test_lines
    @create_test_define_line =
      @parsed_fields.map{|field|
        name = field[:name].camelize
        name[0] = name[0].downcase
        if field[:type] == 'references' then name += 'Id' end
        str = "$" + name + ": " 
        type = cast_to_graphql_input(field)
        if field[:array].present? then type = '[' + type + ']' end
        str += type
        if field[:required].present? then str += "!" end
        str
      }.join(', ')

    @create_test_input_line =
      @parsed_fields.map{|field|
        name = field[:name].camelize
        name[0] = name[0].downcase
        if field[:type] == 'references' then name += 'Id' end
        str = name + ": " + "$" + name
      }.join(', ')
  end

  def generate_update_test_lines
    @update_test_define_line =
      @parsed_fields.filter{|f| !f[:reference].present? }.map{|field|
        name = field[:name].camelize
        name[0] = name[0].downcase
        str = "$" + name + ": " + cast_to_graphql_input(field)
        str
      }.join(', ')

    @update_test_input_line =
      @parsed_fields.filter{|f| !f[:reference].present? }.map{|field|
        name = field[:name].camelize
        name[0] = name[0].downcase
        str = name + ": " + "$" + name
      }.join(', ')
  end


  def generate_create_mutation_lines
    @create_mutation_lines =
      @parsed_fields.map{|field|
        str = 'argument :'
        if field[:reference].present? || field[:type] == 'references'
          str = str + field[:name].underscore + "_id"
        else
          str += field[:name].underscore
        end

        str += ", "

        type = cast_to_graphql(field)

        # if field[:reference].present? then type = field[:name].camelize + "InputType" end
        if field[:reference].present? then type = "ID" end
        if field[:array].present? then type = "[" + type + "]" end

        str += type
        if field[:required].present?
          str += ', required: true'
        else
          str += ', required: false'
        end
        str
      }
  end

  def generate_type_fields
      @type_fields =
      @parsed_fields.map{|field|
        str = 'field :' + field[:name].underscore + ', '

        type = cast_to_graphql(field)
        if field[:reference].present? || field[:type] == 'references' then type = field[:name].camelize + "Type" end
        if field[:array].present? then type = "[" + type + "]" end
        str += type
        if field[:required].present? then 
          str += ', null: false' 
        else 
          str += ', null: true'
        end
        str
      }
  end

  def generate_model_lines
    @model_lines =
      @parsed_fields
        .filter{|field| field[:type] == 'references'}
        .map{|field|
        str = 'belongs_to :'
        if field[:reference].present?
          str += field[:name].underscore
        end

        str
      }
  end

  def migration_fields
    @migration_fields =
      @parsed_fields.map{|field|
        str = 't.' + field[:type] + ' :' + field[:name]

        if field[:reference].present? then str += ", foreign_key: { to_table: :#{field[:reference] || field[:type]} }, type: :uuid" end
        if field[:array].present? then str += ', array: true, default: []' end
        if field[:required].present? then str += ', null: false' end
        str
      }
  end

  # 
  # Helpers
  #

  def array?(option)
    option.delete_suffix('!').ends_with?(']')
  end

  def handle_type(option)
    option = option.delete_suffix('!').delete_suffix(']')
    if option.include?('int') then option = 'integer'
    elsif option.include?('str') then option = 'string'
    elsif option.include?('ref') then option = 'references'
    elsif option.include?('bool') then option = 'boolean'
    else
      :nothing
    end
    option
  end

  def cast_to_graphql(field)
    type = field[:type].camelize

    if type == 'Datetime' then type = 'String'
    elsif type == 'Json' then type = 'GraphQL::Types::JSON'
    elsif type == 'Boolean' then type = 'GraphQL::Types::Boolean'
    elsif type == 'Integer' then type = 'Int'
    end
    type
  end

  def cast_to_graphql_input(field)
    type = field[:type].camelize

    if type == 'Datetime' then type = 'String'
    elsif type == 'Json' then type = 'JSON'
    elsif type == 'Boolean' then type = 'Boolean'
    elsif type == 'Integer' then type = 'Int'
    elsif type == 'References' then type = 'ID'
    end
    type
  end

  def handle_reference(options, type)
    if not type == 'references' 
      return false
    elsif options[2].present? 
      options[2]
    else
      options[0] + 's'
    end
  end

  def print_array(array, name)
    puts "\n " + name + "\n"
    array.map{|f| puts "\n -> " + f.inspect}
  end

  def print_note
    puts "\n\nSucces!"
    puts "Add these lines to your app/graphql/types/mutation_type.rb\n\n"
    puts "field :create_#{@snake_case_name}, mutation: Mutations::Create#{@camelize_name}"
    puts "field :update_#{@snake_case_name}, mutation: Mutations::Update#{@camelize_name}"
    puts "field :delete_#{@snake_case_name}, mutation: Mutations::Delete#{@camelize_name}"
    puts "\n"
  end
end
