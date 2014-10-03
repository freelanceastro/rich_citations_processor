# Copyright (c) 2014 Public Library of Science
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe Collection do

  class TestItem
    attr_reader :attributes
    def initialize(*a); @attributes=a; end
    def ==(other); self.attributes == other.attributes; end
    def property; attributes.first; end
  end

  let(:coll) { Collection.new(TestItem)}
  let(:filled_coll) { coll.add TestItem.new(1); coll.add TestItem.new(3); coll.add TestItem.new(2); coll }

  it "should create a Collection" do
    expect(Collection.new(Object)).not_to be_nil
  end

  describe "#add" do

    it "should add an item" do
      i = TestItem.new
      expect { coll.add(i) }.not_to raise_error
      expect(coll.to_a).to eq([i])
    end

    it "should fail when adding  a duplicate item" do
      i1 = TestItem.new(1)
      expect { coll.add(i1) }.not_to raise_error
      i2 = TestItem.new(1)
      expect { coll.add(i2) }.to raise_error
    end

    it "should add an item from multiple arguments" do
      i = TestItem.new
      result = nil
      expect { result = coll.add(1,2,3) }.not_to raise_error
      expect( result ).to be_a_kind_of(TestItem)
      expect( result.attributes).to eq([1, 2, 3])
    end

    it "should add an item from a hash or named parameters" do
      i = TestItem.new
      result = nil
      expect { result = coll.add(a:1, b:2) }.not_to raise_error
      expect( result ).to be_a_kind_of(TestItem)
      expect( result.attributes).to eq([{a:1, b:2}])
    end

    it "should succeed if no parameters are passed" do
      i = TestItem.new
      result = nil
      expect { result = coll.add }.not_to raise_error
      expect( result ).to be_a_kind_of(TestItem)
    end

    it "should fail if a different class is added" do
      i = Object.new
      result = nil
      expect { result = c.add }.to raise_error
    end

  end

  describe "#for" do

    it "should find an item based on any field" do
      result = filled_coll.for(property: 3)
      expect(result).not_to be_nil
      expect(result.property).to eq(3)

      result = filled_coll.for(attributes: [2])
      expect(result).not_to be_nil
      expect(result.attributes).to eq([2])
    end

    it "should return nil if an item is not found" do
      result = filled_coll.for(property: 9)
      expect(result).to be_nil
    end

  end

  describe "operations" do

    it "should handle basic operations" do
      expect(filled_coll.length).to eq(3)
      expect(filled_coll.size  ).to eq(3)
      expect(filled_coll.count ).to eq(3)

      expect( filled_coll.include?( TestItem.new(3) ) ).to be_truthy
      expect( filled_coll.include?( TestItem.new(4) ) ).to be_falsey

      results = []
      filled_coll.each { |i| results << i.property }
      expect(results).to eq( [ 1, 3, 2 ] )

      results = filled_coll.map { |i| i.property }
      expect(results).to eq( [ 1, 3, 2 ] )
    end

  end

end
