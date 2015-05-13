##
 # This file is part of the Scribe Mantle Bundle.
 #
 # (c) Scribe Inc. <source@scribe.software>
 #
 # For the full copyright and license information, please view the LICENSE.md
 # file that was distributed with this source code.
 ##

require 'erb'

$ents = Dir.glob(File.join(File.dirname(__FILE__), 'src/Scribe/DigitalHubBundle/Entity/*.php'))

SETTER = ERB.new <<-EOT

    /**
     * Setter for XXXX
     *
     * @param XXXX
     * @return $this
     */
    public function set<%= nice %>($<%= var %> = null)
    {
        $this-><%= var %> = $<%= var %>;

        return $this;
    }
EOT

GETTER = ERB.new <<-EOT

    /**
     * Getter for XXXX
     *
     * @return XXXX
     */
    public function get<%= nice %>()
    {
        return $this-><%= var %>;
    }
EOT

CHECKER = ERB.new <<-EOT

    /**
     * Checker for XXXX
     *
     * @return bool
     */
    public function has<%= nice %>()
    {
        return (bool)$this->get<%= nice %>() !== null;
    }
EOT

CLEARER = ERB.new <<-EOT

    /**
     * Nullify XXXX
     *
     * @return $this
     */
    public function clear<%= nice %>()
    {
        $this->set<%= nice %>(null);

        return $this;
    }
EOT

def make_nice(var)
  n = var.dup
  n[0] = n[0].upcase
  n
end

def check_type(nice, var, doc, type, phr)
  return doc if doc[/#{phr}#{nice}/]
  m = type.result(binding)
  doc[doc.rindex('}')] = m + '}'
  doc
end

$ents.each do |ent|
  en = File.read(ent)
  vars = en.scan(/(?<=private \$)[^;]*(?=;)/)
  vars.each do |var|
    nice = make_nice(var)
    en = check_type(nice, var, en, SETTER, 'set')
    en = check_type(nice, var, en, GETTER, 'get')
    en = check_type(nice, var, en, CHECKER, 'has')
    en = check_type(nice, var, en, CLEARER, 'clear')
  end
  File.open(ent, 'w').write(en)
end

# EOF
