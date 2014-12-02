# encoding: utf-8

require "psych"
require "yaml"

require File.join File.dirname(__FILE__), "../i18n_yaml_editor.rb"
require File.join File.dirname(__FILE__), "../i18n_yaml_editor/web.rb"
require File.join File.dirname(__FILE__), "../i18n_yaml_editor/store.rb"

module I18nYamlEditor
  class App

    def initialize path, port, relative_root
      @path = File.expand_path(path)
      @port = port
      @relative_root = relative_root
      @store = Store.new
      I18nYamlEditor.app = self
    end

    attr_accessor :store, :relative_root

    def start
      $stdout.puts " * Loading translations from #{@path}"
      load_translations

      $stdout.puts " * Creating missing translations"
      store.create_missing_keys

      $stdout.puts " * Starting web editor at port 5050"
      Rack::Server.start :app => Web, :Port => (@port || 5050)
    end

    def load_translations
      files = Dir[@path + "/**/*.yml"]
      files.each {|file|
        yaml = YAML.load_file(file)
        store.from_yaml(yaml, file)
      }
    end

    def save_translations
      files = store.to_yaml
      files.each {|file, yaml|
        File.open(file, "w", encoding: "utf-8") {|f| f << yaml.to_yaml}
      }
    end
  end
end
