class AddColumnTitles < ActiveRecord::Migration
  require 'net/https'
  require 'uri'
  require 'json'

  def up
    add_column :bookmarks, :title, :string
    Bookmark.reset_column_information
    Bookmark.all.each do |bookmark|
      bookmark.title = get_nicovideo_thumb_response(bookmark.smid)[:thumb][:title]
      bookmark.save
    end
  end

  def down
    remove_column :bookmarks, :title
  end

  def get_nicovideo_thumb_response(id_info)
    request = "http://ext.nicovideo.jp/api/getthumbinfo/#{id_info}"

    uri = URI.parse(request)
    xml = Net::HTTP.get(uri)
    json = Hash.from_xml(xml).to_json
    nico_thumb_info = JSON.parse(json, {:symbolize_names => true })

    return nico_thumb_info[:nicovideo_thumb_response]
  end
end
