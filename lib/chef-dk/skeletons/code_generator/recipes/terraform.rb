context = ChefDK::Generator.context
terraform_dir = File.join(context.terraform_root, context.terraform_name)

silence_chef_formatter unless context.verbose

generator_desc("Ensuring correct terraform file content")

# terraform root dir
directory terraform_dir

# README
template "#{terraform_dir}/README.md" do
  helpers(ChefDK::Generator::TemplateHelper)
    source "README_terraform.md.erb"
  action :create_if_missing
end
