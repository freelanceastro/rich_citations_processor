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
require 'support/builders/jats'

module RichCitationsProcessor

  RSpec.describe Parsers::JATS::AuthorParser do
    include Spec::Builders::JATS

    let (:parser) { Parsers::JATS.new(xml) }
    let (:paper)  { parser.parse! }

    let (:authors) { paper.authors }

    it "should parse out the authors" do
      meta <<-EOS
        <contrib contrib-type="author">
          <surname>Jolie</surname><given-names>Angelina</given-names>
        </contrib>
        <contrib contrib-type="author">
          <surname>Roberts</surname><given-names>Julia</given-names>
        </contrib>
      EOS

      expect(authors.count).to eq (2)
      expect(authors.first ).to have_attributes(family: 'Jolie',   given:'Angelina')
      expect(authors.second).to have_attributes(family: 'Roberts', given:'Julia'   )
    end

    it "should parse out literal authors" do
      meta <<-EOS
        <contrib contrib-type="author">
          <literal>Roberts, Julia</literal>
        </contrib>
      EOS

      expect(authors.first).to have_attributes(literal: 'Roberts, Julia')
    end

    it "should ignore non-authors" do
      meta <<-EOS
        <contrib contrib-type="author">
          <surname>Jolie</surname><given-names>Angelina</given-names>
        </contrib>
       <contrib contrib-type="editor">
          <surname>Jackson</surname><given-names>Randy</given-names>
        </contrib>
      EOS

      expect(authors.count).to eq(1)
      expect(authors.first).to have_attributes(family: 'Jolie',   given:'Angelina')
    end

    it "should include emails if available" do
      meta <<-EOS
        <contrib contrib-type="author">
          <surname>Jolie</surname><given-names>Angelina</given-names>
          <xref ref-type='corresp' rid='cor2'>
        </contrib>
        <corresp id="cor1">* E-mail: <email xlink:type="simple">f.flintstone@plos.org</email></corresp>
        <corresp id="cor2">* E-mail: <email xlink:type="simple">a.jolie@plos.org</email></corresp>
      EOS

      expect(authors.first).to have_attributes(family: 'Jolie',   given:'Angelina', email:'a.jolie@plos.org')
    end

    it "should include affilitions if available" do
      meta <<-EOS
        <contrib contrib-type="author">
          <surname>Jolie</surname><given-names>Angelina</given-names>
          <xref ref-type='aff' rid='aff2'>
        </contrib>
        <aff id="aff1"><addr-line>Somewhere</addr-line></aff>
        <aff id="aff2"><addr-line>Hollywood</addr-line></aff>
      EOS

      expect(authors.first).to have_attributes(family: 'Jolie',   given:'Angelina', affiliation:'Hollywood')
    end

  end

end