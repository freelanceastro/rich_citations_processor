# Copyright (c) 2014 Public Library of Science

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

module RichCitationsProcessor

  RSpec.describe XMLUtilities do
    subject { XMLUtilities }

    def x(text)
      Nokogiri::XML::Document.parse(text)
    end

    describe "#text" do

      it "should return the text" do
        xml = x(<<-EOX.strip_heredoc
               <root>
               something
               <body>
               <a>text</a>
               more
               </body>
               else
               </root>
               EOX
        )

        expect( subject.text( xml.css('body') ) ).to eq("text\nmore")
      end

    end

    describe "#spaced_text" do

      it "should return the text with spaces" do
        xml = x(<<-EOX.strip_heredoc
               <root>
                 something
                 <node><first>First</first><last>Last</last></node>
                 else
               </root>
        EOX
        )

        expect( subject.spaced_text( xml.css('node') ) ).to eq("First Last")
      end

      it "should normalize leading, tracing and between whitespace" do
        xml = x(<<-EOX.strip_heredoc
               <root>
                 <node> <a>A</a>\n<a> B \n</a><a>C</a>\t<a>D</a>\n\t </node>
               </root>
        EOX
        )

        expect( subject.spaced_text( xml.css('node') ) ).to eq("A B C D")
      end

    end

    describe "#text_before" do

      before do
        @xml = x(<<-EOX.strip_heredoc
               <root>
                 <body> <a>A</a> <b>B</b> <c> C </c> <d>D</d> <e>E</e> </body>
                 <other />
               </root>
        EOX
        )
      end

      it "should return the text before the node" do
        expect( subject.text_before( @xml.css('body'), @xml.at_css('c') ) ).to eq('A B ')
      end

      it "it should return '' if for the first node" do
        expect( subject.text_before( @xml.css('body'), @xml.at_css('a') ) ).to eq('')
      end

      it "it should return nil if node is not found" do
        expect( subject.text_before( @xml.css('body'), @xml.at_css('other') ) ).to be_nil
      end

    end

    describe "#text_after" do

      before do
        @xml = x(<<-EOX.strip_heredoc
               <root>
                 <body> <a>A</a> <b>B</b> <c> C </c> <d>D</d> <e>E</e> </body>
                 <other />
               </root>
        EOX
        )
      end

      it "should return the text before the node" do
        expect( subject.text_after( @xml.css('body'), @xml.css('c').first ) ).to eq(' D E')
      end

      it "it should return '' if for the first node" do
        expect( subject.text_after( @xml.css('body'), @xml.css('e').first ) ).to eq('')
      end

      it "it should return nil if node is not found" do
        expect( subject.text_after( @xml.css('body'), @xml.css('other').first ) ).to be_nil
      end

    end

    describe "#text_between" do

      before do
        @xml = x(<<-EOX.strip_heredoc
               <root>
                 one
                 <before />
                 before
                 <body><a>A</a> <b>B</b> <c>C</c> <d>D</d> <e>E</e></body>
                 after
                 <after />
                 ninety-nine
               </root>
        EOX
        )
      end

      it "should return nil if the first node is nil" do
        expect( subject.text_between( nil, @xml.css('b').first )).to be_nil
      end

      it "should return the text for a range of nodes" do
        expect( subject.text_between( @xml.css('b').first, @xml.css('d').first) ).to eq('B C D')
      end

      it "should work if the first and last nodes are the same" do
        expect( subject.text_between( @xml.css('b').first, @xml.css('b').first) ).to eq('B')
      end

      it "should work if the first node is the first in the parent" do
        expect( subject.text_between( @xml.css('a').first, @xml.css('c').first) ).to eq('A B C')
      end

      it "should work if the last node is the last in the parent" do
        expect( subject.text_between( @xml.css('c').first, @xml.css('e').first) ).to eq('C D E')
      end

      it "should get all of the remaining text if the last node is nil" do
        expect( subject.text_between( @xml.css('c').first, nil) ).to eq('C D E')
      end

      it "should get all of the remaining text if the last node is before the first node" do
        expect( subject.text_between( @xml.css('d').first, @xml.css('b').first) ).to eq('D E')
      end

      it "should fail if the first and last node don't have the same parent" do
        expect { subject.text_between( @xml.css('before').first, @xml.css('e').first) }.to raise_error ArgumentError
      end

      it "should fail if the first and last node don't have the same parent (2)" do
        expect { subject.text_between( @xml.css('a').first, @xml.css('after').first) }.to raise_error ArgumentError
      end

    end

    describe "traversal" do

      before do
        @xml = x(<<-EOX.strip_heredoc
               <root>
                 <a/>
                 <b>
                   <c><d/></c>
                 </b>
                 <e/>
               </root>
        EOX
        )
      end

      it "should traverse depth first" do
        result = []
        subject.depth_traverse(@xml) do |n|
          result << n.name if n.element?
        end

        expect(result).to eq(['a','d','c','b','e','root'])
      end

      it "should traverse breadth first" do
        result = []
        subject.breadth_traverse(@xml) do |n|
          result << n.name if n.element?
        end

        expect(result).to eq(['root','a','b','c','d','e'])
      end

      it "should traverse breadth first from a sub node" do
        result = []
        subject.breadth_traverse(@xml.at_css('b')) do |n|
          result << n.name if n.element?
        end

        expect(result).to eq(['b','c','d'])
      end

      it "should find the nearest node" do
        d = @xml.css('d').first
        b = @xml.css('b').first

        expect(subject.nearest(d, ['b','root'])).to eq(b)
      end

      it "return nil if there is no nearest node" do
        d = @xml.css('d').first

        expect(subject.nearest(d, ['x-b','x-root'])).to be_nil
      end

    end

    describe XMLUtilities::WordCounter do

      before do
        @xml = x(<<-EOX.strip_heredoc
               <root>
                 root 1
                 <body>
                    <a>A</a>
                    <b>B</b>
                    <c> C </c>
                    <d>D</d>
                    <e>E</e>
                 </body>
                 <other />
                 root 99
               </root>
        EOX
        )
      end

      subject { described_class.new(@xml.at_css('body') ) }

      it "should create an instance" do
        subject
      end

      it "should count the words" do
        expect( subject.count_to( @xml.at_css('c')) ).to eq(2)
      end

      it "should raise an exception if the node is not in the container" do
        expect { subject.count_to( @xml.at_css('other')) }.to raise_exception
      end

      it "should raise an exception if the node is a parent of the container" do
        expect { subject.count_to( @xml.at_css('root')) }.to raise_exception
      end

      it "should count subsequent words" do
        expect( subject.count_to( @xml.at_css('c')) ).to eq(2)
        expect( subject.count_to( @xml.at_css('e')) ).to eq(4)
      end

      it "should raise an exception if the same node is requested twice" do
        subject.count_to( @xml.at_css('c') )
        expect { subject.count_to( @xml.at_css('c')) }.to raise_exception
      end

      it "should raise an exception if the counts are not ordered" do
        subject.count_to( @xml.at_css('e') )
        expect { subject.count_to( @xml.at_css('c')) }.to raise_exception
      end

      it "should count to the end" do
        expect( subject.count_to_end ).to eq(5)
      end

      it "should count to the end more than once" do
        expect( subject.count_to_end ).to eq(5)
        expect( subject.count_to_end ).to eq(5)
      end

      it "after counting to the end counting should fail" do
        expect( subject.count_to_end ).to eq(5)
        expect { subject.count_to( @xml.at_css('c')) }.to raise_exception
      end

      it "should count to the end after counting other nodes" do
        expect( subject.count_to( @xml.at_css('e')) ).to eq(4)
        expect( subject.count_to_end ).to eq(5)
      end

    end

  end

end