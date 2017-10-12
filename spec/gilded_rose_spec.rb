require_relative '../lib/gilded_rose'

describe "#update_quality" do

  context "with a single item" do
    let(:initial_sell_in) { 5 }
    let(:initial_quality) { 10 }
    let(:name) { "item" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    before { update_quality([item]) }

    it "should lower quality and by ONE" do
      expect(item.quality).to equal (initial_quality - 1)
    end

    it "should lower sell_in by ONE" do
      expect(item.sell_in).to equal (initial_sell_in - 1)
    end
  end

  context "with multiple items" do
    let(:items) {
      [
        Item.new("NORMAL ITEM", 5, 10),
        Item.new("Aged Brie", 3, 10),
      ]
    }

    before { update_quality(items) }

    it "should lower NORMAL ITEM's quality and sell_in by ONE" do
      expect(items[0].quality).to equal 9
      expect(items[0].sell_in).to equal 4
    end

    it "should increase Aged Brie's quality by ONE and lower sell_in by ONE" do
      expect(items[1].quality).to equal 11
      expect(items[1].sell_in).to equal 2
    end
  end

  context "with a quality 0 item" do
    let(:initial_sell_in) { 5 }
    let(:initial_quality) { 0 }
    let(:name) { "item" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    before { update_quality([item]) }

    it "should not lower the quality beyond 0" do
      expect(item.quality).to equal 0
    end
  end

  context "with an item that has passed sell by date" do
    let(:initial_sell_in) { 0 }
    let(:initial_quality) { 10 }
    let(:name) { "item" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    before { update_quality([item]) }

    it "should lower the quality twice as fast" do
      expect(item.quality).to equal (initial_quality - 2)
    end
  end

  context "with Sulfuras" do
    let(:initial_sell_in) { 5 }
    let(:initial_quality) { 80 }
    let(:name) { "Sulfuras, Hand of Ragnaros" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    before { update_quality([item]) }

    it "should not CHANGE the quality and sell_in" do
      expect(item.quality).to equal (initial_quality)
      expect(item.sell_in).to equal (initial_sell_in)
    end
  end

  context "with Aged Brie" do
    let(:initial_sell_in) { 5 }
    let(:initial_quality) { 49 }
    let(:name) { "Aged Brie" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    before { update_quality([item]) }

    it "should increase the quality by ONE" do
      expect(item.quality).to equal (initial_quality + 1)
    end

    it "should not increase the quality beyond 50" do
      update_quality([item])
      expect(item.quality).to equal 50
    end
  end

  context "with Backstage Passes" do
    let(:initial_sell_in) { 10 }
    let(:initial_quality) { 10 }
    let(:name) { "Backstage passes to a TAFKAL80ETC concert" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    it "should increase quality by 2 for each decrease in sell_in" do
      while item.sell_in > 5 do
        update_quality([item])
      end
      expect(item.quality).to equal (initial_quality + 2 * 5)
    end

    it "should increase quality by 3 for each decrease in sell_in when sell_in is 5 or less" do
      while item.sell_in > 0 do
        update_quality([item])
      end
      expect(item.quality).to equal (initial_quality + 2 * 5 + 3 * 5)
    end

    it "should drop quality to 0 when sell_in is less than 0 (after the concert)" do
      while item.sell_in >= 0 do
        update_quality([item])
      end
      expect(item.quality).to equal 0
    end
  end

  context "with Conjured" do
    let(:initial_sell_in) { 10 }
    let(:initial_quality) { 50 }
    let(:name) { "Conjured" }
    let(:item) { Item.new(name, initial_sell_in, initial_quality) }

    it "should decrease the quality by 2" do
      update_quality([item])
      expect(item.quality).to equal(initial_quality - 2)
    end

    it "should decrease the quality by 4 after sell by date" do
      item.sell_in = 0
      update_quality([item])
      expect(item.quality).to equal(initial_quality - 4)
    end
  end

end
