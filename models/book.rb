require_relative '../db/sql_runner'
require_relative './author'

class Book

  attr_reader :id, :author_id
  attr_accessor :title, :genre, :description, :stock, :buying_cost, :selling_price, :picture_link

  def initialize(details)
    @id = details['id'].to_i
    @title = details['title']
    @author_id = details['author_id'].to_i
    @genre = details['genre']
    @description = details['description']
    @stock = details['stock'].to_i
    @buying_cost = details['buying_cost'].to_i
    @selling_price = details['selling_price'].to_i
    @picture_link = details['picture_link']
  end

  def self.map_books(books_array)
    return books_array.map{|book_hash| Book.new(book_hash)}
  end

  def save()
    sql = 'INSERT INTO books (title, author_id, genre, description, stock, buying_cost, selling_price, picture_link) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id'
    values = [@title, @author_id, @genre, @description, @stock, @buying_cost, @selling_price, @picture_link]
    book = SqlRunner.run(sql, values).first()
    @id = book['id'].to_i
  end

  def self.all()
    sql = 'SELECT * FROM books ORDER BY id'
    books_array = SqlRunner.run(sql)
    return map_books(books_array)
  end

  def self.all_alphabetically
    sql = 'SELECT * FROM books ORDER BY title'
    books_array = SqlRunner.run(sql)
    return map_books(books_array)
  end

  def self.delete_all
    sql = 'DELETE FROM books'
    SqlRunner.run(sql)
  end

  def update()
    sql = 'UPDATE books SET (title, author_id, genre, description, stock, buying_cost, selling_price, picture_link) = ($1, $2, $3, $4, $5, $6, $7, $8) WHERE id = $9'
    values = [@title, @author_id, @genre, @description, @stock, @buying_cost, @selling_price, @picture_link, @id]
    SqlRunner.run(sql, values)
  end

  def delete
    sql = 'DELETE FROM books WHERE id = $1'
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.find_by_title(title)
    sql = 'SELECT * FROM books WHERE title = $1'
    values = [title]
    book = SqlRunner.run(sql, values).first
    return Book.new(book)
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM books WHERE id = $1'
    values = [id]
    book = SqlRunner.run(sql, values).first
    return Book.new(book)
  end

  def self.find_by_genre(genre)
    sql = 'SELECT * FROM books WHERE genre = $1'
    values = [genre]
    books_array = SqlRunner.run(sql, values)
    return Book.map_books(books_array)
  end

  def find_other_books_in_same_genre
    sql = 'SELECT * FROM books WHERE genre = $1 EXCEPT SELECT * FROM books WHERE id = $2'
    values = [@genre, @id]
    books_array = SqlRunner.run(sql, values)
    return Book.map_books(books_array)
  end

  def find_author
    sql = 'SELECT * FROM authors WHERE id = $1'
    values = [@author_id]
    author = SqlRunner.run(sql, values).first
    return Author.new(author)
  end

  def find_author_name
    sql = 'SELECT * FROM authors WHERE id = $1'
    values = [@author_id]
    author = SqlRunner.run(sql, values).first
    return author['name']
  end

  def buy_book(quantity)
    if (@buying_cost * quantity > Shop.get_total)
    @stock += quantity
    update()
  end

  def sell_book(quantity)
    @stock -= quantity
    update()
  end

end
