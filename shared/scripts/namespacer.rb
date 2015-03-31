##
 # This file is part of the Scribe Mantle Bundle.
 #
 # (c) Scribe Inc. <source@scribe.software>
 #
 # For the full copyright and license information, please view the LICENSE.md
 # file that was distributed with this source code.
 ##

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end

class Namespacer
  attr_reader :correct_ns, :incorrect_ns,
    :read_dir, :namespaces, :bad_namespaces

  INDENT = '  '
  HALF_RANGE = 4

  def initialize(correct_ns, incorrect_ns, read_dir)
    @incorrect_ns = incorrect_ns
    @correct_ns = correct_ns
    @read_dir = read_dir
    @namespaces = find_namespaces.compact
    @bad_namespaces = namespaces.map { |n| good_to_bad(n) }
  end

  def bad_to_good(str)
    str.gsub(incorrect_ns, correct_ns)
  end

  def good_to_bad(str)
    str.gsub(correct_ns, incorrect_ns)
  end

  def find_namespaces
    get_files(read_dir).map do |f|
      c = File.read(f)
      get_class(c)
    end
  end

  def get_class(content)
    ns = content[/(?<=namespace )[^;]+/]
    klass = content[/(?<=class )[^ \n]+/]
    ns and klass  ? ns + '\\' + klass : nil
  end

  def fix_dir(dir)
    files_and_content = get_file_array(dir)
    puts "NB: Any response containing \"y\" evaluates to true. All other responses evaluate to false.".pink
    puts "-----"
    files_and_content.each do |file, content|
      uses = get_relevant_use_statements(content)
      next if uses.empty?
      puts ""
      puts "Verifying " + file.yellow
      better_content = content.dup
      uses.each do |bad_use|
        console_check(bad_use, better_content)
      end
      if better_content != content
        finalize_content(file, better_content)
      end
    end
  end

  def finalize_content(file, better_content)
    puts ""
    puts "Write changes to " + file.yellow + "?"
    print "> "
    write_content(file, better_content) if affirmative
  end

  def console_check(bad_use, content)
    context = use_context(bad_use, content)
    puts ""
    puts context
    ideal = bad_to_good(bad_use)
    puts "Should be \"#{ideal}\"?".green
    print "> "
    STDOUT.flush
    if affirmative
      content.gsub!(bad_use, ideal)
    end
  end

  def affirmative
    r = gets.chomp.downcase
    r[/y/] ? true : false
  end

  def write_content(file, content)
    File.open(file, 'w') do |f|
      f.write(content)
    end
  end

  def get_file_array(dir)
    get_files(dir).map { |f| [f, File.read(f)] }
  end

  def get_files(dir)
    files = Dir.glob(File.join(dir, '**/*.php'))
  end

  def get_relevant_use_statements(c)
    all_uses = get_use_statements(c)
    all_uses.reject do |u|
      !bad_namespaces.include?(u)
    end
  end

  def get_use_statements(c)
    raw_uses = c.scan(/(?<=use )[^;]+/)
    raw_uses.each_with_object([]) { |s, arr| arr << s.split(/,[\s\n\r]*/) }.flatten
  end

  def use_context(user, content)
    str = content[/(.+\n){1,#{HALF_RANGE}}.+#{Regexp.escape(user)}(.+\n){1,#{HALF_RANGE}}/]
    str.split("\n").map do |line|
      if line[user]
        "#{INDENT}*#{INDENT}#{line}".red
      else
        "#{INDENT}<#{INDENT}#{line}"
      end
    end
  end
end

default_correct_ns = 'Scribe'
default_incorrect_ns = 'Scribe\\MantleBundle'
default_read_dir = 'vendor/scribe/mantle-bundle/lib/Utility'
default_fix_dirs = %w(src/)

# you can pass in order args and overwrite the defaults
# as per the order below. Args 2 through anything will be
# understood as directories to examine and fix.'

correct_ns = ARGV[0] || default_correct_ns
incorrect_ns = ARGV[1] || default_incorrect_ns
read_dir = ARGV[2] || default_read_dir
fix_dirs = ARGV[3 .. -1] || default_fix_dirs

namespace = Namespacer.new(correct_ns, incorrect_ns, read_dir)

fix_dirs.each do |dir|
  namespace.fix_dir(dir)
end

# EOF
