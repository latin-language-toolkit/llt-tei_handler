require 'spec_helper'

describe LLT::XmlHandler::PreProcessor do
  let(:pre_processor) { LLT::XmlHandler::PreProcessor }

  def load_fixture(filename)
    File.read(File.expand_path("../../../fixtures/#{filename}", __FILE__))
  end

  let(:embedded_tei_doc) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <reply>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <xxx/>
          </teiHeader>
          <body>
            <head>TITLE</head>
            <p>Text <ref type='note'>Note</ref> resumed</p>
          </body>
        </TEI>
      </reply
    EOF
  end

  let(:tei_doc) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <xxx/>
        </teiHeader>
        <body>
          <head>TITLE</head>
          <p>Text <ref type='note'>Note</ref> resumed</p>
        </body>
      </TEI>
    EOF
  end

  let(:prefixed_tei_doc) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <reply xmlns:tei="http://www.tei-c.org/ns/1.0">
        <tei:TEI>
          <tei:teiHeader>
            <xxx/>
          </tei:teiHeader>
          <tei:body>
            <tei:head>TITLE</head>
            <tei:p>Text <tei:ref type='note'>Note</tei:ref> resumed</tei:p>
          </tei:body>
        </tei:TEI>
      </tei:reply
    EOF
  end

  let(:doc_wo_ns) do
    <<-EOF
      <?xml version="1.0" encoding="utf-8"?>
      <reply>
        <custom_root>
          <teiHeader></teiHeader>
          <body></body>
        </custom_root>
      </reply>
    EOF
  end

  describe "#new" do
    it "takes a xml document on initialization" do
      doc = <<-EOF
        <?xml version="1.0" encoding="utf-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
        </TEI>
      EOF
      expect { pre_processor.new(doc) }.not_to raise_error
    end

    it "tries to find a root element, given as optional keyword param" do
      doc = pre_processor.new(doc_wo_ns, root: 'custom_root')
      doc.document.root.name.should == 'custom_root'
    end

    it "root element can have a namespace, given as optional keyword param" do
      doc = pre_processor.new(embedded_tei_doc, root: 'TEI', ns: "http://www.tei-c.org/ns/1.0")
      doc.document.root.name.should == "TEI"
    end

    it "really honors the namespace - it has to be present when given" do
      doc = pre_processor.new(embedded_tei_doc, root: 'TEI')
      doc.document.root.name.should_not == "TEI"
    end

    it "also works with prefixes" do
      doc = pre_processor.new(prefixed_tei_doc, root: 'TEI', ns: "http://www.tei-c.org/ns/1.0")
      doc.document.root.name.should == "TEI"
    end
  end

  describe "#remove_nodes" do
    def with_stripped_lines(string)
      string.lines.map(&:strip).join
    end

    it "takes out a given node including all of its content" do
      doc = pre_processor.new(doc_wo_ns)

      doc.document.xpath('//teiHeader').should_not be_empty

      doc.remove_nodes('teiHeader')
      doc.document.xpath('//teiHeader').should be_empty
    end

    it "can remove several nodes at a single step" do
      doc = pre_processor.new(doc_wo_ns)

      doc.document.xpath('//teiHeader').should_not be_empty
      doc.document.xpath('//body').should_not be_empty

      doc.remove_nodes('teiHeader', 'body')
      doc.document.xpath('//teiHeader').should be_empty
      doc.document.xpath('//body').should be_empty
    end

    it "honors a namespace given on initialization" do
      ns =  "http://www.tei-c.org/ns/1.0"
      doc1 = pre_processor.new(tei_doc,   ns: ns)
      doc2 = pre_processor.new(doc_wo_ns, ns: ns)

      doc1.document.xpath('//ns:teiHeader', ns: ns).should_not be_empty
      doc2.document.xpath('//teiHeader').should_not be_empty

      doc1.remove_nodes('teiHeader')
      doc2.remove_nodes('teiHeader')

      doc1.document.xpath('//ns:teiHeader', ns: ns).should be_empty
      doc2.document.xpath('//teiHeader').should_not be_empty
    end

    it "also works with prefixes" do
      ns =  "http://www.tei-c.org/ns/1.0"
      doc = pre_processor.new(prefixed_tei_doc,   ns: ns)

      doc.document.xpath('//ns:teiHeader', ns: ns).should_not be_empty

      doc.remove_nodes('teiHeader')
      doc.document.xpath('//ns:teiHeader', ns: ns).should be_empty
    end
  end
end
