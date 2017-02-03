#
# Copyright:: 2017, AppDirect, Inc., All Rights Reserved.
#

require 'chef-dk/command/generator_commands/base'

module ChefDK
  module Command
    module GeneratorCommands

      # chef generate terraform path/to/basename --generator-cookbook=path/to/generator
      #
      # Generates a basic terraform directory structure. Most file types are
      # omitted, the user is expected to add additional files as needed using
      # the relevant generators.
      class Terraform < Base

        banner "Usage: chef generate terraform NAME [options]"

        attr_reader :errors

        attr_reader :terraform_name_or_path

        option :verbose,
          short:        "-V",
          long:         "--verbose",
          description:  "Show detailed output from the generator",
          boolean:      true,
          default:      false

        options.merge!(SharedGeneratorOptions.options)

        def recipe
          'terraform'
        end

        def initialize(params)
          @params_valid = true
          @terraform_name = nil
          @verbose = false
          super
        end

        def run
          read_and_validate_params
          if params_valid?
            setup_context
            msg("Generating terraform #{terraform_name}")
            chef_runner.converge
            msg("")
            emit_post_create_message
            0
          else
            err(opt_parser)
            1
          end
        rescue ChefDK::ChefRunnerError => e
          err("ERROR: #{e}")
          1
        end

        def emit_post_create_message
          msg("Your terraform is ready. Type `cd #{terraform_name_or_path}` to enter it.")
        end

        def setup_context
          super
          Generator.add_attr_to_context(:skip_git_init, terraform_path_in_git_repo?)
          Generator.add_attr_to_context(:terraform_root, terraform_root)
          Generator.add_attr_to_context(:terraform_name, terraform_name)
          Generator.add_attr_to_context(:verbose, verbose?)
        end

        def terraform_name
          File.basename(terraform_full_path)
        end

        def terraform_root
          File.dirname(terraform_full_path)
        end

        def terraform_full_path
          File.expand_path(terraform_name_or_path, Dir.pwd)
        end

        def verbose?
          @verbose
        end

        def read_and_validate_params
          arguments = parse_options(params)
          @terraform_name_or_path = arguments[0]
          if !@terraform_name_or_path
            @params_valid = false
          end

          if config[:verbose]
            @verbose = true
          end

          true
        end

        def params_valid?
          @params_valid
        end

        def terraform_path_in_git_repo?
          Pathname.new(terraform_full_path).ascend do |dir|
            return true if File.directory?(File.join(dir.to_s, ".git"))
          end
          false
        end
      end
    end
  end
end
