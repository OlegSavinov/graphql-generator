class GraphQlGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :fields, type: :array, default: [], banner: "field_name:field_type"
	class_option :name, type: :string
	class_option :input_type, type: :boolean

	def create_service_file
    @camelize_name = options[:name].camelize
    @snake_case_name = options[:name].underscore

    parse_variables

    generate_migration
    generate_type
    generate_model
    generate_create_mutation
    generate_update_mutation
    generate_delete_mutation

    if options[:input_type].present? then generate_input_type end

    print_note
  end

  private

  def generate_migration
    migration_fields
    prefix_name = Time.now.utc.to_s.delete_suffix(' UTC').delete('^0-9')
    migration_name = @snake_case_name + ".rb"
    migration_dir = "db/migrate/" + prefix_name + "_" + migration_name

    # template "migration_template.erb", migration_dir
  end

  def generate_model
    generate_model_lines
    filename = @snake_case_name + ".rb"
    dir = "app/models/" + filename

    # template "model_template.erb", dir
  end

  def generate_type
    generate_create_mutation_lines
    filename = "create_" + @snake_case_name + ".rb"
    dir = "app/graphql/mutations/" + filename

    # template "create_mutation_template.erb", dir
  end

  def generate_type
    generate_type_fields
    filename = @snake_case_name + "_type.rb"
    dir = "app/graphql/types/" + filename

    # template "graphql_types/type_template.erb", dir
  end

  def generate_create_mutation
    generate_create_mutation_lines
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/create_" + filename

    # template "mutations/create_mutation_template.erb", dir
  end

  def generate_update_mutation
    generate_update_mutation_lines
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/update_" + filename

    # template "mutations/update_mutation_template.erb", dir
  end

  def generate_delete_mutation
    filename = @snake_case_name + ".rb"
    dir = "app/graphql/mutations/delete_" + filename

    # template "mutations/delete_mutation_template.erb", dir
  end

  def generate_input_type
    filename = @snake_case_name + "_input_type.rb"
    dir = "app/graphql/types/inputs/" + filename

    # template "graphql_types/input_type_template.erb", dir
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

    print_array(@parsed_fields, "Parsed vars")
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

    print_array(@update_mutation_lines, "Update mutation lines")
  end

  def generate_create_mutation_lines
    @create_mutation_lines =
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

        str += type
        if field[:required].present?
          str += ', required: true'
        else
          str += ', required: false'
        end
        str
      }

    print_array(@create_mutation_lines, "CREATE mutation lines")
  end

  def generate_type_fields
      @type_fields =
      @parsed_fields.map{|field|
        str = 'field :'
        if field[:reference].present?
          str += field[:name].underscore + "s"
        else
          str += field[:name].underscore
        end

        str += ", "

        type = cast_to_graphql(field)
        if field[:reference].present? || field[:type] == 'references' then type = field[:name].camelize + "Type" end
        if field[:array].present? then type = "[" + type + "]" end
        str += type
        if field[:required].present? then str += ', null: false' end
        str
      }

      print_array(@type_fields, "Type fields")
  end

  def generate_model_lines
    @model_lines =
      @parsed_fields
        .filter{|field| field[:type] == 'references'}
        .map{|field|
        str = 'has_many :'
        if field[:reference].present?
          str += field[:reference].underscore
        end

        str += ', dependent: :destroy'
        str
      }

    print_array(@model_lines, "Model lines")
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

    print_array(@migration_fields, "Migration lines")
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
    puts "field :create_#{@snake_case_name}, mutation: mutations::Create#{@camelize_name}"
    puts "field :update_#{@snake_case_name}, mutation: mutations::Update#{@camelize_name}"
    puts "field :delete_#{@snake_case_name}, mutation: mutations::Delete#{@camelize_name}"
    puts "\n"
  end
end
