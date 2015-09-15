# encoding: utf-8

require "psych"
require "yaml"

require File.join File.dirname(__FILE__), "../i18n_yaml_editor.rb"
require File.join File.dirname(__FILE__), "../i18n_yaml_editor/web.rb"
require File.join File.dirname(__FILE__), "../i18n_yaml_editor/store.rb"

require 'active_support/all'
class Hash
  def to_hash_recursive
    result = self.to_hash

    result.each do |key, value|
      case value
      when Hash
        result[key] = value.to_hash_recursive
      when Array
        result[key] = value.to_hash_recursive
      end
    end

    result
  end

  def sort_by_key(recursive=false, &block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if recursive && seed[key].is_a?(Hash)
        seed[key] = seed[key].sort_by_key(true, &block)
      end
      seed
    end
  end
end

class Array
  def to_hash_recursive
    result = self

    result.each_with_index do |value,i|
      case value
      when Hash
        result[i] = value.to_hash_recursive
      when Array
        result[i] = value.to_hash_recursive
      end
    end

    result
  end
end

module I18nYamlEditor
  class App

    def initialize(path, port=5050, relative_root='.')
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
      #files = Dir["/home/wteuber/SD/sage_one_advanced/host_app/config/locales/**/*.yml", "/home/wteuber/SD/sage_one_advanced/advanced_uk/config/locales/**/*.yml", "/home/wteuber/SD/sage_one_gac_de/config/locales/**/*.yml"]
      files.each {|file|
        yaml = YAML.load_file(file)
        store.from_yaml(yaml, file)
      }
    end

    def save_translations
      files = store.to_yaml
      files.each {|file, yaml|
        File.open(file, "w", encoding: "utf-8") do |f|
          # default_locale_translations = I18n.backend.send(:translations)[locale].with_indifferent_access.to_hash_recursive
          # i18n_yaml = {locale.to_s => default_locale_translations}.sort_by_key(true).to_yaml

          i18n_yaml = yaml.with_indifferent_access.to_hash_recursive.to_yaml
          process = i18n_yaml.split(/\n/).reject{|e| e == ''}[1..-1]  # remove "---" from first line in yaml

          # add an empty line if yaml tree level changes by 2 or more
          tmp_ary = []
          process.each_with_index do |line, idx|
            tmp_ary << line
            unless process[idx+1].nil?
              this_line_spcs = line.match(/\A\s*/)[0].length
              next_line_spcs = process[idx+1].match(/\A\s*/)[0].length
              tmp_ary << '' if next_line_spcs - this_line_spcs < -2
            end
          end

          output = tmp_ary * "\n"

          f.puts output
        end
      }

      %x(
        PWD=`pwd`
        cd /home/wteuber/SD/sage_one_advanced/host_app
        bundle exec rake i18n:js:export
        cd $PWD
      )
    end
  end
end
