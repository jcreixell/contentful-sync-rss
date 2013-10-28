xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Contentful RSS Sync"
    xml.description "Contentful RSS Sync."
    xml.link "http://contentful.com/"

    items.each do |item|
      xml.item do
        xml.title item['sys']['id']
        xml.link "link"
        xml.description "description"
        xml.pubDate DateTime.parse(item['sys']['createdAt'])
        xml.guid "guid"
      end
    end
  end
end
