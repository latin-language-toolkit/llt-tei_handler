module LLT
  module XmlHandler
    class PreProcessor
      require 'nokogiri'

      def initialize(document)
        @document = Nokogiri::XML(document)
        try_to_find_tei_root unless is_tei?
      end

      def to_xml
        without_duplicate_declaration(@document.to_xml).strip
      end

      def is_tei?
        @document.root.name =~ /^TEI/
      end

      def ignore_nodes(*nodes)
        @document.search(*nodes).each(&:remove)
        @document
      end

      alias_method :remove_nodes, :ignore_nodes

      private

      DUPLICATE_XML_VERSION = /<\?xml version=.*\?>\s*{2}/m
      def without_duplicate_declaration(doc)
        if doc.match(DUPLICATE_XML_VERSION)
          doc.sub(/^<\?xml version=.*\?>/, '')
        else
          doc
        end
      end

      def try_to_find_tei_root
        tei = @document.xpath('//*[name() = "TEI" or name() = "TEI.2"]').first
        if tei
          if RUBY_ENGINE == "jruby"
            # Pretty unnecessarily reparses the document fragment, but
            # nokogiri-java seems to have problems with handling namespaces
            # when assigning the root node of a document by hand.
            #
            # The issue has been reported on the nokogiri-talk Google group
            # and is described in detail there (currently awaiting approval)
            @document = Nokogiri::XML(tei.to_s)
          else
            @document = Nokogiri::XML::Document.new
            @document.root = tei
          end
          @document.encoding = "UTF-8"
        else
          raise ArgumentError.new('Document is no TEI XML')
        end
      end
    end
  end
end