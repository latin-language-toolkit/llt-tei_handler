module LLT
  module XmlHandler
    class PreProcessor
      require 'nokogiri'

      attr_reader :document

      def initialize(document, root: nil, ns: nil)
        @document = Nokogiri::XML(document)
        @namespace = ns
        go_to_root(root) if root

        @document.encoding = "UTF-8"
      end

      def to_xml
        without_duplicate_declaration(@document.to_xml).strip
      end

      def remove_nodes(*nodes)
        nodes.each do |node|
          @document.xpath(*to_xpath(node, @namespace)).each(&:remove)
        end
      end

      private

      DUPLICATE_XML_VERSION = /<\?xml version=.*\?>\s*{2}/m
      def without_duplicate_declaration(doc)
        if doc.match(DUPLICATE_XML_VERSION)
          doc.sub(/^<\?xml version=.*\?>/, '')
        else
          doc
        end
      end

      def to_xpath(elem, ns)
        ns ? ["//ns:#{elem}", ns: ns] : ["//#{elem}"]
      end

      def go_to_root(root)
        new_root = @document.xpath(*to_xpath(root, @namespace)).first
        return unless new_root # or throw an error?

        if RUBY_ENGINE == "jruby"
          # Pretty unnecessarily reparses the document fragment, but
          # nokogiri-java seems to have problems with handling namespaces
          # when assigning the root node of a document by hand.
          #
          # The issue has been reported on the nokogiri-talk Google group
          # and is described in detail there (currently awaiting approval)
          @document = Nokogiri::XML(new_root.to_s)
          root_ns = new_root.namespace
          @document.root.add_namespace(root_ns.prefix, root_ns.href) if root_ns
        else
          @document = Nokogiri::XML::Document.new
          @document.root = new_root
        end
      end
    end
  end
end
