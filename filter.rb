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


def cost1(card, cost)
  if cost.valid? && cost.cost_hash.values.all? {|c| c <= 1}
    puts card.display
    puts
  end
end

def cost2(card, cost)
  if cost.valid? && cost.cost_hash.any? {|(kind, c)| kind != "generics" && c == 2}
    puts card.display
    puts
  end
end

File.open("cards.xml", "r") do |f|
  document = Nokogiri::XML::Document.parse f
  document.css("card").each do |c|
    card = Card.new(c)
    cost = ManaCost.new(card.mana_text)
    send(ARGV.first, card, cost)
  end
end
