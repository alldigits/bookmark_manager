require 'pg'
require 'uri'
require_relative 'database_connection'

class Bookmark
  attr_reader :id, :title, :url

  def initialize(id:, title:, url:)
    @id = id
    @title = title
    @url = url
  end

  def self.all
   result = DatabaseConnection.query("SELECT * FROM bookmarks")
   result.map do |bookmark|
     Bookmark.new(
       id: bookmark['id'],
       title: bookmark['title'],
       url: bookmark['url']
     )
     end
  end

  def self.create(url:, title:)
    # result is a postgres object, and you transform it into a ruby object
    return false unless is_url?(url)
    result = DatabaseConnection.query("INSERT INTO bookmarks (title, url) VALUES('#{title}', '#{url}') RETURNING id, title, url;")
    Bookmark.new(id: result[0]['id'], title: result[0]['title'], url: result[0]['url'])
  end

  def self.delete(id:)
    DatabaseConnection.query("DELETE FROM bookmarks WHERE id = #{id}") # use SQL to delete the id given
  end

  def self.get(id:)
    result = DatabaseConnection.query("SELECT * FROM bookmarks WHERE id = #{id}")
    Bookmark.new(id: result[0]['id'], title: result[0]['title'], url: result[0]['url'])
  end

  def self.update(id:, title:, url:)
    result = DatabaseConnection.query("UPDATE bookmarks SET url = '#{url}', title = '#{title}' WHERE id = #{id} RETURNING id, url, title;")
    Bookmark.new(id: result[0]['id'], title: result[0]['title'], url: result[0]['url'])
  end

  private

  def self.is_url?(url)
    url =~ /\A#{URI::regexp(['http', 'https'])}\z/
  end

end
