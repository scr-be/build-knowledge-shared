require 'open-uri'
require 'json'
require 'yaml'
require 'base64'

class FixturizeFontAwesome
  HEADER = YAML.load(<<-ICONS
Icon:

    version:

        structure: 1.0.0
        data:      1.0.0

    orm:

        priority:   102
        mode:       truncate
        entity:     s.mantle.icon.entity.class
        repository: s.mantle.icon.repo

    dependencies:

        IconFamily:
            entity:     's.mantle.icon_family.entity.class'
            repository: 's.mantle.icon_family.repo'

    data:
ICONS
)

  MAP_KEYS = {
    'id' => 'slug',
  }

  DROP_KEYS = %w(
    filter
    created
    url
    code
    label
  )

  ADDITIONS = {
    'attributes' => Array.new,
    'familyCollection' => ['@IconFamily?slug=fa']
  }

  WS_WRAPPERS = %w(
    version
    orm
    dependencies
    data
  )

  def initialize(tag, file = nil)
    @tag = tag
    @file = file
  end

  def url
    @url ||= "https://api.github.com/repos/FortAwesome/Font-Awesome/contents/src/icons.yml/?ref=#{@tag}"
  end

  def icon_data
    @icon_data ||= get_yaml['icons']
  end

  def yaml
    @yaml ||= HEADER.to_yaml(indentation: 4)
  end

  def formatted_yaml
    yaml.gsub!(/ -/, '     -')
    WS_WRAPPERS.each do |w|
      yaml.gsub!(/(^    #{w}:)/, "\n\\1\n")
    end
    yaml.gsub!(/(^ +[0-9]+:)/, "\n\\1")
    yaml.gsub!(/\n\n\n/, "\n\n")
    yaml.gsub!(/'null'/, 'null')
    yaml.gsub!(/familyCollection: &1/, 'familyCollection:')
    yaml.gsub!(/familyCollection: \*1/, "familyCollection:\n                - \"@IconFamily?slug=fa\"")
    yaml
  end

  def fixtures
    HEADER['Icon']['data'] = {}
    reformat_icon_data
    formatted_yaml
  end

  def reformat_icon_data
    icon_data.each_with_index do |icon, ind|
      icon['slug'] = icon['id']
      icon.delete('id')
      DROP_KEYS.each do |d|
        icon.delete(d)
      end
      icon['aliases'] ||= 'null'
      icon['attributes'] = 'null'
      icon['familyCollection'] = ['@IconFamily?slug=fa']
      HEADER['Icon']['data'][ind + 1] = icon
    end
  end

  def get_yaml
    if @file
      YAML.load(File.read(@file))
    else
      bs = JSON.load(URI.parse(url).read)['content']
      utf8 = Base64.decode64(bs)
      YAML.load(utf8)
    end
  end
end

awesomer = FixturizeFontAwesome.new(ARGV[0], ARGV[1])

File.open('IconData.yml', 'w') do |f|
  f.write(awesomer.fixtures)
end
