require 'nokogiri'

class ManaCost
  attr_accessor :mana_text

  def initialize(mana_text)
    self.mana_text = mana_text
  end

  def valid?
    mana_text =~ /([RGBUW]|\d)+/
  end

  def reds
    count_type /R/
  end

  def blues
    count_type /U/
  end

  def blacks
    count_type /B/
  end

  def greens
    count_type /G/
  end

  def whites
    count_type /W/
  end

  def generics
    counts = gather(/\d/)
    if counts.empty?
      0
    else
      counts.map(&:to_i).inject(&:+)
    end
  end

  def cost_hash
    result = {}
    %w[reds blues greens whites blacks generics].each do |name|
      result[name] = send name
    end
    result
  end

  def total
    cost_hash.values.inject &:+
  end

  private

  def count_type(type)
    gather(type).count
  end

  def gather(type)
    mana_text.each_char.select {|c| c =~ type}
  end
end

class Card
  attr_accessor :card_node

  def initialize(card_node)
    self.card_node = card_node
  end

  def mana_text
    _text card_node.children.css("manacost")
  end

  def name
    _text card_node.children.css("name")
  end

  def type
    _text card_node.children.css("type")
  end

  def text
    _text card_node.children.css("text")
  end

  def stats
    _text card_node.children.css("pt")
  end

  def color
    card_node.children.css("color").map {|c| _text c}.join("")
  end

  def display
    non_blanks = [name, mana_text, type, stats, color, text].reject {|a| a.gsub(/\s/,'').empty?}
    non_blanks.join("\n")
  end

  private

  def _text(thing)
    if thing.kind_of? Nokogiri::XML::Text
      thing.to_s
    elsif thing.children.all? {|a| a.kind_of? Nokogiri::XML::Text}
      thing.children.map(&:to_s).join
    end
  end
end


def each_card(&block)
  File.open("cards.xml", "r") do |f|
    document = Nokogiri::XML::Document.parse f
    document.css("card").each do |c|
      card = Card.new(c)
      cost = ManaCost.new(card.mana_text)
      block.call(card, cost)
    end
  end
end

banned_card_names = ["Amulet of Quoz",
"Ancestral Recall",
"Balance",
"Bazaar of Baghdad",
"Black Lotus",
"Black Vise",
"Bronze Tablet",
"Channel",
"Chaos Orb",
"Contract from Below",
"Darkpact",
"Demonic Attorney",
"Demonic Consultation",
"Demonic Tutor",
"Earthcraft",
"Falling Star",
"Fastbond",
"Flash",
"Frantic Search",
"Goblin Recruiter",
"Gush",
"Hermit Druid",
"Imperial Seal",
"Jeweled Bird",
"Library of Alexandria",
"Mana Crypt",
"Mana Drain",
"Mana Vault",
"Memory Jar",
"Mental Misstep",
"Mind Twist",
"Mind's Desire",
"Mishra's Workshop",
"Mox Emerald",
"Mox Jet",
"Mox Pearl",
"Mox Ruby",
"Mox Sapphire",
"Mystical Tutor",
"Necropotence",
"Oath of Druids",
"Rebirth",
"Shahrazad",
"Skullclamp",
"Sol Ring",
"Strip Mine",
"Survival of the Fittest",
"Tempest Efreet",
"Time Vault",
"Time Walk",
"Timetwister",
"Timmerian Fiends",
"Tinker",
"Tolarian Academy",
"Vampiric Tutor",
"Wheel of Fortune",
"Windfall",
"Worldgorger Dragon",
"Yawgmoth's Bargain",
"Yawgmoth's Will"]

task :default do
  cards = []
  each_card do |card, cost|
    next if banned_card_names.include?(card.name)
    puts card.display
    puts
  end
end
