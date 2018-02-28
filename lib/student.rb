require "pry"

require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
       CREATE TABLE IF NOT EXISTS students(
         id INTEGER PRIMARY KEY,
         name TEXT,
         grade TEXT
       )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"

    DB[:conn].execute(sql)
  end

  def save
    if !@id
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else
      sql = "UPDATE students SET name = ? WHERE id = ?"
      DB[:conn].execute(sql, @name, @id)
    end

  end

  def self.create(name, grade)
    student = Student.new(name,grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = Student.new(row[1],row[2], row[0])
    # binding.pry
  end


  def update
    sql = "UPDATE students SET name = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @id)
    # binding.pry
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"

    student = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student)
  end

end
