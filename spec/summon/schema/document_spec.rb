require 'spec_helper'
require 'pathname'

describe Summon::Document do
  EXAMPLE_DOCUMENT_JSON = Pathname(__FILE__).dirname.join("example_document.json").read
  EXPECTED_DOCUMENT_YAML = Pathname(__FILE__).dirname.join('expected_document.yaml').read

  before {@document = Summon::Document.new(@service, JSON.parse(EXAMPLE_DOCUMENT_JSON))}
  subject {@document}
  it {should_not be_from_library}
  its(:abstract) {should eql "This is the most awesome document ever"}
  its(:subject_terms) {should eql ["Women's music", "Popular music", "Rock music"]}
  its(:issns) {should eql ["1063-7125", "0000-1111"]}
  its(:isbns) {should eql [ "0849343763 (v. 1)","0849343771 (v. 2)"]}
  its(:publication_title) {should eql "Batman Books"}
  it {should be_in_holdings}

  describe "authors" do
    it "combines givenname, middlename, surname if fullname is missing" do
      @document.authors[2].name.should == "Shi Wang"
      @document.authors[3].name.should == "Hai C Chu"
    end
    it "preserves order" do
      @document.authors.map(&:name).should == ["Liang, Yong X", "Gu, Miao N", "Shi Wang", "Hai C Chu"]
    end
    context "when 'sequence' doesn't exist in hash" do
      before do
        JSON.parse(EXAMPLE_DOCUMENT_JSON).tap do |data|
          data["Author_xml"] = [{ "fullname" => "Liang, Yong X" }, { "fullname" => "Shi Wang", "sequence" => 1 }]
          @document = Summon::Document.new(@service, data)
        end
      end
      it "handles ArgumentError/NoMethodError" do
        @document.authors.map(&:name).should == ["Liang, Yong X", "Shi Wang"]
      end
    end
  end

  describe "from_library" do
    context "when source_types includes 'Library Catalog'" do
      before do
        JSON.parse(EXAMPLE_DOCUMENT_JSON).tap do |data|
          data["SourceType"] = ["Library Catalog"]
          @document = Summon::Document.new(@service, data)
        end
      end
      subject {@document}
      it {should be_from_library}
    end
    context "when source_types doesn't include 'Library Catalog'" do
      JSON.parse(EXAMPLE_DOCUMENT_JSON).tap do |data|
        data["SourceType"] = ["Index Database"]
        @document = Summon::Document.new(@service, data)
      end
      subject {@document}
      it {should_not be_from_library}
    end
  end

end
