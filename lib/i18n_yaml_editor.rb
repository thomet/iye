module I18nYamlEditor
  class << self
    attr_accessor :app
  end
end

require File.join File.dirname(__FILE__), "i18n_yaml_editor/app.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/category.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/key.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/store.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/transformation.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/translation.rb"
require File.join File.dirname(__FILE__), "i18n_yaml_editor/web.rb"
