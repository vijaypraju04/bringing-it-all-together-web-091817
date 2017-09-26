require "pry"

class Dog
  attr_accessor :id, :name, :breed


  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
        DB[:conn].execute(sql)
      end

    def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
      DB[:conn].execute(sql)
    end

    def save
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end

    def self.create(hash)
      dog = Dog.new(hash)
      # .tap {|dog| dog.save}
      dog.save
      dog
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
        Dog.new(name: row[1], breed: row[2], id: row[0])
      end.first
    end

    def self.find_or_create_by(name:, breed:)
  dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
  if !dogs.empty?
    dog_data = dogs[0]
    dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  else
    dog = self.create(name: name, breed: breed)
  end
  dog
end

def self.new_from_db(dog_data)
  new_dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
end

def self.find_by_name(name)
  sql = <<-SQL
  SELECT *
  FROM dogs
  WHERE name = ?
  LIMIT 1
  SQL
  DB[:conn].execute(sql, name).map do |data|
    self.new_from_db(data)
  end.first
end

def update
  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
  DB[:conn].execute(sql, self.name, self.breed, self.id)
end

# sally = Dog.new("sally", "german shepard")
# sally.update
end
