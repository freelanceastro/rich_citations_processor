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

# Base class for resolving citation references to Candidate URIs
# The base class is optimized for resolving references one at a time

module RichCitationsProcessor
  module URIResolvers

    class Grouped < Base
      abstract!

      def resolve!
        group_size = self.class.const_get(:GROUP_SIZE)
        method_not_implemented_error('GROUP_SIZE')  unless group_size

        filtered_references.each_slice(group_size) do |ref_list|
          ref_collection = Models::Collection.new(Models::Reference)
          ref_collection << ref_list
          resolve_references!(ref_collection)
        end if attempt?
      end

      protected

      def resolve_references!(ref_collection)
        method_not_implemented_error
      end

    end
  end
end
